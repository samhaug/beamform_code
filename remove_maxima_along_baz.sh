#!/bin/bash

if [ $# != 3 ]; then
   echo "Creates new beammax file without including maxima that arrive += D degrees"
   echo "  from EQ/array baz"
   echo "USAGE: remove_maxima_along_baz BEAMMAX_IN BEAMMAX_OUT D"
   echo "BEAMMAX_IN is computed by find_beammax.sh "
   echo "BEAMFILE_OUT will be created"
   echo "D (int): Exclude maxima from BEAMMAX_IN that are within += D degrees of EQ/array backazimuth"
   exit
fi

if [ -e $2 ]; then
   echo "File $2 exists. Removing it"
   rm $2
fi

cwd=$(pwd)
alat=$(grep array_centroid_lat $cwd/describe | awk '{print $2}')
alon=$(grep array_centroid_lon $cwd/describe | awk '{print $2}')
elat=$(grep event_lat $cwd/describe | awk '{print $2}')
elon=$(grep event_lon $cwd/describe | awk '{print $2}')
gcarc=$(vincenty_inverse $elat $elon $alat $alon | awk '{print $3}')
evdp=$(grep event_depth $cwd/describe | awk '{print $2}')

baz1=$(vincenty_inverse $elat $elon $alat $alon | awk '{print $2}')
ibaz=${baz1%.*}
echo 'BAZ=' $ibaz

while read baz inc time amp; do
    if (( ( $baz > $(($ibaz-$3)) ) && ($baz < $(($ibaz+$3)) ) )); then 
       continue 
    else 
       echo $baz $inc $time $amp >> $2
    fi
done < $1



