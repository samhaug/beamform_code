#!/bin/bash

# runs sac_2xh in directory containing z_comp,n_comp,e_comp. Step 4 of the instruction

if [ ! -d z_comp ]; then echo "Cannot find z_comp, run prepare_3comp.py first"; exit; fi
if [ ! -d n_comp ]; then echo "Cannot find n_comp, run prepare_3comp.py first"; exit; fi
if [ ! -d e_comp ]; then echo "Cannot find e_comp, run prepare_3comp.py first"; exit; fi

cd z_comp
for i in *sac; do
   sac_2xh $i $i.xh
done
cd ..

cd n_comp
for i in *sac; do
   sac_2xh $i $i.xh
done
cd ..

cd e_comp
for i in *sac; do
   sac_2xh $i $i.xh
done
cd ..

# check for empty xh files and remove across all components
null_z=$(cd z_comp && ls -l *xh | awk '$5==0 {print $NF}');
null_n=$(cd n_comp && ls -l *xh | awk '$5==0 {print $NF}');
null_e=$(cd e_comp && ls -l *xh | awk '$5==0 {print $NF}');
null_list=($null_z $null_n $null_e)
for d in ${null_list[@]}; do
  for i in $d; do
     rm z_comp/$i > /dev/null
     rm n_comp/$i > /dev/null
     rm e_comp/$i > /dev/null
  done
done


cat z_comp/*xh > z.xh
cat n_comp/*xh > n.xh
cat e_comp/*xh > e.xh

xh_shorthead z.xh | awk '{print $8,$9,$3,$4}' > coords.txt

