#!/bin/bash

# Organizes subarray xh files from subarray*.txt files

if [ ! -f subarray_1.txt ]; then 
     echo "Must have at least one subarray_?.txt file"
     echo "run subdivide_array.py in this directory first"
     exit
fi

j=0
for i in subarray_*.txt; do
    dirname=SUBARRAY_${i//[!0-9]/}
    mkdir $dirname
    mv $i $dirname
    cd $dirname
    while read lat lon netw stat; do
       cat ../z_comp/*${netw}*${stat}*xh >> z.xh
       cat ../n_comp/*${netw}*${stat}*xh >> n.xh
       cat ../e_comp/*${netw}*${stat}*xh >> e.xh
    done < $i
    cd ..
    
    j=$((j+1))
done
