#!/bin/bash

# Organizes subarray xh files from subarray*.txt files

if [ ! -f f1_subarray_1.txt ]; then 
     echo "Must have at least one f1_subarray_?.txt file"
     echo "run subdivide_array_zcomp.py in this directory first"
     exit
fi

for i in f*subarray_*.txt; do
    freq=$(echo $i | cut -d"_" -f1)
    num=$(echo $i | cut -d"_" -f3 | cut -d"." -f1)
    dirname=${freq}_SUBARRAY_${num}
    mkdir $dirname
    mv $i $dirname
    cd $dirname
    xh_grepnetstat ../xh/z_${freq}_clean_v.xh z_vel.xh $i
    xh_grepnetstat ../xh/z_${freq}_clean.xh z_disp.xh $i
    cd ..
    
done
