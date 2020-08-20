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

if [ ! -e f1_beammax_clean ]; then
   echo " Cannot find f1_beammax_clean. Make sure all of the frequecy band files exist"
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


echo "Finding f1 scattered energy"
i=1
while read baz inc time amp; do
    #Account for traces starting at 400 seconds after earthquake
    t_min=$((${time%.*}-5-400))
    t_max=$((${time%.*}+5-400))
    i_min=$((${inc%.*}-1))
    i_max=$((${inc%.*}+1))
    echo $baz $inc $time > scatter_energy/energy_${i}_f1.dat
    xh_beamenergy f1_norm.beam $t_min $t_max $i_min $i_max >> scatter_energy/energy_${i}_f1.dat
    i=$((i+1))
done < f1_beammax_clean

echo "Finding f2 scattered energy"
i=1
while read baz inc time amp; do
    t_min=$((${time%.*}-5-400))
    t_max=$((${time%.*}+5-400))
    i_min=$((${inc%.*}-1))
    i_max=$((${inc%.*}+1))
    echo $baz $inc $time > scatter_energy/energy_${i}_f2.dat
    xh_beamenergy f2_norm.beam $t_min $t_max $i_min $i_max >> scatter_energy/energy_${i}_f2.dat
    i=$((i+1))
done < f2_beammax_clean

echo "Finding f3 scattered energy"
i=1
while read baz inc time amp; do
    t_min=$((${time%.*}-5-400))
    t_max=$((${time%.*}+5-400))
    i_min=$((${inc%.*}-1))
    i_max=$((${inc%.*}+1))
    echo $baz $inc $time > scatter_energy/energy_${i}_f3.dat
    xh_beamenergy f3_norm.beam $t_min $t_max $i_min $i_max >> scatter_energy/energy_${i}_f3.dat
    i=$((i+1))
done < f3_beammax_clean

echo "Finding f4 scattered energy"
i=1
while read baz inc time amp; do
    t_min=$((${time%.*}-5-400))
    t_max=$((${time%.*}+5-400))
    i_min=$((${inc%.*}-1))
    i_max=$((${inc%.*}+1))
    echo $baz $inc $time > scatter_energy/energy_${i}_f4.dat
    xh_beamenergy f4_norm.beam $t_min $t_max $i_min $i_max >> scatter_energy/energy_${i}_f4.dat
    i=$((i+1))
done < f4_beammax_clean

