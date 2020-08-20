#!/bin/bash

alatlon=$(awk 'BEGIN{i=0;lat=0;lon=0} {lat+=$1;lon+=$2;i++} END{print lat/i,lon/i}' subarray*.txt)
elatlon=$(xh_shorthead xh/z.xh | awk '{print $6,$7}' | head -n1)

baz=$(vincenty_inverse $alatlon $elatlon | awk '{print $1}')
baz=${baz%.*}

#baz_min=$(($baz-60))
#baz_max=$(($baz+60))

baz_min=0
baz_max=359

if [ -f subarray*.txt ]; then
   beam_name=$(echo subarray_*.txt)
else
   beam_name="synthetic"
fi
beam_name=${beam_name::-4}

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
echo "xh_3compbeamform xh/z_f1.xh xh/n_f1.xh xh/e_f1.xh $baz_min $baz_max 1 0 40 1 ${beam_name}_f1.beam" >> beam.sbatch
echo "xh_3compbeamform xh/z_f2.xh xh/n_f2.xh xh/e_f2.xh $baz_min $baz_max 1 0 40 1 ${beam_name}_f2.beam" >> beam.sbatch
echo "xh_3compbeamform xh/z_f3.xh xh/n_f3.xh xh/e_f3.xh $baz_min $baz_max 1 0 40 1 ${beam_name}_f3.beam" >> beam.sbatch
echo "xh_3compbeamform xh/z_f4.xh xh/n_f4.xh xh/e_f4.xh $baz_min $baz_max 1 0 40 1 ${beam_name}_f4.beam" >> beam.sbatch
#echo "xh_3compbeamform zhypo.xh nhypo.xh ehypo.xh $baz_min $baz_max 1 0 40 1 hypo.beam" >> beam.sbatch
echo "xh_beamdescribe ${beam_name}_f1.beam > describe" >> beam.sbatch

sbatch beam.sbatch
