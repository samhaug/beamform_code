#!/bin/bash

#Forget trying to find the right azimuth bounds (above code). Just compute all 360 degrees 

baz_min=0
baz_max=359

if [ ! -e z.xh ]; then
   echo "cannot find z.xh file"
   exit
fi

beam_name=z.beam

echo "#!/bin/bash" > beam.sbatch
echo "#SBATCH --job-name=beamform" >> beam.sbatch
echo "#SBATCH --account=jritsema1" >> beam.sbatch
echo "#SBATCH --export=ALL " >> beam.sbatch
echo "#SBATCH --nodes=1" >> beam.sbatch
echo "#SBATCH --ntasks-per-node=1 " >> beam.sbatch
echo "#SBATCH --cpus-per-task=1" >> beam.sbatch
echo "#SBATCH --mem=175000m" >> beam.sbatch
echo "#SBATCH --time=03:00:00 " >> beam.sbatch
echo "#SBATCH --output=beam.out" >> beam.sbatch
echo "#SBATCH --error=beam.err " >> beam.sbatch
echo "xh_beamform z.xh $baz_min $baz_max 1 -20 20 1 ${beam_name}" >> beam.sbatch
echo "xh_beamdescribe ${beam_name} > describe" >> beam.sbatch

sbatch beam.sbatch
