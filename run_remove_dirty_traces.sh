#!/bin/bash

# Remove traces named in dirty_list for each Event directory

for d in Event*; do
    echo $d
    cd $d
    while read name; do rm data/*${name}*; done < dirty_list.txt
    cd ..
done
