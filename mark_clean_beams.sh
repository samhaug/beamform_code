#!/bin/bash

# Touch empty file called CLEAN in subarray directory if too many local maxima are found

if [ $# != 1 ]; then
   echo "USAGE mark_clean_beams.sh NUMBER"
   echo "touch empty file called CLEAN if number of lines in beammax file is less than NUMBER"
   echo "Good for marking junk beamforms"
   exit
fi

for d in Event*/SUBARRAY*; do
    cd $d
    lines=$(wc -l beammax | awk '{print $1}')
    if (( $lines < $1 )); then
        touch CLEAN
        echo $d "CLEAN" $lines
    else
        echo $d "DIRTY" $lines
    fi
    cd ../../
done



