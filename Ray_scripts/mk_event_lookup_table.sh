#!/bin/bash 
SRC=/home/samhaug/src/beamform_code/Ray_scripts

dg=0.5

#Make lookup table for outgoing rays for a given earthquake. 
#Need to be in the Event_* directory. Looks for a describe file
#within SUBARRAY_1

if [ ! -e SUBARRAY_1/describe ]; then
   echo "Can't find SUBARRAY_1/describe"
   exit
fi

if [ -e source_ray_P.dat ]; then
   rm source_ray_P.dat
fi

if [ -e source_ray_S.dat ]; then
   rm source_ray_S.dat
fi

#-- source depth
h=$(grep depth SUBARRAY_1/describe | cut -d" " -f 2)

for deg in $(seq 30 0.5 98); do
   echo Degree: $deg
   #-- calculate path + traveltime along path
   #-- use ak135_jr which has mini-discontinuities every 10 km or so
   taup_path -mod prem -h $h -ph P -o out_P -deg $deg --withtime
   $SRC/grep_first_ray < out_P.gmt | tail -n +2 >> source_ray_P.dat

   taup_path -mod prem -h $h -ph S -o out_S -deg $deg --withtime
   $SRC/grep_first_ray < out_S.gmt | tail -n +2 >> source_ray_S.dat
done

 
