#!/bin/bash

if (( $(pwd | awk -F"/" '{print $NF}') != 'seismograms' )); then 
echo "Must be in the seismograms directory"
exit
fi

echo "#!/bin/bash" > beammax.sbatch
echo "#SBATCH --job-name=beammax" >> beammax.sbatch
echo "#SBATCH --account=jritsema1" >> beammax.sbatch
echo "#SBATCH --export=ALL " >> beammax.sbatch
echo "#SBATCH --nodes=1" >> beammax.sbatch
echo "#SBATCH --ntasks-per-node=1 " >> beammax.sbatch
echo "#SBATCH --cpus-per-task=1" >> beammax.sbatch
echo "#SBATCH --mem=175000m" >> beammax.sbatch
echo "#SBATCH --time=00:30:00 " >> beammax.sbatch
echo "#SBATCH --output=beammax.out" >> beammax.sbatch
echo "#SBATCH --error=beammax.err " >> beammax.sbatch

echo 'for d in Ev*/SUB*; do echo $d; (cd $d && ~/src/beamform_code/find_beammax_filter.sh); done' >> beammax.sbatch

sbatch beammax.sbatch
