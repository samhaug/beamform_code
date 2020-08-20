#!/bin/bash

if [ $# != 0 ]; then
   echo "Finds local maxima in beamform object. Automatically determines waterlevel"
   echo "and temporal boundaries. Does this for each normalized filtered beam file"
   echo "USAGE: ./find_beammax.sh "
   exit
fi

if [ ! -e f1_norm.beam ]; then
   echo "Cannot find f1_norm.beam. Execute this script in the same directory"
   echo 'as f{1,2,3,4}_norm.beam'
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
t_min=$((${P_time%.*}+20-400))
t_max=$((${PP_time%.*}-10-400))

# Use the following three lines for non-normalized beamforms. 
# Reccomended to normalize on P
#root_max=$(grep dat2 $cwd/describe | awk '{print $4}')
#max_lvl=$(echo "$root_max*0.20" | bc -l)
#w_lvl=$(echo "$root_max*0.02" | bc -l)

# These levels should be appropriate for normalized beamforms.
max_lvl=0.30
w_lvl=0.10

#echo "xh_beammax $1 $w_lvl $max_lvl $t_min $t_max 5 30 > beammax"

xh_beammax f1_norm.beam $w_lvl $max_lvl $t_min $t_max 0 20 > f1_beammax
xh_beammax f2_norm.beam $w_lvl $max_lvl $t_min $t_max 0 20 > f2_beammax
xh_beammax f3_norm.beam $w_lvl $max_lvl $t_min $t_max 0 20 > f3_beammax
xh_beammax f4_norm.beam $w_lvl $max_lvl $t_min $t_max 0 20 > f4_beammax

