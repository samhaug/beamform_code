#!/bin/bash

# Look for scattering combinations that match incidence angle and traveltime
#THIS IS FOR IN-PLANE SCATTERING ONLY. DEFUCNT AS OF 2/24/20

if [ ! -d time_files ]; then
    mkdir time_files
fi
#incidence angle of arrival
inc=24
# Distance from EQ to array centroid
delta=48
#azimuthal deviation of scattered energy
az=9
# EQ depth
evdp=582
# Depth search incriment
search=$(seq 200 50 2000)

seq 0 1 $delta > time_files/rec_deg

# Find all reciever branches that are close to observed incidence angle
for s_depth in $search; do
    # Pipe taup output and grep for floats, return only lines with 10 awk fields
    taup_time -mod prem -h $s_depth -ph P < time_files/rec_deg \
           | grep -E '[+-]?([0-9]*[.])?[0-9]+' | awk -v var1="$inc" -v var2="$delta" '{if (NF==10 && sqrt((var1-$7)^2)<3) print $1,$4,$5,$7,var2-$1}' > time_files/P_rec_${s_depth}.dat
done

for s_depth in $search; do
    awk '{print $NF}' time_files/P_rec_${s_depth}.dat > time_files/source_deg
    deg_list=$(awk '{print $NF}' time_files/P_rec_${s_depth}.dat)
    taup_time -mod prem -h $evdp -ph P --stadepth $s_depth < time_files/source_deg \
        | grep -E '[+-]?([0-9]*[.])?[0-9]+' | awk '{if (NF==10) print $1,$4,$5,$7}' > time_files/P_source_${s_depth}.dat
    taup_time -mod prem -h $evdp -ph S --stadepth $s_depth < time_files/source_deg \
        | grep -E '[+-]?([0-9]*[.])?[0-9]+' | awk '{if (NF==10) print $1,$4,$5,$7}' > time_files/S_source_${s_depth}.dat

    while read delta t p i d; do
        awk -v var=$d -v t=$t -v s=$s_depth '{if (sqrt((var-$1)^2)<0.5) print $1,6371-s,$4+t}' time_files/P_source_${s_depth}.dat >> time_files/P_P.dat
        awk -v var=$d -v t=$t -v s=$s_depth '{if (sqrt((var-$1)^2)<0.5) print $1,6371-s,$4+t}' time_files/S_source_${s_depth}.dat >> time_files/S_P.dat
    done < time_files/P_rec_${s_depth}.dat
    
done




