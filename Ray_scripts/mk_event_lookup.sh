#!/bin/bash 
SRC=/home/samhaug/src/beamform_code/Ray_scripts

dg=0.5

if [ ! -e describe ]; then
   echo "can't find describe"
   exit
fi

if [ -e source_ray.dat ]; then
   rm source_ray.dat
fi
#-- source depth
h=$(grep depth describe | cut -d" " -f 2)

for deg in $(seq 30 0.5 98); do
   echo Degree: $deg
   #-- calculate path + traveltime along path
   #-- use ak135_jr which has mini-discontinuities every 10 km or so
   taup_path -mod prem -h $h -ph P -o out_P -deg $deg --withtime
   $SRC/grep_first_ray < out_P.gmt | tail -n +2 >> source_ray_P.dat

   taup_path -mod prem -h $h -ph S -o out_S -deg $deg --withtime
   $SRC/grep_first_ray < out_S.gmt | tail -n +2 >> source_ray_S.dat
done

 
