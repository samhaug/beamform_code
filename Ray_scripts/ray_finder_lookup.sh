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

   # Take every other line of input file to save time.
   #incoming_ray_coords $libray/Ray_h0_D${dist} $evla $evlo $stla $stlo $baz | awk 'NR%2==0' > ray_in
   incoming_ray_coords $libray/Ray_h0_D${dist} $evla $evlo $stla $stlo $baz  > ray_in
   connect_rays ray_in source_ray_P.dat $evla $evlo $time

done < full_clean

