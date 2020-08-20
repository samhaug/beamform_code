#!/bin/bash

if (( $(pwd | awk -F"/" '{print $NF}') != 'seismograms' )); then 
echo "Must be in the seismograms directory"
exit
fi

echo "#!/bin/bash" > normalize.sbatch
echo "#SBATCH --job-name=normalize" >> normalize.sbatch
echo "#SBATCH --account=jritsema1" >> normalize.sbatch
echo "#SBATCH --export=ALL " >> normalize.sbatch
echo "#SBATCH --nodes=1" >> normalize.sbatch
echo "#SBATCH --ntasks-per-node=1 " >> normalize.sbatch
echo "#SBATCH --cpus-per-task=1" >> normalize.sbatch
echo "#SBATCH --mem=175000m" >> normalize.sbatch
echo "#SBATCH --time=00:30:00 " >> normalize.sbatch
echo "#SBATCH --output=normalize.out" >> normalize.sbatch
echo "#SBATCH --error=normalize.err " >> normalize.sbatch

echo 'for d in Ev*/SUB*; do echo $d; (cd $d && ~/src/beamform_code/normalize_beam_on_P_filter.sh); done' >> normalize.sbatch

sbatch normalize.sbatch
