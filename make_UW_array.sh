#!/bin/bash

for d in Event*; do
    cd $d
    iak=$(grep ' UW ' coords.txt | wc -l | awk '{print $1}')
    if (( $iak < 15 )); then
        echo $d $iak not enough stations for UW subarray
        cd ..
        continue
    else
        mkdir SUBARRAY_UW
        grep ' UW ' coords.txt > SUBARRAY_UW/subarray_UW.txt
        cat z_comp/UW*xh > SUBARRAY_UW/z.xh
        cat n_comp/UW*xh > SUBARRAY_UW/n.xh
        cat e_comp/UW*xh > SUBARRAY_UW/e.xh
        cd ..
    fi
done
