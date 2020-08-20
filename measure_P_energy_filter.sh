#!/bin/bash

if [ $# != 0 ]; then
   echo "Measures P-wave beam energy as a function of baz. Automatically determines inc and "
   echo "and temporal boundaries. Does this for each frequency band"
   echo "USAGE: ./measure_P_energy_filter.sh "
   exit
fi

if [ ! -e f1_norm.beam ]; then
   echo "Cannot find f1_norm.beam in this directory. Make sure all four of these beamfiles"
   echo "exist in this directory."
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

#Find temporal boundaries of P

P_time=$(taup_time -mod prem -h $evdp -deg $gcarc -ph P --time | awk '{print $1}') 
P_inc=$(taup_time -mod prem -h $evdp -deg $gcarc -ph P | tail -n2 | head -n1 | awk '{print $7}')

# Account for trace starting at 400 seconds
t_min=$((${P_time%.*}-10-400))
t_max=$((${P_time%.*}+10-400))

i_min=$((${P_inc%.*}-2))
i_max=$((${P_inc%.*}+2))

#echo "xh_beamenergy $1 $t_min $t_max $i_min $i_max > P_energy.dat"

echo "Measuring f1 P energy"
xh_beamenergy f1_norm.beam $t_min $t_max $i_min $i_max > f1_P_energy.dat
echo "Measuring f2 P energy"
xh_beamenergy f2_norm.beam $t_min $t_max $i_min $i_max > f2_P_energy.dat
echo "Measuring f3 P energy"
xh_beamenergy f3_norm.beam $t_min $t_max $i_min $i_max > f3_P_energy.dat
echo "Measuring f4 P energy"
xh_beamenergy f4_norm.beam $t_min $t_max $i_min $i_max > f4_P_energy.dat




