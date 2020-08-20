#!/bin/bash

for d in Event*; do
    cd $d
    iak=$(grep ' TA ' coords.txt | wc -l | awk '{print $1}')
    if (( $iak < 15 )); then
        echo $d $iak not enough stations for TA subarray
        cd ..
        continue
    else
        mkdir SUBARRAY_TA
        grep ' TA ' coords.txt > SUBARRAY_TA/subarray_TA.txt
        cat z_comp/TA*xh > SUBARRAY_TA/z.xh
        cat n_comp/TA*xh > SUBARRAY_TA/n.xh
        cat e_comp/TA*xh > SUBARRAY_TA/e.xh
    fi
    cd ..
done
