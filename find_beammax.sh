#!/bin/bash

if [ $# != 1 ]; then
   echo "Finds local maxima in beamform object. Automatically determines waterlevel"
   echo "and temporal boundaries"
   echo "USAGE: ./find_beammax.sh BEAMFILE"
   echo "BEAMFILE is computed by xh_3compbeam"
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

#Find temporal boundaries by sP and PP time

sP_time=$(taup_time -mod prem -h $evdp -deg $gcarc -ph sP --time | awk '{print $1}') 
PP_time=$(taup_time -mod prem -h $evdp -deg $gcarc -ph PP --time | awk '{print $1}') 
P_time=$(taup_time -mod prem -h $evdp -deg $gcarc -ph P --time | awk '{print $1}') 
#Use these for deeper events ~150km
#t_min=$((${sP_time%.*}+50))
#t_max=$((${PP_time%.*}-20))

#Use these for shallow events h < 20km
t_min=$((${P_time%.*}+20))
t_max=$((${PP_time%.*}-10))

# Use the following three lines for non-normalized beamforms. 
# Reccomended to normalize on P
#root_max=$(grep dat2 $cwd/describe | awk '{print $4}')
#max_lvl=$(echo "$root_max*0.20" | bc -l)
#w_lvl=$(echo "$root_max*0.02" | bc -l)

# These levels should be appropriate for normalized beamforms.
max_lvl=0.4
w_lvl=0.06

echo "xh_beammax $1 $w_lvl $max_lvl $t_min $t_max 5 30 > beammax"

xh_beammax $1 $w_lvl $max_lvl $t_min $t_max 0 30 > beammax

