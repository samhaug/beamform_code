#!/bin/bash
#SBATCH --job-name=scatloc
#SBATCH --account=jritsema1
#SBATCH --export=ALL 
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=105000m
#SBATCH --time=01:30:00 
#SBATCH --output=scatloc.out
#SBATCH --error=scatloc.err 

# run parallel instances of scatter_locate.sh on output file of xh_beammmax and beamfile.

# Usage: sbatch parallel_scatter_locate.sh BEAMFILE MAXFILE
# BEAMFILE: Beamfile structure from xh_3compbeamform
# MAXFILE:  Local maxima of BEAMFILE computed with xh_beammax

if [ $# != 3 ]; then
   echo "This is a batch script."
   echo "USAGE: sbatch single_satter_locate.sh BEAMFILE MAXFILE lineno"
   echo "BEAMFILE: Beamfile structure from xh_3compbeamform"
   echo "MAXFILE:  Local maxima of BEAMFILE computed with xh_beammax"
   echo "lineno:  line number of MAXFILE from which to calculate"
   exit
fi

echo BEAMFILE: $1
echo MAXFILE: $2
echo lineno: $3

freq=$(echo "$2" | awk -F"_" '{print $1}')

line=$3

source ~/.bashrc
ulimit -s unlimited

if [ ! -d scatter ]; then
   mkdir scatter
fi

if [ ! -e describe ]; then
   xh_beamdescribe f1_norm.beam > describe 
fi

echo "start time is : $(date +"%T")"
alat=$(grep array_centroid_lat describe | awk '{print $2}')
alon=$(grep array_centroid_lon describe | awk '{print $2}')
elat=$(grep event_lat describe | awk '{print $2}')
elon=$(grep event_lon describe | awk '{print $2}')
h=$(grep event_depth describe | awk '{print $2}')

# get info from nth line of file
full=($(sed "${line}q;d" $2))
baz=${full[0]}
inc=${full[1]}
time=${full[2]}
srun ${SRC}/beamform_code/scatter_locate.sh \
     $alat $alon $elat $elon $h $inc $baz $time $line > ./scatter/scatter_${freq}_${line}.dat 

