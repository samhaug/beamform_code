#!/bin/bash 

dg=0.5

#-- source depth
h=0
#h=120

for deg in $(seq 30 0.5 98); do
   echo Degree: $deg
   #-- calculate path + traveltime along path
   #-- use ak135_jr which has mini-discontinuities every 10 km or so
   taup_path -mod prem -h $h -ph P -o out -deg $deg --withtime
   # grep the first ray from the output (multiple rays are very similar)
   ./grep_first_ray < out.gmt > lib_raypaths/"Ray_h${h}_D${deg}"
done

 

