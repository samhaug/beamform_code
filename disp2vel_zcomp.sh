#!/bin/bash


if [ ! -d xh ]; then
   echo "Can't locate xh/ directory"
   echo "execute bpfilter_zcomp.sh first"
   exit
fi

xh_disp2vel xh/z_f1_clean.xh xh/z_f1_clean_v.xh -t 10 >> /dev/null

xh_disp2vel xh/z_f2_clean.xh xh/z_f2_clean_v.xh -t 10 >> /dev/null

xh_disp2vel xh/z_f3_clean.xh xh/z_f3_clean_v.xh -t 10 >> /dev/null

xh_disp2vel xh/z_f4_clean.xh xh/z_f4_clean_v.xh -t 10 >> /dev/null
