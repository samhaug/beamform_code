#!/bin/bash

if [ $# != 0 ]; then
   echo "Measures scattered beam energy as a function of baz. Determines baz, inc"
   echo "and temporal boundaries from beammax file. Automatically does this for"
   echo "each frequency band beamfile and beammax file"
   echo "USAGE: ./measure_scattered_energy_filter.sh "
   exit
fi

if [ ! -e f1_norm.beam ]; then
   echo " Cannot find f1_norm.beam. Make sure all of the freuqnecy band files exist"
   exit
fi

if [ ! -e f1_beammax_P_ray ]; then
   echo " Cannot find f1_beammax_P_ray. Make sure all of the frequecy band files exist"
   exit
fi

cwd=$(pwd)
alat=$(grep array_centroid_lat $cwd/describe | awk '{print $2}')
alon=$(grep array_centroid_lon $cwd/describe | awk '{print $2}')
elat=$(grep event_lat $cwd/describe | awk '{print $2}')
elon=$(grep event_lon $cwd/describe | awk '{print $2}')
baz=$(vincenty_inverse $elat $elon $alat $alon | awk '{print $2}')
gcarc=$(vincenty_inverse $elat $elon $alat $alon | awk '{print $3}')
evdp=$(grep event_depth $cwd/describe | awk '{print $2}')


if [ ! -d scatter_energy ]; then
     mkdir scatter_energy
  else
     echo "scatter_energy exists, removing now"
     rm -rf scatter_energy
     mkdir scatter_energy
fi


freq=(f1 f2 f3 f4)
for f in ${freq[@]}; do  
   echo "Finding $f scattered energy"
   i=1
   while read baz inc time amp; do
       #Account for traces starting at 400 seconds after earthquake
       t_min=$((${time%.*}-5-400))
       t_max=$((${time%.*}+5-400))
       i_min=$((${inc%.*}-1))
       i_max=$((${inc%.*}+1))
       echo $baz $inc $time > scatter_energy/energy_${i}_${f}.dat
       xh_beamenergy ${f}_norm.beam $t_min $t_max $i_min $i_max >> scatter_energy/energy_${i}_${f}.dat
       i=$((i+1))
   done < ${f}_beammax_P_ray
done

