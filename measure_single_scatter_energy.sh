#!/bin/bash

if [ $# != 2 ]; then
   echo "Measures scattered beam energy as a function of baz. Determines baz, inc"
   echo "and temporal boundaries from beammax file."
   echo "USAGE: ./measure_single_scattered_energy.sh beammax line_no"
   echo "beammax is computed by find_beammax.sh. It is suggested to remove on-azimuth arrivals"
   echo "line_no is the line number of beammax on which to calculate energy"
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

if [ ! -d scatter_energy_single ]; then
   mkdir scatter_energy_single
fi

beammax_file=$1
line=$2
base_freq=$(echo $beammax_file | awk -F"_" '{print $1}')

info=($(sed "${line}q;d" $beammax_file))
baz=${info[0]}
inc=${info[1]}
time=${info[2]}
amp=${info[3]}
# offset 400 seconds to account for starttime of seismogram
t_min=$((${time%.*}-5-400))
t_max=$((${time%.*}+5-400))
i_min=$((${inc%.*}-1))
i_max=$((${inc%.*}+1))

echo $baz $inc $time > scatter_energy_single/energy_norm${base_freq}_f1_${line}.dat
echo $baz $inc $time > scatter_energy_single/energy_norm${base_freq}_f2_${line}.dat
echo $baz $inc $time > scatter_energy_single/energy_norm${base_freq}_f3_${line}.dat
echo $baz $inc $time > scatter_energy_single/energy_norm${base_freq}_f4_${line}.dat

echo "xh_beamenergy f1_norm.beam $t_min $t_max $i_min $i_max > scatter_energy_single/energy_${line}.dat"
xh_beamenergy f1_norm.beam $t_min $t_max $i_min $i_max >> scatter_energy_single/energy_norm${base_freq}_f1_${line}.dat
echo "xh_beamenergy f2_norm.beam $t_min $t_max $i_min $i_max > scatter_energy_single/energy_${line}.dat"
xh_beamenergy f2_norm.beam $t_min $t_max $i_min $i_max >> scatter_energy_single/energy_norm${base_freq}_f2_${line}.dat
echo "xh_beamenergy f3_norm.beam $t_min $t_max $i_min $i_max > scatter_energy_single/energy_${line}.dat"
xh_beamenergy f3_norm.beam $t_min $t_max $i_min $i_max >> scatter_energy_single/energy_norm${base_freq}_f3_${line}.dat
echo "xh_beamenergy f4_norm.beam $t_min $t_max $i_min $i_max > scatter_energy_single/energy_${line}.dat"
xh_beamenergy f4_norm.beam $t_min $t_max $i_min $i_max >> scatter_energy_single/energy_norm${base_freq}_f4_${line}.dat
