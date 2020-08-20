#!~/src/anaconda3/bin/python
# useful for converting axisem Axisem output to sac files
from sys import argv,exit
if len(argv[0]) == '--help':
   print("USAGE: Execute this script in the Data_Postprocessing/SEISMOGRAMS")
   print("       folder. This will prepare sac files for use with sac_2xh")
   exit

import obspy
import numpy as np
from glob import glob

stations = open('../../MZZ/STATIONS').readlines()
stat_l = [i.strip().split()[0] for i in stations]
net_l = [i.strip().split()[1] for i in stations]
lat_l = [float(i.strip().split()[2]) for i in stations]
lon_l = [float(i.strip().split()[3]) for i in stations]
evla = float(open('../../CMTSOLUTION').readlines()[4].strip().split()[1])
evlo = float(open('../../CMTSOLUTION').readlines()[5].strip().split()[1])
evdp = float(open('../../CMTSOLUTION').readlines()[6].strip().split()[1])

for f in glob("*.dat"):
    tr = obspy.core.Trace()
    tr.stats.sac = {}
    tr.stats.sac['evla'] = evla
    tr.stats.sac['evlo'] = evlo
    tr.stats.sac['evdp'] = evdp
    tr.stats.station = f.split('_')[0]
    tr.stats.network = f.split('_')[1]
    tr.stats.channel = f.split('_')[-1][0]
    idx = stat_l.index(tr.stats.station)
    tr.stats.sac['stla'] = lat_l[idx]
    tr.stats.sac['stlo'] = lon_l[idx]
    d = np.genfromtxt(f)
    tr.stats.delta = np.diff(d[:,0])[0]
    tr.stats.samplig_rate = 1./tr.stats.delta
    tr.data = d[:,1]
    tr.interpolate(2)
    tr.data = tr.data[0:7198]
    tr.filter('bandpass',freqmin=1/100.,freqmax=1./5,zerophase=True)
    tr.write(f.replace("dat","sac"),format='SAC')



