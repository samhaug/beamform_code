#!/bin/bash
#SBATCH --job-name=ray_finder
#SBATCH --account=jritsema1
#SBATCH --export=ALL 
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=36 
#SBATCH --cpus-per-task=1
#SBATCH --mem=180000m
#SBATCH --time=08:30:00 
#SBATCH --output=ray_finder.out
#SBATCH --error=ray_finder.err 

#Submit ray_finder_lookup.sh every SUBARRAY file. Each code runs a separate instance of 
# ray_finder_lookup.sh

STARTTIME=$(date +%s)
echo "start time is : $(date +"%T")"

nodes=(`scontrol show hostnames $SLURM_JOB_NODELIST`)
i=0
j=0
n_parallel_jobs=${#nodes[@]}
echo n_parallel_jobs: $n_parallel_jobs
cur=$(pwd)

for dir in $cur/Event*/SUBARRAY*; do
    if [ $j == 20 ]; then
      j=0
      i=$((i+1))
      echo "Using next node: ${nodes[$i]}"
      if [ $i == $(($n_parallel_jobs)) ]; then
         echo "All nodes full."
         i=0 
         j=0
         wait
      fi
    fi
    echo "$j running: $dir"
    cd $dir 
    srun -n1 -N1 -w ${nodes[$i]} ~/src/beamform_code/Ray_scripts/ray_finder_lookup.sh &
    echo "submitted "
    cd ../..
    j=$((j+1))
done
wait

ENDTIME=$(date +%s)
Ttaken=$(($ENDTIME - $STARTTIME))
echo
echo "finish time is : $(date +"%T")"
echo "RUNTIME is :  $(($Ttaken/3600)) hours :: $(($(($Ttaken%3600))/60)) minutes :: $(($Ttaken % 60)) seconds."

