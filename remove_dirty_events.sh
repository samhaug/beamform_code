#!/bin/bash

dir=$(pwd | awk -F'/' '{print $NF}')
if [ $dir != 'seismograms' ]; then
   echo "USAGE: remove_dirty_events.sh N"
   echo "Removes all event directories with less than N sac files in Event*/data"
   echo "must be in the seismograms directory"
   exit
fi

if [ $# != 1 ]; then
   echo "USAGE: remove_dirty_events.sh N"
   echo "Removes all event directories with less than N sac files in Event*/data"
   echo "must be in the seismograms directory"
   exit
fi

for d in Event*; do
    if (( $(ls $d | wc -l) < $1 )); then
        echo $(ls $d/data | wc -l), $d
        rm -rf $d
    fi
done
