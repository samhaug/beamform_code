#!/bin/bash

if [ $# != 1 ]; then
   echo "USAGE weight_all.sh ref_dist"
   exit
fi

if [ ! -d SUBARRAY_* ]; then echo "Must have at least one SUBARRAY_X directory"; exit; fi

for i in SUBARRAY_*; do 
    echo "Weighting " $i
    cd $i
    xh_weight z.xh zw.xh $1 > /dev/null
    xh_weight n.xh nw.xh $1 > /dev/null
    xh_weight e.xh ew.xh $1 > /dev/null
    cd ..
done

