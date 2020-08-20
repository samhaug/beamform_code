#!/bin/bash

if [ $# != 1 ]; then
   echo "Measures P-wave beam energy as a function of baz. Automatically determines inc and "
   echo "and temporal boundaries"
   echo "USAGE: ./measure_P_energy.sh BEAMFILE"
   echo "BEAMFILE is computed by xh_3compbeam. Suggested to use normalized beamfile"
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

t_min=$((${P_time%.*}-10))
t_max=$((${P_time%.*}+10))

i_min=$((${P_inc%.*}-2))
i_max=$((${P_inc%.*}+2))

echo "xh_beamenergy $1 $t_min $t_max $i_min $i_max > P_energy.dat"

xh_beamenergy $1 $t_min $t_max $i_min $i_max > P_energy.dat


