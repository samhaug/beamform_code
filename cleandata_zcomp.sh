#!/bin/bash

if [ ! -e xh/z_f1.xh ]; then
   echo "Can't find filtered xh files in directory xh/ " 
   echo "execute bpfilter_zcomp.sh first"
   exit
fi

if [ ! -e time_lookup.dat ]; then
   echo "Can't find time_lookup.dat. Make with ./make_lookup.sh"
   exit
fi

for i in $(seq 1 1 4); do

    xh_cleandata xh/z_f${i}.xh xh/z_f${i}_clean.xh time_lookup.dat 3

    xh_shorthead xh/z_f${i}_clean.xh | awk '{print $8,$9,$3,$4}' > f${i}_coords.txt

done
