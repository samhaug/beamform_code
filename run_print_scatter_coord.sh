#!/bin/bash

for d in Event_201*/SUB*; do 
    if [ -e $d/CLEAN ]; then 
        echo $d
        (cd ${d}/scatter && ~/src/beamform_code/print_scatter_coord.sh ../beammax ); 
    fi; 
done

