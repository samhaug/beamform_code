#!/bin/bash

if (( $(pwd | awk -F"/" '{print $NF}') != 'seismograms' )); then 
echo "Must be in the seismograms directory"
exit
fi

echo "#!/bin/bash" > P_energy.sbatch
echo "#SBATCH --job-name=P_energy" >> P_energy.sbatch
echo "#SBATCH --account=jritsema1" >> P_energy.sbatch
echo "#SBATCH --export=ALL " >> P_energy.sbatch
echo "#SBATCH --nodes=1" >> P_energy.sbatch
echo "#SBATCH --ntasks-per-node=1 " >> P_energy.sbatch
echo "#SBATCH --cpus-per-task=1" >> P_energy.sbatch
echo "#SBATCH --mem=175000m" >> P_energy.sbatch
echo "#SBATCH --time=00:30:00 " >> P_energy.sbatch
echo "#SBATCH --output=P_energy.out" >> P_energy.sbatch
echo "#SBATCH --error=P_energy.err " >> P_energy.sbatch

echo 'for d in Ev*/SUB*; do echo $d; (cd $d && ~/src/beamform_code/measure_P_energy_filter.sh); done' >> P_energy.sbatch

sbatch P_energy.sbatch
