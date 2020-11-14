#!/bin/bash

if [ ! -d xh ]; then
   echo "Can't find xh file" 
   echo "execute bpfilter_zcomp.sh first"
fi


for i in $(seq 1 1 4); do
    xh_cleandata xh/z_f${i}.xh xh/z_f${i}_clean.xh 3
    xh_shorthead xh/z_f${i}_clean.xh | awk '{print $8,$9,$3,$4}' > f${i}_coords.txt
done
