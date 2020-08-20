#!/bin/bash

# runs sac_2xh in directory containing z_comp,n_comp,e_comp. Step 4 of the instruction

if [ ! -d z_comp ]; then echo "Cannot find z_comp"; exit; fi
if [ ! -d n_comp ]; then echo "Cannot find n_comp"; exit; fi
if [ ! -d e_comp ]; then echo "Cannot find e_comp"; exit; fi

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

cat z_comp/*xh > z.xh
cat n_comp/*xh > n.xh
cat e_comp/*xh > e.xh

xh_shorthead z.xh | awk '{print $8,$9,$3,$4}' > coords.txt

