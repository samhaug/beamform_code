#!/bin/bash
#SBATCH --job-name=master_run
#SBATCH --account=jritsema1
#SBATCH --export=ALL 
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=36 
#SBATCH --cpus-per-task=1
#SBATCH --mem=180000m
#SBATCH --time=08:30:00 
#SBATCH --output=master_run.out
#SBATCH --error=master_run.err 

#Submit master_run.sh in every SUBARRAY file. Each code runs a separate instance of 
#submit_master_run.sh

STARTTIME=$(date +%s)
echo "start time is : $(date +"%T")"

nodes=(`scontrol show hostnames $SLURM_JOB_NODELIST`)
i=0
j=0
n_parallel_jobs=${#nodes[@]}
echo n_parallel_jobs: $n_parallel_jobs

for dir in Event*/SUBARRAY*; do
    echo "running: $dir"
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
    (cd $dir && srun -n1 -N1 -w ${nodes[$i]} ~/src/beamform_code/master_run.sh)&
    j=$((j+1))
done
wait

ENDTIME=$(date +%s)
Ttaken=$(($ENDTIME - $STARTTIME))
echo
echo "finish time is : $(date +"%T")"
echo "RUNTIME is :  $(($Ttaken / 3600)) hours ::  $(($(($Ttaken%3600))/60)) minutes  :: $(($Ttaken % 60)) seconds."

