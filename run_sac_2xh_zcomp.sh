#!/bin/bash

# runs sac_2xh in directory containing z_comp,n_comp,e_comp. Step 4 of the instruction

if [ ! -d z_comp ]; then echo "Cannot find z_comp, run prepare_3comp.py first"; exit; fi

cd z_comp
for i in *sac; do
   sac_2xh $i $i.xh
done
cd ..

# check for empty xh files and remove across all components
null_z=$(cd z_comp && ls -l *xh | awk '$5==0 {print $NF}');
null_list=($null_z)
for d in ${null_list[@]}; do
  for i in $d; do
     rm z_comp/$i > /dev/null
  done
done

if [ ! -d xh ]; then
   mkdir xh
fi  

cat z_comp/*xh > xh/z.xh

# Make sure each trace has 3250 samples
one=$(xh_shorthead xh/z.xh | wc -l)
two=$(xh_shorthead xh/z.xh | awk '$NF==3250' | wc -l)

echo "###########################"
echo "###########################"
echo ""
echo ""
if (( $one != $two )); then
   echo "PROBLEM: Not all traces have 3250 samples!"

elif (( $one == $two )); then
   echo "ALL CLEAR: All traces have 3250 samples!"
fi


