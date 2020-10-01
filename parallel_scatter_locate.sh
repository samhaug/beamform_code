#!/bin/bash
#SBATCH --job-name=scatloc
#SBATCH --account=jritsema1
#SBATCH --export=ALL 
#SBATCH --nodes=5
#SBATCH --ntasks-per-node=36 
#SBATCH --cpus-per-task=1
#SBATCH --mem=175000m
#SBATCH --time=08:30:00 
#SBATCH --output=scatter_locate.out
#SBATCH --error=scatter_locate.err 

# run parallel instances of scatter_locate.sh on output file of xh_beammmax and beamfile.

# Usage: sbatch parallel_scatter_locate.sh BEAMFILE MAXFILE
# BEAMFILE: Beamfile structure from xh_3compbeamform
# MAXFILE:  Local maxima of BEAMFILE computed with xh_beammax

if [ $# != 2 ]; then
   echo "This is a batch script."
   echo "USAGE: sbatch parallel_satter_locate.sh BEAMFILE MAXFILE"
   echo "BEAMFILE: Beamfile structure from xh_3compbeamform"
   echo "MAXFILE:  Local maxima of BEAMFILE computed with xh_beammax"
   exit
fi

echo BEAMFILE: $1
echo MAXFILE: $2

STARTTIME=$(date +%s)

source ~/.bashrc
ulimit -s unlimited

if [ ! -d scatter ]; then
   mkdir scatter
fi

echo "start time is : $(date +"%T")"
xh_beamdescribe $1 > describe 
alat=$(grep array_centroid_lat describe | awk '{print $2}')
alon=$(grep array_centroid_lon describe | awk '{print $2}')
elat=$(grep event_lat describe | awk '{print $2}')
elon=$(grep event_lon describe | awk '{print $2}')
h=$(grep event_depth describe | awk '{print $2}')


nodes=(`scontrol show hostnames $SLURM_JOB_NODELIST`)
i=0
j=0
k=1
n_parallel_jobs=${#nodes[@]}
echo n_parallel_jobs: $n_parallel_jobs

while read baz inc time amp;  do
    echo $baz $inc $time $amp
    if [ $j == 20 ]; then
      j=0
      i=$((i+1))
      echo "Using next node: ${nodes[$i]}"
      if [ $i == $(($n_parallel_jobs-1)) ]; then
         echo "All nodes full."
         i=0 
         j=0
         wait
      fi
    fi
    srun -n1 -N1 -w ${nodes[$i]} \
        ${SRC}/beamform_code/scatter_locate.sh \
        $alat $alon $elat $elon $h $inc $baz $time $k > ./scatter/scatter_${k}.dat &
    k=$((k+1))
    j=$((j+1))
done < $2
wait
     

ENDTIME=$(date +%s)
Ttaken=$(($ENDTIME - $STARTTIME))
echo
echo "finish time is : $(date +"%T")"
echo "RUNTIME is :  $(($Ttaken / 3600)) hours ::  $(($(($Ttaken%3600))/60)) minutes  :: $(($Ttaken % 60)) seconds."

