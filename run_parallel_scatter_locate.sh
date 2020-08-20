#!/bin/bash
for d in */SUBARRAY*; do 
   if [ -e $d/CLEAN ]; then 
       (cd $d && sbatch ~/src/beamform_code/parallel_scatter_locate.sh *.beam beammax)
   fi 
done
