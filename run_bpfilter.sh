#!/bin/bash

if [ ! -e SUBARRAY_1 ]; then
    echo "Needs at least one SUBARRAY_* directory"
    echo "run organize_subarrays.sh in this directory first"
    exit
fi

for d in SUBARRAY*; do
    echo "Filtering $d"
    (cd $d && ~/src/beamform_code/bpfilter.sh)
    (cd $d && mkdir xh)
    (cd $d && mv *.xh xh)
done
