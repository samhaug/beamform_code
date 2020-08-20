#!/bin/bash

if [ $# != 2 ]; then
   echo "Measures scattered beam energy as a function of baz. Determines baz, inc"
   echo "and temporal boundaries from beammax file."
   echo "USAGE: ./measure_scattered_energy.sh BEAMFILE beammax"
   echo "BEAMFILE is computed by xh_3compbeam"
   echo "beammax is computed by find_beammax.sh. It is suggested to remove on-azimuth arrivals"
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


i=1
while read baz inc time amp; do
    t_min=$((${time%.*}-5))
    t_max=$((${time%.*}+5))
    i_min=$((${inc%.*}-1))
    i_max=$((${inc%.*}+1))
    echo "xh_beamenergy $1 $t_min $t_max $i_min $i_max > scatter_energy/energy_${i}.dat"
    echo $baz $inc $time > scatter_energy/energy_${i}.dat
    xh_beamenergy $1 $t_min $t_max $i_min $i_max >> scatter_energy/energy_${i}.dat
    i=$((i+1))
done < $2



