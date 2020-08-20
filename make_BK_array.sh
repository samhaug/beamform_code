#!/bin/bash

for d in Event*; do
    cd $d
    iak=$(grep ' BK ' coords.txt | wc -l | awk '{print $1}')
    if (( $iak < 15 )); then
        echo $d $iak not enough stations for BK subarray
        cd ..
        continue
    else
        mkdir SUBARRAY_BK
        grep ' BK ' coords.txt > SUBARRAY_BK/subarray_BK.txt
        cat z_comp/BK*xh > SUBARRAY_BK/z.xh
        cat n_comp/BK*xh > SUBARRAY_BK/n.xh
        cat e_comp/BK*xh > SUBARRAY_BK/e.xh
    fi
    cd ..
done
