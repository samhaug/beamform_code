#!/bin/bash

if [ $# != 2 ]; then
   echo "Finds temporal, incidence angle, and baz bounds for P wave arriaval"
   echo "and normalizes on maximum within these bounds"
   echo "USAGE: ./beam_normalizes_zcomp.sh BEAMFILE_IN BEAMFILE_OUT"
   echo "BEAMFILE is computed by xh_3compbeam"
   exit
fi

if [ ! -e describe ]; then
    xh_beamdescribe_zcomp $1 > describe
fi

#Find temporal, baz, and incidence angle boundaries

evdp=$(awk '/evdp/ {print $2}' describe)
gcarc=$(awk '/gcarc/ {print $2}' describe)
baz=$(awk '/sr_baz/ {print $2}' describe)

P_inc=$(taup_time -mod prem -deg $gcarc -ph P -h $evdp | tail -n2 | head -n1 | awk '{print $7}')
i_min=$((${P_inc%.*}-3))
i_max=$((${P_inc%.*}+3))

P_time=$(taup_time -mod prem -h $evdp -deg $gcarc -ph P --time | awk '{print $1}')
t_min=$((${P_time%.*}-15))
t_max=$((${P_time%.*}+15))

b_min=$((${baz%.*}-4))
b_max=$((${baz%.*}+4))


echo "xh_beamnorm_zcomp $1 $2 $b_min $b_max $i_min $i_max $t_min $t_max"
xh_beamnorm_zcomp $1 $2 $b_min $b_max $i_min $i_max $t_min $t_max



