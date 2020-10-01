#!/bin/bash
table=/home/samhaug/src/beamform_code/Ray_scripts/Table_D_theta_t
libray=/home/samhaug/src/beamform_code/Ray_scripts/lib_raypaths

if [ ! -e describe ]; then
   echo "making new describe"
   xh_beamdescribe f1_norm.beam > describe
fi

evla=$(grep event_lat describe | cut -d" " -f2)
evlo=$(grep event_lon describe | cut -d" " -f2)
stla=$(grep array_centroid_lat describe | cut -d" " -f2)
stlo=$(grep array_centroid_lon describe | cut -d" " -f2)
evdp=$(grep event_depth describe | cut -d" " -f2)

cat *_beammax_clean > full_clean
i=0
while read baz inc time amp; do
   i=$((i+1))
   echo $i
   dist=$(awk -v "i=$inc" 'BEGIN{min=100} 
                    {if (sqrt(($2-i)**2)<min)
                       {min=sqrt(($2-i)**2);dist=$1}}
                    END{printf "%2.1f", dist}' $table)

   incoming_ray_coords $libray/Ray_h0_D${dist} $evla $evlo $stla $stlo $baz | \
            awk 'NR % 2 == 0'  > out
   while read g d lat lon t1; do 
      d=$(echo "6371.0-$d" | bc -l)
      t2=$(taup_time -mod prem -h $evdp -ph P,p --stadepth $d -deg $g --time)
      if [ -z $t2 ]; then t2=0; fi
      t_total=$(echo "sqrt((($t2+$t1)-$time)^2)" | bc -l)
      printf -v t_diff "%4.1f" $t_total
      #echo $t_diff
      # if the algorithm finds a time that is close enough, mark location
      if (( $(echo "$t_diff < 3.0" |bc -l)  )); then
         printf "%8.2f %8.2f %8.2f %8.2f %8.2f %8.2f\n" $baz $inc $time $lat $lon $d && break
      # if the time difference anywhere on the ray branch is too large, there's not likely a match
      # anywhere on the ray branch so don't waste time on it.
      elif (( $(echo "$t_diff > 500.0" | bc -l) )) ; then
         break
      fi
   done < out
done < full_clean




