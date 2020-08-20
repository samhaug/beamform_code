#!/bin/bash

for d in Event_20*/SUB*; do 
    if [ -e $d/CLEAN ]; then 
        echo $d
        (cd ${d}/scatter && ~/src/beamform_code/remove_blanks.sh 10 ); 
    fi; 
done

