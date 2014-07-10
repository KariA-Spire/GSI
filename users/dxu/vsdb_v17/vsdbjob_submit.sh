#!/bin/ksh
set -ux

##-------------------------------------------------------------------
## Fanglin Yang,  September 2010
## E-mail: fanglin.yang@noaa.gov, Tel: 301-6833722          
## Global Weather and Climate Modeling Branch, EMC/NCEP/NOAA/
##    This package generates forecast perfomance stats in VSDB format 
##    and makes a variety of graphics to compare anomaly correlation 
##    and RMSE among different experiments. It also makes graphics of
##    CONUS precip skill scores and fits to rawindsonde observations.
##    The different components can be turned on or off as desired. 
##    Graphics are sent to a web server for display (for example:  
##    http://www.emc.ncep.noaa.gov/gmb/wx24fy/vsdb/prhs11/)
##-------------------------------------------------------------------

 MAKEVSDBDATA=YES           ;#To create VSDB date
#MAKEVSDBDATA=NO            ;#VSDB data already exists

#MAKEMAPS=YES               ;#To make AC and RMS maps
 MAKEMAPS=NO                ;#Not to make AC and RMS maps

#..............
 CONUSDATA=YES              ;#To generate precip verification stats
#CONUSDATA=NO               ;#all precip stats already exist

#CONUSPLOTS=YES             ;#To make precip verification maps
 CONUSPLOTS=NO              ;#Not to make precip verification maps
#..............

#FIT2OBS=YES                ;#To make fit-to-obs maps              
 FIT2OBS=NO                 ;#Not to make fit-to-obs maps              
#..............

#MAPS2D=YES                 ;#To make maps of lat-lon distributions and zonal-mean corss-sections.
 MAPS2D=NO                  ;#Not to make maps of lat-lon distributions and zonal-mean corss-sections.

#----------------------------------------------------------------------
export machine=WCOSS              ;#IBM(cirrus/stratus), ZEUS, GAEA, and JET etc
export machine=$(echo $machine|tr '[a-z]' '[A-Z]')
myhome=`pwd`
set -a;. ${myhome}/setup_envs.sh $machine 
if [ $? -ne 0 -o $rc -gt 0 ]; then exit; fi
set -ux

export tmpdir=$STMP/$LOGNAME/nwpvrfy$$               ;#temporary directory for running verification
export mapdir=$tmpdir/web                            ;#local directory to display plots and web templates
mkdir -p $tmpdir ||exit
if [ ! -d $mapdir ]; then
 mkdir -p $mapdir ; cd $mapdir ||exit
 tar xvf ${vsdbhome}/vsdb_exp_webpage.tar 
fi
cd $tmpdir ||exit
rm *.out


myarch=$GNOSCRUB/$LOGNAME/archive              ;#archive directory of experiments 
COMROT=$PTMP/$LOGNAME/COMROT                   ;#running directory of experiments
chost=$(hostname)                              ;#current computer host name

### --------------------------------------------------------------
###   make vsdb database
      if [ $MAKEVSDBDATA = YES ] ; then
### --------------------------------------------------------------
export fcyclist="00 12"                        ;#forecast cycles to be verified
export expnlist="prhs13 fim"                   ;#experiment names 
export expdlist="$myarch $myarch"              ;#exp directories, can be different
export complist="$chost  $chost "              ;#computer names, can be different if passwordless ftp works 
export dumplist=".gfs. .fim."                  ;#file format pgb${asub}${fhr}${dump}${yyyymmdd}${cyc}
export vhrlist="00 12 "                        ;#verification hours for each day             
export DATEST=20130801                         ;#verification starting date
export DATEND=20130815                         ;#verification ending date
export vlength=384                             ;#forecast length in hour

export rundir=$tmpdir/stats
export listvar1=fcyclist,expnlist,expdlist,complist,dumplist,vhrlist,DATEST,DATEND,vlength,rundir
export listvar2=machine,anl_type,scppgb,sfcvsdb,canldir,ecmanldir,vsdbsave,vsdbhome,gd,NWPROD
export listvar="$listvar1,$listvar2"

## pgb files must be saved as $expdlist/$expnlist/pgbf${fhr}${cdump}${yyyymmdd}${cyc}
if [ $batch = YES ]; then
  $SUBJOB -e $listvar -a $ACCOUNT  -q $CUE2RUN -g $GROUP -p 1/1/N -r 2048/1 -t 6:00:00 \
     -j vstep1 -o $tmpdir/vstep1.out  ${vsdbhome}/verify_exp_step1.sh
else
     ${vsdbhome}/verify_exp_step1.sh 1>${tmpdir}/vstep1.out 2>&1
fi

### --------------------------------------------------------------
      fi                                       
### --------------------------------------------------------------


 
### --------------------------------------------------------------
###   make AC and RMSE maps            
      if [ $MAKEMAPS = YES ] ; then
### --------------------------------------------------------------
#
export fcycle="00 12"                      ;#forecast cycles to be verified
export mdlist="gfs prexp prexp2"           ;#experiment names, up to 10, to compare on maps
export vsdblist="$gfsvsdb $vsdbsave1 $vsdbsave2"  ;#vsdb stats directories 
export vhrlist="00 12"                     ;#verification hours for each day to show on map
export DATEST=20120201                     ;#verification starting date to show on map
export DATEND=20120228                     ;#verification ending date to show on map
export vlength=240                         ;#forecast length in hour to show on map
export maptop=10                           ;#can be set to 10, 50 or 100 hPa for cross-section maps
export maskmiss=1                          ;#remove missing data from all models to unify sample size, 0-->NO, 1-->Yes
export rundir=$tmpdir/acrms$$
export scoredir=$rundir/score

  ${vsdbhome}/verify_exp_step2.sh  1>${tmpdir}/vstep2.out 2>&1 


##--wait 3 hours for all stats to be created and then generate scorecard 
if [ ${scorecard:-NO} = YES ]; then
 if [ $batch = YES ]; then
   listvar=SDATE,EDATE,mdlist,webhostid,webhost,ftpdir,doftp,rundir,scoredir,vsdbhome,mapdir
   $SUBJOB -e $listvar -a $ACCOUNT  -q $CUE2FTP -g $GROUP -p 1/1/S -r 1024/1 -t 1:00:00 -w +0300 \
      -j scorecard -o $rundir/score.out  ${vsdbhome}/run_scorecard.sh   
 else
    sleep 10800
    ${vsdbhome}/run_scorecard.sh  1>$rundir/score.out 2>&1 
 fi
fi
### --------------------------------------------------------------
    fi
### --------------------------------------------------------------



### --------------------------------------------------------------
###   compute precip threat score stats over CONUS   
      if [ $CONUSDATA = YES ] ; then
### --------------------------------------------------------------
export expnlist="prhs13 prtest"                          ;#experiment names
export expdlist="$COMROT $COMROT"                        ;#fcst data directories, can be different
export hpsslist="/NCEPDEV/hpssuser/g01/wx24fy/WCOSS /NCEPDEV/hpssuser/g01/wx24fy/WCOSS"  ;#hpss archive directory                  
export complist="$chost  $chost "                        ;#computer names, can be different if passwordless ftp works 
export ftyplist="flx flx"                                ;#file types: pgb or flx
export dumplist=".gfs. .gfs."                            ;#file format ${ftyp}f${fhr}${dump}${yyyymmdd}${cyc}
export ptyplist="PRATE PRATE"                            ;#precip types in GRIB: PRATE or APCP
export bucket=6                        ;#accumulation bucket in hours. bucket=0 -- continuous accumulation
export fhout=6                                           ;#forecast output frequency in hours
export cycle="00"                                        ;#forecast cycle to verify, give only one
export DATEST=20130601                                   ;#forecast starting date 
export DATEND=20130630                                   ;#forecast ending date 
export ARCDIR=$GNOSCRUB/$LOGNAME/archive                 ;#directory to save stats data
export rundir=$tmpdir/mkup_precip                        ;#temporary running directory
export scrdir=${vsdbhome}/precip                  
                                                                                                                           
export listvar1=expnlist,expdlist,hpsslist,complist,ftyplist,dumplist,ptyplist,bucket,fhout,cycle
export listvar2=machine,DATEST,DATEND,ARCDIR,rundir,scrdir,OBSPCP,mapdir,scppgb,NWPROD
export listvar="$listvar1,$listvar2"

if [ $batch = YES ]; then
  $SUBJOB -e $listvar -a $ACCOUNT  -q $CUE2RUN -g $GROUP -p 1/1/S -r 1024/1 -t 06:00:00  \
    -j mkup_rain_stat.sh -o $tmpdir/mkup_rain_stat.out ${scrdir}/mkup_rain_stat.sh
else
    ${scrdir}/mkup_rain_stat.sh  1>${tmpdir}/mkup_rain_stat.out 2>&1       
fi
### --------------------------------------------------------------
      fi
### --------------------------------------------------------------


### --------------------------------------------------------------
###   make CONUS precip skill score maps 
      if [ $CONUSPLOTS = YES ] ; then
### --------------------------------------------------------------
export expnlist="gfs prhs13"                              ;#experiment names, up to 6 , gfs is operational GFS
export expdlist="${gfswgnedir} $myarch"                   ;#fcst data directories, can be different
export complist="$chost  $chost "                         ;#computer names, can be different if passwordless ftp works 
export cyclist="00 12"                                    ;#forecast cycles for making QPF maps, 00Z and/or 12Z 
export DATEST=20130601                                    ;#forecast starting date to show on map
export DATEND=20130630                                    ;#forecast ending date to show on map
export rundir=$tmpdir/plot_pcp
export scrdir=${vsdbhome}/precip                  
                                                                                                                           
export listvar1=expnlist,expdlist,complist,cyclist,DATEST,DATEND,rundir,scrdir
export listvar2=doftp,webhost,webhostid,ftpdir,scppgb,gstat,NWPROD,mapdir,GRADSBIN
export listvar3=vsdbhome,SUBJOB,ACCOUNT,GROUP,CUE2RUN,CUE2FTP
export listvar="$listvar1,$listvar2,$listvar3"

if [ $batch = YES ]; then
  $SUBJOB -e $listvar -a $ACCOUNT  -q $CUE2RUN -g $GROUP -p 1/1/S -r 2048/1 -t 01:00:00  \
    -j plot_pcp -o $tmpdir/plot_pcp.out ${scrdir}/plot_pcp.sh
else
    ${scrdir}/plot_pcp.sh 1>${tmpdir}/plot_pcp.out 2>&1 
fi
### --------------------------------------------------------------
      fi
### --------------------------------------------------------------
                                                                                                                           

### --------------------------------------------------------------
###   make fit-to-obs plots
      if [ $FIT2OBS = YES ] ; then
### --------------------------------------------------------------
export expnlist="fnl prt1534"                              ;#experiment names, only two allowed, fnl is operatinal GFS
export expdlist="$gfsfitdir $myarch1"                    ;#fcst data directories, can be different
export complist="$chost  $chost "                         ;#computer names, can be different if passwordless ftp works
export endianlist="little little"           ;#big_endian or little_endian of fits data, CCS-big, Zeus-little
export cycle="00"                                         ;#forecast cycle to verify, only one cycle allowed
export oinc_f2o=24                                         ;#increment (hours) between observation verify times for timeout plots
export finc_f2o=12                                         ;#increment (hours) between forecast lengths for timeout plots
export fmax_f2o=120                                       ;#max forecast length to show for timeout plots
export DATEST=20131120                                    ;#forecast starting date to show on map
export DATEND=20131211                                    ;#forecast ending date to show on map
export rundir=$tmpdir/fit
export scrdir=${vsdbhome}/fit2obs

 ${scrdir}/fit2obs.sh 1>${tmpdir}/fit2obs.out 2>&1 
### --------------------------------------------------------------
      fi
### --------------------------------------------------------------


### --------------------------------------------------------------
###   make maps of lat-lon distributions and zonal-mean cross-sections
      if [ $MAPS2D = YES ] ; then
### --------------------------------------------------------------
export expnlist="cntl pre13j"        ;#experiments, up to 8; gfs will point to ops data
export expdlist="$myarch  $myarch"   ;#fcst data directories, can be different
export complist="$chost  $chost "    ;#computer names, can be different if passwordless ftp works 
export dumplist=".gfs. .gfs."        ;#file format pgb${asub}${fhr}${dump}${yyyymmdd}${cyc}

export fdlist="anl 1 5 10"            ;#fcst day to verify, e.g., d-5 uses f120 f114 f108 and f102; anl-->analysis; -1->skip
                                      #note: these maps take a long time to make. be patient or set fewer cases
#export fhlist1="f06 f06 f18 f18"     ;#may specify exact fcst hours to compare for a specific day, must be four
#export fhlist5="f120 f120 f120 f120" ;#may specify exact fcst hours to compare for a specific day, must be four
export cycle="00"                     ;#forecast cycle to verify, given only one
export DATEST=20100701                ;#starting verifying date
export ndays=31                       ;#number of days (cases)

export nlev=26                        ;#pgb file vertical layers
export grid=G2                        ;#pgb file resolution, G2-> 2.5deg;   G3-> 1deg
export pbtm=1000                      ;#bottom pressure for zonal mean maps
export ptop=1                         ;#top pressure for zonal mean maps
export latlon="-90 90 0 360"          ;#map area lat1, lat2, lon1 and lon2
export rundir=$tmpdir/2dmaps

export listvara=machine,gstat,expnlist,expdlist,complist,dumplist,cycle,DATEST,ndays,nlev,grid,pbtm,ptop,latlon
export listvarb=rundir,mapdir,obdata,webhost,webhostid,ftpdir,doftp,NWPROD,APRUN,vsdbhome,GRADSBIN
export listvarc=SUBJOB,ACCOUNT,GROUP,CUE2RUN,CUE2FTP

export odir=0
for fcstday in $fdlist ; do
 export odir=`expr $odir + 1 `
 export fcst_day=$fcstday
 export listvar=$listvara,$listvarb,$listvarc,odir,fcst_day,fhlist$fcst_day
 if [ $batch = YES ]; then
  $SUBJOB -e $listvar -a $ACCOUNT  -q $CUE2RUN -g $GROUP -p 1/1/N -r 4096/1 -t 6:00:00 \
     -j map2d$odir -o $tmpdir/2dmaps${odir}.out  ${vsdbhome}/plot2d/maps2d_new.sh
 else
  ${vsdbhome}/plot2d/maps2d_new.sh  1>${tmpdir}/2dmaps${odir}.out 2>&1 &
 fi
done
### --------------------------------------------------------------
      fi                                       
### --------------------------------------------------------------

exit

