#!/bin/bash

if [ $# != 4 ]; then
   echo ""
   echo "USAGE: ./hypothetical_scatter_time.sh XH_IN az gcarc depth"
   echo "Computes the expected P-P travel time for each station in XH_IN"
   echo "   for a hypothetical scattering point az CW from north and gcarc degrees"
   echo "   from the earthquake source."
   echo "OUTPUT: List of traveltimes in order of xh file"
   echo ""
   exit
fi

elatlon=($(xh_shorthead $1 | awk '{print $6,$7}' | head -n1))
evla=${elatlon[0]}
evlo=${elatlon[1]}
xh_shorthead e.xh | awk '{print $8,$9}' > statcoords.tmp

mlatlon=($(vincenty_direct $evla $evlo $2 $3))
mla=${mlatlon[0]}
mlo=${mlatlon[1]}

dist_to_earthquake=$(vincenty_inverse $mla $mlo $evla $evlo | awk '{print $3}')
time_to_earthquake=$(taup_time -mod prem -h $4 -deg $dist_to_earthquake -ph p,P --time)

if [ -z time_to_earthquake ]; then
    echo "No scattering point at this location from earthquake"
    exit
fi

while read stla stlo; do
   dist_to_station=$(vincenty_inverse $mla $mlo $stla $stlo | awk '{print $3}')
   time_to_station=$(taup_time -mod prem -h $4 -deg $dist_to_station -ph p,P --time)
   if [ -z time_to_station ]; then
       echo 0.000
   else
       echo "$time_to_station+$time_to_earthquake" | bc -l
   fi
done < statcoords.tmp

rm statcoords.tmp



