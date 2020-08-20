#!/bin/bash

for d in Event*; do
    cd $d
    iak=$(grep ' AK ' coords.txt | wc -l | awk '{print $1}')
    if (( $iak < 15 )); then
        echo $d $iak not enough stations for AK subarray
        cd ..
        continue
    else
        mkdir SUBARRAY_AK
        grep ' AK ' coords.txt > SUBARRAY_AK/subarray_AK.txt
        cat z_comp/AK*xh > SUBARRAY_AK/z.xh
        cat n_comp/AK*xh > SUBARRAY_AK/n.xh
        cat e_comp/AK*xh > SUBARRAY_AK/e.xh
    fi
    cd ..
done
