#!/bin/bash

for d in Event*; do
    cd $d
    ici=$(grep ' CI ' coords.txt | wc -l | awk '{print $1}')
    if (( $ici < 15 )); then
        echo $d: $ici not enough stations for CI subarray
        cd ..
        continue
    else
        mkdir SUBARRAY_CI
        grep ' CI ' coords.txt > SUBARRAY_CI/subarray_CI.txt
        cat z_comp/CI*xh > SUBARRAY_CI/z.xh
        cat n_comp/CI*xh > SUBARRAY_CI/n.xh
        cat e_comp/CI*xh > SUBARRAY_CI/e.xh
    fi
    cd ..
done
