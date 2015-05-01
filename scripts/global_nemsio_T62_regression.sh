#!/bin/sh

set -x

. $(awk '{ print $1 }' regression_var.out)

if [ "$machine" = "Zeus" -o "$machine" = "Theia" ]; then

   # Submit jobs using sub_zeus wrapper.
   if [ "$debug" = ".false." ]; then
      /bin/sh sub_zeus -j $global_nemsio_T62_updat_exp1 -t 0:15:00 -p 6/6/0 $scripts/global_nemsio_T62.sh

      while [[ $(grep -c '+ rc=0' ${global_nemsio_T62_updat_exp1}.out) -ne 1 ]]; do
         grep '+ rc=' ${global_nemsio_T62_updat_exp1}.out > return_code_global_nemsio_3dvar.out
         if [ -s return_code_global_nemsio_3dvar.out ]; then
            if [[ $(stat -c %s return_code_global_nemsio_3dvar.out) -ne '0' ]]; then
               if [[ $(awk '{ print $2 }' return_code_global_nemsio_3dvar.out) -ne 'rc=0' ]]; then
                  echo $global_nemsio_T62_updat_exp1" job has failed with return code of "$(awk '{ print $2 }' return_code_global_nemsio_3dvar.out)"."
                  rm -f return_code_global_nemsio_3dvar.out
                  exit
               fi
            fi
         fi
         echo "Job "$global_nemsio_T62_updat_exp1" is not complete yet.  Will recheck in a minute."
         sleep 60
      done

      rm -f return_code_global_nemsio_3dvar.out

      /bin/sh sub_zeus -j $global_nemsio_T62_updat_exp2 -t 0:12:00 -p 8/8/0 $scripts/global_nemsio_T62.sh

      while [[ $(grep -c '+ rc=0' ${global_nemsio_T62_updat_exp2}.out) -ne 1 ]]; do
         grep '+ rc=' ${global_nemsio_T62_updat_exp2}.out > return_code_global_nemsio_3dvar.out
         if [ -s return_code_global_nemsio_3dvar.out ]; then
            if [[ $(stat -c %s return_code_global_nemsio_3dvar.out) -ne '0' ]]; then
               if [[ $(awk '{ print $2 }' return_code_global_nemsio_3dvar.out) -ne 'rc=0' ]]; then
                  echo $global_nemsio_T62_updat_exp2" job has failed with return code of "$(awk '{ print $2 }' return_code_global_nemsio_3dvar.out)"."
                  rm -f return_code_global_nemsio_3dvar.out
                  exit
               fi
            fi
         fi
         echo "Job "$global_nemsio_T62_updat_exp2" is not complete yet.  Will recheck in a minute."
         sleep 60
      done

      rm -f return_code_global_nemsio_3dvar.out

      /bin/sh sub_zeus -j $global_nemsio_T62_contrl_exp1 -t 0:15:00 -p 6/6/0 $scripts/global_nemsio_T62.sh

      while [[ $(grep -c '+ rc=0' ${global_nemsio_T62_contrl_exp1}.out) -ne 1 ]]; do
         grep '+ rc=' ${global_nemsio_T62_contrl_exp1}.out > return_code_global_nemsio_3dvar.out
         if [ -s return_code_global_nemsio_3dvar.out ]; then
            if [[ $(stat -c %s return_code_global_nemsio_3dvar.out) -ne '0' ]]; then
               if [[ $(awk '{ print $2 }' return_code_global_nemsio_3dvar.out) -ne 'rc=0' ]]; then
                  echo $global_nemsio_T62_contrl_exp1" job has failed with return code of "$(awk '{ print $2 }' return_code_global_nemsio_3dvar.out)"."
                  rm -f return_code_global_nemsio_3dvar.out
                  exit
               fi
            fi
         fi
         echo "Job "$global_nemsio_T62_contrl_exp1" is not complete yet.  Will recheck in a minute."
         sleep 60
      done

      rm -f return_code_global_nemsio_3dvar.out

      /bin/sh sub_zeus -j $global_nemsio_T62_contrl_exp2 -t 0:12:00 -p 8/8/0 $scripts/global_nemsio_T62.sh

      while [[ $(grep -c '+ rc=0' ${global_nemsio_T62_contrl_exp2}.out) -ne 1 ]]; do
         grep '+ rc=' ${global_nemsio_T62_contrl_exp2}.out > return_code_global_nemsio_3dvar.out
         if [ -s return_code_global_nemsio_3dvar.out ]; then
            if [[ $(stat -c %s return_code_global_nemsio_3dvar.out) -ne '0' ]]; then
               if [[ $(awk '{ print $2 }' return_code_global_nemsio_3dvar.out) -ne 'rc=0' ]]; then
                  echo $global_nemsio_T62_contrl_exp2" job has failed with return code of "$(awk '{ print $2 }' return_code_global_nemsio_3dvar.out)"."
                  rm -f return_code_global_nemsio_3dvar.out
                  exit
               fi
            fi
         fi
         echo "Job "$global_nemsio_T62_contrl_exp2" is not complete yet.  Will recheck in a minute."
         sleep 60
      done

      rm -f return_code_global_nemsio_3dvar.out

      /bin/sh $scripts/regression_test.sh $global_nemsio_T62_updat_exp1 $global_nemsio_T62_updat_exp2 $global_nemsio_T62_contrl_exp1 $global_nemsio_T62_contrl_exp2 nemsio_tmp62 $global_nemsio_regression 10 8 4

      rm -f global_nemsio_T62.out

      exit

   elif [ "$debug" = .true. ]; then
      /bin/sh sub_zeus -j $global_nemsio_T62_updat_exp1 -p 6/6/ -t 0:35:00 $scripts/global_nemsio_T62.sh

      rm -f global_nemsio_T62.out

      exit
   fi

   exit

elif [[ "$machine" = "WCOSS" ]]; then

   # Submit jobs using sub wrapper.
   if [ "$debug" = ".false." ]; then
      /bin/sh sub_wcoss -a GDAS-T2O -j $global_nemsio_T62_updat_exp1 -q $queue -p 16/2/ -r /1 -t 0:25:00 $scripts/global_nemsio_T62.sh

      while [[ $(grep -c '+ rc=0' ${global_nemsio_T62_updat_exp1}.out) -ne 1 ]]; do
         grep '+ rc=' ${global_nemsio_T62_updat_exp1}.out > return_code_global_nemsio_3dvar.out
         if [ -s return_code_global_nemsio_3dvar.out ]; then
            if [[ $(stat -c %s return_code_global_nemsio_3dvar.out) -ne '0' ]]; then
               if [[ $(awk '{ print $2 }' return_code_global_nemsio_3dvar.out) -ne 'rc=0' ]]; then
                  echo $global_nemsio_T62_updat_exp1" job has failed with return code of "$(awk '{ print $2 }' return_code_global_nemsio_3dvar.out)"."
                  rm -f return_code_global_nemsio_3dvar.out
                  exit
               fi
            fi
         fi
         echo "Job "$global_nemsio_T62_updat_exp1" is not complete yet.  Will recheck in a minute."
         sleep 60
      done

      while [[ $(grep -c 'Resource usage summary:' ${global_nemsio_T62_updat_exp1}.out) -ne 1 ]]; do
         echo "Job "$global_nemsio_T62_updat_exp1" is not complete yet.  Will recheck in a minute."
         sleep 60
      done

      rm -f return_code_global_nemsio_3dvar.out
      /bin/sh sub_wcoss -a GDAS-T2O -j $global_nemsio_T62_updat_exp2 -q $queue -p 16/4/ -r /2 -t 0:15:00 $scripts/global_nemsio_T62.sh

      while [[ $(grep -c '+ rc=0' ${global_nemsio_T62_updat_exp2}.out) -ne 1 ]]; do
         grep '+ rc=' ${global_nemsio_T62_updat_exp2}.out > return_code_global_nemsio_3dvar.out
         if [ -s return_code_global_nemsio_3dvar.out ]; then
            if [[ $(stat -c %s return_code_global_nemsio_3dvar.out) -ne '0' ]]; then
               if [[ $(awk '{ print $2 }' return_code_global_nemsio_3dvar.out) -ne 'rc=0' ]]; then
                  echo $global_nemsio_T62_updat_exp2" job has failed with return code of "$(awk '{ print $2 }' return_code_global_nemsio_3dvar.out)"."
                  rm -f return_code_global_nemsio_3dvar.out
                  exit
               fi
            fi
         fi
         echo "Job "$global_nemsio_T62_updat_exp2" is not complete yet.  Will recheck in a minute."
         sleep 60
      done

      while [[ $(grep -c 'Resource usage summary:' ${global_nemsio_T62_updat_exp2}.out) -ne 1 ]]; do
         echo "Job "$global_nemsio_T62_updat_exp2" is not complete yet.  Will recheck in a minute."
         sleep 60
      done

      rm -f return_code_global_nemsio_3dvar.out
      /bin/sh sub_wcoss -a GDAS-T2O -j $global_nemsio_T62_contrl_exp1 -q $queue -p 16/2/ -r /1 -t 0:25:00 $scripts/global_nemsio_T62.sh

      while [[ $(grep -c '+ rc=0' ${global_nemsio_T62_contrl_exp1}.out) -ne 1 ]]; do
         grep '+ rc=' ${global_nemsio_T62_contrl_exp1}.out > return_code_global_nemsio_3dvar.out
         if [ -s return_code_global_nemsio_3dvar.out ]; then
            if [[ $(stat -c %s return_code_global_nemsio_3dvar.out) -ne '0' ]]; then
               if [[ $(awk '{ print $2 }' return_code_global_nemsio_3dvar.out) -ne 'rc=0' ]]; then
                  echo $global_nemsio_T62_contrl_exp1" job has failed with return code of "$(awk '{ print $2 }' return_code_global_nemsio_3dvar.out)"."
                  rm -f return_code_global_nemsio_3dvar.out
                  exit
               fi
            fi
         fi
         echo "Job "$global_nemsio_T62_contrl_exp1" is not complete yet.  Will recheck in a minute."
         sleep 60
      done

      while [[ $(grep -c 'Resource usage summary:' ${global_nemsio_T62_contrl_exp1}.out) -ne 1 ]]; do
         echo "Job "$global_nemsio_T62_contrl_exp1" is not complete yet.  Will recheck in a minute."
         sleep 60
      done

      rm -f return_code_global_nemsio_3dvar.out
      /bin/sh sub_wcoss -a GDAS-T2O -j $global_nemsio_T62_contrl_exp2 -q $queue -p 16/4/ -r /2 -t 0:15:00 $scripts/global_nemsio_T62.sh

      while [[ $(grep -c '+ rc=0' ${global_nemsio_T62_contrl_exp2}.out) -ne 1 ]]; do
         grep '+ rc=' ${global_nemsio_T62_contrl_exp2}.out > return_code_global_nemsio_3dvar.out
         if [ -s return_code_global_nemsio_3dvar.out ]; then
            if [[ $(stat -c %s return_code_global_nemsio_3dvar.out) -ne '0' ]]; then
               if [[ $(awk '{ print $2 }' return_code_global_nemsio_3dvar.out) -ne 'rc=0' ]]; then
                  echo $global_nemsio_T62_contrl_exp2" job has failed with return code of "$(awk '{ print $2 }' return_code_global_nemsio_3dvar.out)"."
                  rm -f return_code_global_nemsio_3dvar.out
                  exit
               fi
            fi
         fi
         echo "Job "$global_nemsio_T62_contrl_exp2" is not complete yet.  Will recheck in a minute."
         sleep 60
      done

      while [[ $(grep -c 'Resource usage summary:' ${global_nemsio_T62_contrl_exp2}.out) -ne 1 ]]; do
         echo "Job "$global_nemsio_T62_contrl_exp2" is not complete yet.  Will recheck in a minute."
         sleep 60
      done

      rm -f return_code_global_nemsio_3dvar.out
      /bin/sh $scripts/regression_test.sh $global_nemsio_T62_updat_exp1 $global_nemsio_T62_updat_exp2 $global_nemsio_T62_contrl_exp1 $global_nemsio_T62_contrl_exp2 nemsio_tmp62 $global_nemsio_regression 10 8 4

      rm -f global_nemsio_T62.out

      exit

   elif [ "$debug" = .true. ]; then
      /bin/sh sub_wcoss -a GDAS-T2O -j $global_nemsio_T62_updat_exp1 -q $queue -p 16/2/ -t 0:35:00 $scripts/global_nemsio_T62.sh

      rm -f global_nemsio_T62.out

      exit
   fi

   exit

fi