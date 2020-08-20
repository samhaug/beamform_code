#!/bin/bash

#Use this script to remove scatter files where no conversion matches observed traveltime

if [ $# != 1 ]; then
  echo "USAGE: remove_blanks.sh TIME"
  echo "Removes scatter output files of parallel_scatter_locate.sh or scatter_locate.sh"
  echo "      if minimum value of pp and sp times are less than TIME"
  echo "Execute inside of scatter/ directory created with parallel_scatter_locate.sh"
  exit
fi

for i in scatter*dat; do
    pp_min=$(awk 'BEGIN{j=100} {if ($5<j) j=$5} END{print j}' $i)
    sp_min=$(awk 'BEGIN{j=100} {if ($6<j) j=$6} END{print j}' $i)
    if (( $(echo "$pp_min > $1" | bc -l) && $(echo "$sp_min > $1" | bc -l) )); then
           echo REJECTED: $i $pp_min $sp_min       
           rm $i
    else
           echo ACCEPTED: $i $pp_min $sp_min        
    fi
done

