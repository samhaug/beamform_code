#!/bin/bash

dep_met=$(saclst evdp f data/A* | head -n1 | awk '{print $2}')
dep_km=$( echo "$dep_met/1000" | bc -l )
printf "Earthquake %8.2f km deep\n" "$dep_km"

seq 50 0.5 90 > degrees.dat
taup_time -mod prem -ph P -h $dep_km --time -o time < degrees.dat > /dev/null
cat time.gmt | awk 'NR%2==1' > time.dat
rm time.gmt
paste degrees.dat time.dat > time_lookup.dat
rm time.dat
rm degrees.dat


echo "Made lookup table time_lookup.dat"
