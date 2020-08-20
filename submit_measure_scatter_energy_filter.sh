#!/bin/bash

if (( $(pwd | awk -F"/" '{print $NF}') != 'seismograms' )); then 
echo "Must be in the seismograms directory"
exit
fi

echo "#!/bin/bash" > scatter_energy.sbatch
echo "#SBATCH --job-name=scatter_energy" >> scatter_energy.sbatch
echo "#SBATCH --account=jritsema1" >> scatter_energy.sbatch
echo "#SBATCH --export=ALL " >> scatter_energy.sbatch
echo "#SBATCH --nodes=1" >> scatter_energy.sbatch
echo "#SBATCH --ntasks-per-node=1 " >> scatter_energy.sbatch
echo "#SBATCH --cpus-per-task=1" >> scatter_energy.sbatch
echo "#SBATCH --mem=175000m" >> scatter_energy.sbatch
echo "#SBATCH --time=00:30:00 " >> scatter_energy.sbatch
echo "#SBATCH --output=scatter_energy.out" >> scatter_energy.sbatch
echo "#SBATCH --error=scatter_energy.err " >> scatter_energy.sbatch

echo 'for d in Ev*/SUB*; do echo $d; (cd $d && ~/src/beamform_code/measure_scatter_energy_filter.sh); done' >> scatter_energy.sbatch

sbatch scatter_energy.sbatch
