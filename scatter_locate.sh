#!/bin/bash

if [ $# != 9 ]; then
  echo "Look for connecting raypath combos that match baz, inc, and traveltime"
  echo "Usage: scatter_locate.sh a_lat a_lon e_lat e_lon e_dep inc baz time num"
  echo "       a_lat : array centroid latitude"
  echo "       a_lon : array centroid longitude"
  echo "       e_lat : earthquake latitude"
  echo "       e_lon : earthquake longitude"
  echo "       e_dep : earthquake depth"
  echo "       inc : incidence angle from vertical"
  echo "       baz : azimuth from array to scatterer clockwise from north"
  echo "       time : arrival time of scattered wave"
  echo "       num : any integer. only important for parallel runs as this integer will"
  echo "             be the suffix on stored lookup table."
  exit 
fi

if [ ! -d time_files ]; then
    mkdir time_files
fi

#Array centroid/EQ lat/lon
a_lat=$1
a_lon=$2
e_lat=$3
e_lon=$4
#EQ depth
evdp=$5
#Incidence angle of arrival
inc=$6
#Back azimuth of arrival (clockwise from North)
baz=$7
#observed time
tobs=$8
#any integer for suffix purposes
num=$9

#Depth search incriment
search=$(seq 100 20 2800)
seq 0 1 90 > time_files/deg_${num}

for s_depth in $search; do
    # Find all reciever branches that are close to observed incidence angle
    # Pipe taup output and grep for floats, return only lines with 10 awk fields
    # P_rec_###.dat format:
    # a_lat, a_lon, baz, distance, time, ray_p, inc_angle
    taup_time -mod prem -h $s_depth --stadepth 0 -ph P,p < time_files/deg_${num} \
        | grep -E '[+-]?([0-9]*[.])?[0-9]+' | \
        awk  -v var1="$inc" -v a_lat="$a_lat" -v a_lon="$a_lon" -v baz="$baz" \
       '{if (NF==10 && sqrt((var1-$7)^2)<0.25) print a_lat,a_lon,baz,$1,$4,$5,$7}' > \
        time_files/P_rec_${s_depth}_${num}.dat

    # Remove empty files
    if [ ! -s time_files/P_rec_${s_depth}_${num}.dat ]; then 
        rm time_files/P_rec_${s_depth}_${num}.dat

    # If not empty, find distance from event to scatter point
    else
        # print a_lat, a_lon, az (baz), dist
        awk '{print $1,$2,$3,$4}' time_files/P_rec_${s_depth}_${num}.dat > \
            time_files/input_${num}.dat
        # for some reason, vincenty file codes repeat the last line
        vincenty_direct_file time_files/input_${num}.dat | head -n -1 | \
           awk -v e_lat="$e_lat" -v e_lon="$e_lon" \
           '{print e_lat,e_lon,$1,$2}'> time_files/coord_${s_depth}_${num}.dat

        vincenty_inverse_file time_files/coord_${s_depth}_${num}.dat | head -n -1 | \
           awk '{print $3}' > time_files/gcarc_${s_depth}_${num}.dat
        #final output
        #distance from array along baz, time, slowness, inc, distance from source
        paste time_files/{P_rec_${s_depth}_${num}.dat,coord_${s_depth}_${num}.dat,gcarc_${s_depth}_${num}.dat} | \
          awk '{print $4,$5,$6,$7,$12}' > time_files/info_${s_depth}_${num}.dat

        rm time_files/input_${num}.dat
        rm time_files/coord_${s_depth}_${num}.dat
        rm time_files/gcarc_${s_depth}_${num}.dat
        rm time_files/P_rec_${s_depth}_${num}.dat
        while read g1 time p i g2; do
           # Use lower case phase name for upward going ray
           # must swap station and event depth. This does not work for downgoing rays
           tp=$(taup_time -mod prem -h $s_depth -deg $g2 --stadepth $evdp --time -ph p,P \
                | awk '{print $1}')
           ts=$(taup_time -mod prem -h $s_depth -deg $g2 --stadepth $evdp --time -ph s,S   \
                | awk '{print $1}')
           # if no raypath exists than make the time very long
           if [ -z $tp ]; then tp=5000.0; fi
           if [ -z $ts ]; then ts=5000.0; fi
           #This clumsy phrase removes the minus sign to imitate absolute value
           total_time_pp=$(echo "($tp+$time)-$tobs" | bc | sed 's/-//g')
           total_time_sp=$(echo "($ts+$time)-$tobs" | bc | sed 's/-//g')
           #time_diff_pp=$(awk -v tobs=$tobs -v tp=$tp -v t=$time \
           #              '{print sqrt(((tp+t)-tobs)^2)}') 
           #time_diff_sp=$(awk -v tobs=$tobs -v ts=$ts -v t=$time \
           #              '{print sqrt(((ts+t)-tobs)^2)}') 

           echo $g1 $g2 $s_depth $((6371-${s_depth})) $total_time_pp $total_time_sp
          
        done < time_files/info_${s_depth}_${num}.dat
    fi
done


