#!/bin/bash

if [ $# != 0 ]; then
   echo "Finds temporal, incidence angle, and baz bounds for P wave arriaval"
   echo "and normalizes on maximum within these bounds. Does this automatically"
   echo "for each filtered beamfile."
   echo "USAGE: ./normalize_beam_on_P_filter.sh"
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

#Find temporal, baz, and incidence angle boundaries

#echo "evdp: " $evdp
#echo "gcarc: " $gcarc
P_inc=$(taup_time -mod prem -deg $gcarc -ph P -h $evdp | tail -n2 | head -n1 | awk '{print $7}')
i_min=$((${P_inc%.*}-3))
i_max=$((${P_inc%.*}+3))

P_time=$(taup_time -mod prem -h $evdp -deg $gcarc -ph P --time | awk '{print $1}')
#Account for trace starting at 400 seconds after earthquake
t_min=$((${P_time%.*}-15-400))
t_max=$((${P_time%.*}+15-400))

b_min=$((${baz%.*}-4))
b_max=$((${baz%.*}+4))

#echo "xh_beamnorm $1 $2 $t_min $t_max $i_min $i_max $b_min $b_max"

#xh_beamnorm subarray_*_f1.beam f1_norm.beam $t_min $t_max $i_min $i_max $b_min $b_max
#xh_beamnorm subarray_*_f2.beam f2_norm.beam $t_min $t_max $i_min $i_max $b_min $b_max
#xh_beamnorm subarray_*_f3.beam f3_norm.beam $t_min $t_max $i_min $i_max $b_min $b_max
#xh_beamnorm subarray_*_f4.beam f4_norm.beam $t_min $t_max $i_min $i_max $b_min $b_max

xh_beamnorm fuck.beam fuck_norm.beam $t_min $t_max $i_min $i_max $b_min $b_max
#xh_beamnorm fuck_slow.beam fuck_slow_norm.beam $t_min $t_max $i_min $i_max $b_min $b_max

