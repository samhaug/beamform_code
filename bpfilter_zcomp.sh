#!/bin/bash

if [ ! -d xh ]; then
   echo "Can't locate xh/ directory"
   echo "execute run_sac_2xh_zcomp.sh first"
   exit
fi

echo First filtering band: 0.5s 1s 10s 12s
xh_bpfilter xh/z.xh xh/z_f1.xh -t 10 -f 83 100 1000 2000 >> /dev/null

echo Second filtering band: 1s 2s 25s 30s
xh_bpfilter xh/z.xh xh/z_f2.xh -t 10 -f 33 40 500 1000 >> /dev/null

echo Third filtering band: 1.5s 3s 25s 30s
xh_bpfilter xh/z.xh xh/z_f3.xh -t 10 -f 33 40 333 666 >> /dev/null

echo Fourth filtering band: 2.5s 5s 50s 60s
xh_bpfilter xh/z.xh xh/z_f4.xh -t 10 -f 16 20 200 400 >> /dev/null
