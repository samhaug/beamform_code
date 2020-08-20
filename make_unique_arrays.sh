#!/bin/bash

if [ ! -e coords.txt ]; then
   echo "Need coords.txt to parse."
   echo "this script will make a SUBARRAY directory for each unique network code in"
   echo "coords.txt so long as there is at least 15 stations associated with the network"
   exit
fi

for net in $(awk '{print $3}' coords.txt | uniq); do 
    if (( $(grep " $net " coords.txt | wc -l | awk '{print $1}') < 15 )); then
        echo Not enough stations for $net subarray
        continue
    else
        mkdir SUBARRAY_$net
        grep " $net " coords.txt > SUBARRAY_${net}/subarray_${net}.txt
        cat z_comp/${net}*xh > SUBARRAY_${net}/z.xh
        cat n_comp/${net}*xh > SUBARRAY_${net}/n.xh
        cat e_comp/${net}*xh > SUBARRAY_${net}/e.xh
    fi
done
