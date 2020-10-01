#!/bin/bash

if [ $# != 2 ]; then
   echo "Creates new beammax file without including maxima that arrive += D degrees"
   echo "  from EQ/array baz. Does this automatically for each filtered beammax file"
   echo "USAGE: remove_maxima_along_baz Dmin Dmax"
   echo "Dmin (int): Exclude maxima from BEAMMAX_IN that are within += D degrees of EQ/array backazimuth"
   echo "Dmax (int): Exclude maxima from BEAMMAX_IN that are outside += D degrees of EQ/array backazimuth"
   exit
fi


rm *beammax_clean > /dev/null

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
dmin=$1
dmax=$2

if (( $(($dmax+ibaz)) > 365 )); then
   dmax=366
   overflow=$(($dmax+ibaz-365))
   overflowf4=$((25+ibaz-365))
fi

if (( $(($dmax+ibaz)) < 365 )); then
for d in f{1,2,3}*beammax; do 
    touch ${d}_clean
    while read baz inc time amp; do
        if (( ( $baz > $(($ibaz-$dmax)) ) && ($baz < $(($ibaz-$dmin)) ) )); then 
           echo $baz $inc $time $amp >> ${d}_clean
        elif (( ( $baz > $(($ibaz+$dmin)) ) && ($baz < $(($ibaz+$dmax)) ) )); then 
           echo $baz $inc $time $amp >> ${d}_clean
        else
           continue
        fi
    done < $d
done
fi

if (( $(($dmax+ibaz)) > 365 )); then
   for d in f{1,2,3}*beammax; do 
       touch ${d}_clean
       while read baz inc time amp; do
           if (( ( $baz > $(($ibaz-$dmax)) ) && ($baz < $(($ibaz-$dmin)) ) )); then 
             echo $baz $inc $time $amp >> ${d}_clean
           elif (( $baz < $overflow )); then 
              echo $baz $inc $time $amp >> ${d}_clean
           elif (( $baz > $ibaz+$dmin )); then 
              echo $baz $inc $time $amp >> ${d}_clean
           else
              continue
           fi
       done < $d
   done
   for d in f4*beammax; do 
       touch ${d}_clean
       while read baz inc time amp; do
           if (( $baz > $overflowf4 )); then 
              echo $baz $inc $time $amp >> ${d}_clean
           else
              continue
           fi
       done < $d
   done
fi

for d in f4*beammax; do 
    touch ${d}_clean
    while read baz inc time amp; do
        if (( ( $baz > $(($ibaz-$2)) ) && ($baz < $(($ibaz-25)) ) )); then 
           echo $baz $inc $time $amp >> ${d}_clean
        elif (( ( $baz > $(($ibaz+25)) ) && ($baz < $(($ibaz+$2)) ) )); then 
           echo $baz $inc $time $amp >> ${d}_clean
        else
           continue
        fi
    done < $d
done


