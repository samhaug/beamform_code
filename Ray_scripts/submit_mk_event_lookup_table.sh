#!/bin/bash
SRC=/home/samhaug/src/beamform_code/Ray_scripts
echo "#!/bin/bash" > mk_table.sbatch
echo "#SBATCH --job-name=mk_table" >> mk_table.sbatch
echo "#SBATCH --account=jritsema1" >> mk_table.sbatch
echo "#SBATCH --export=ALL " >> mk_table.sbatch
echo "#SBATCH --nodes=1" >> mk_table.sbatch
echo "#SBATCH --ntasks-per-node=1" >> mk_table.sbatch
echo "#SBATCH --cpus-per-task=1" >> mk_table.sbatch
echo "#SBATCH --mem=180000m" >> mk_table.sbatch
echo "#SBATCH --time=01:30:00 " >> mk_table.sbatch
echo "#SBATCH --output=mk_table.out" >> mk_table.sbatch
echo "#SBATCH --error=mk_table.err " >> mk_table.sbatch
echo 'for d in E*; do (cd $d && $SRC/mk_event_lookup_table.sh); done' >> mk_table.sbatch

sbatch mk_table.sbatch
