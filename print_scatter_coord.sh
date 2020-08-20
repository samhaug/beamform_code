#!/bin/bash

#Use this script to remove scatter files where no conversion matches observed traveltime

if [ $# != 1 ]; then
  echo "USAGE: print_scatter_coord.sh maxfile"
  echo "Produce coordinates and depth of scatterers by locating the minimum time value in each"
  echo "   scatter file. Must be executed in the directory created by parallel_scatter_locate.sh"
  echo ""
  echo "   maxfile: Local maxima of BEAMFILE computed with xh_beammax"
  echo "   OUTPUT: Two files of format lon/lat/depth for SP and PP locations"
  exit
fi

if [ ! -f scatter_?.dat ]; then
  echo " Cannot find any scatter_?.dat file"
  echo "   Make sure you are in the directory created by parallel_scatter_locate.sh"
  exit
fi

if [ ! -f ../describe ]; then 
  echo " Cannot find a describe file in the parent directory"
  exit
fi

if [ -f PP_locations.dat ]; then 
   rm PP_locations.dat
fi
if [ -f SP_locations.dat ]; then 
   rm SP_locations.dat
fi

alat=$(grep array_centroid_lat ../describe | awk '{print $2}')
alon=$(grep array_centroid_lon ../describe | awk '{print $2}')

for i in scatter*dat; do
    line=$(echo $i | sed 's/[^0-9]*//g')
    #Get first element of line and set to back azimuth
    full=($(sed "${line}q;d" $1))
    baz=${full[0]}

    t=$(awk 'BEGIN{g=0;d=0;j=10} {if ($5<j) {g=$1;d=$3;j=$5}} END{print j}' $i)
    gcarc=$(awk 'BEGIN{g=0;d=0;j=10} {if ($5<j) {g=$1;d=$3;j=$5}} END{print g}' $i)
    depth=$(awk 'BEGIN{g=0;d=0;j=10} {if ($5<j) {g=$1;d=$3;j=$5}} END{print d}' $i)
    latlon=$(vincenty_direct $alat $alon $baz $gcarc | awk '{print $2,$1}')
    if [ $gcarc == 0 ]; then
       gcarc=$(awk 'BEGIN{g=0;d=0;j=10} {if ($6<j) {g=$1;d=$3;j=$5}} END{print g}' $i)
       depth=$(awk 'BEGIN{g=0;d=0;j=10} {if ($6<j) {g=$1;d=$3;j=$5}} END{print d}' $i)
       latlon=$(vincenty_direct $alat $alon $baz $gcarc | awk '{print $2,$1}')
       echo $latlon $depth >> SP_locations.dat
    else
       echo $latlon $depth >> PP_locations.dat
    fi
    

done

