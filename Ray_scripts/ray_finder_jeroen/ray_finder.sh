#!/bin/bash
table=./Table_D_theta_t
libray=./lib_raypaths

if [ ! -e describe ]; then
   echo "making new describe"
   xh_beamdescribe f1_norm.beam > describe
fi

evla=$(grep event_lat describe | cut -d" " -f2)
evlo=$(grep event_lon describe | cut -d" " -f2)
stla=$(grep array_centroid_lat describe | cut -d" " -f2)
stlo=$(grep array_centroid_lon describe | cut -d" " -f2)
evdp=$(grep event_depth describe | cut -d" " -f2)

i=0
# For each potential scattering signal
while read baz inc time amp; do
   i=$((i+1))
   echo $i
   # Find the appropriate line in Table_D_theta_t to determine distance from incidince angle 
   dist=$(awk -v "i=$inc" 'BEGIN{min=100} 
                    {if (sqrt(($2-i)**2)<min)
                       {min=sqrt(($2-i)**2);dist=$1}}
                    END{printf "%2.1f", dist}' $table)

   # calculate the coordinates, depth, and distance to EQ of each point on the 
   # appropriate raypath. use every second line to save time. put them in a temporary file 
   raypath_point_coords $libray/Ray_h0_D${dist} $evla $evlo $stla $stlo $baz | \
            awk 'NR % 2 == 0'  > ray.tmp
   # Now use taup to find if there is a connecting raypath between each point and the EQ.
   while read g d lat lon t1; do 
      t2=$(taup_time -mod prem -h $evdp -ph P,p --stadepth $d -deg $g --time)
      # if the t2 variable is empty, there is no connecting path.
      if [ -z $t2 ]; then break; fi
      #add up the travel times of branch 1 and 2 and calculate the abs of the difference between
      #this time and the observed time.
      t_diff=$(echo "sqrt((($t2+$t1)-$time)^2)" | bc -l)
      printf -v t_diff "%4.1f" $t_diff
      # if the algorithm finds a time that is close enough (within 3 seconds), mark location
      if (( $(echo "$t_diff < 3.0" |bc -l)  )); then
         printf "%8.2f %8.2f %8.2f %8.2f %8.2f %8.2f\n" $baz $inc $time $lat $lon $d && break
      # if the time difference anywhere on the ray branch is too large (> 500s), there's not likely a match
      # anywhere on the ray branch so don't waste time on it.
      elif (( $(echo "$t_diff > 500.0" | bc -l) )) ; then
         break
      fi
   done < ray.tmp
done < potential_scatterers.dat




