import obspy
from os.path import isdir
from subprocess import call
from obspy.taup import TauPyModel
import numpy as np
from matplotlib import pyplot as plt
model = TauPyModel(model='prem')

if not isdir("./z_comp"):
    call("mkdir ./z_comp",shell=True)
if not isdir("./e_comp"):
    call("mkdir ./e_comp",shell=True)
if not isdir("./n_comp"):
    call("mkdir ./n_comp",shell=True)
   

print('reading')
z = obspy.read('data/*BHZ*')
n = obspy.read('data/*BHN*')
e = obspy.read('data/*BHE*')
print('read')
z_l = []
n_l = []
e_l = []
all_l = []

z.interpolate(6)
n.interpolate(6)
e.interpolate(6)
#z.filter('bandpass',freqmin=1/100.,freqmax=1./5,zerophase=True)
#n.filter('bandpass',freqmin=1/100.,freqmax=1./5,zerophase=True)
#e.filter('bandpass',freqmin=1/100.,freqmax=1./5,zerophase=True)
z.detrend()
n.detrend()
e.detrend()

# Trim data to numsamp samples. Remove shorter traces

numsamp=3882

z_netw=[]
z_stat=[]
z_loc=[]
for idx,tr in enumerate(z):
        z[idx].data = z[idx].data[0:numsamp]
        if len(z[idx].data) != numsamp:
            z_stat.append(z[idx].stats.station)
            z_netw.append(z[idx].stats.network)
            z_loc.append(z[idx].stats.location)

for ii in range(0,len(z_netw)):
    z.remove(z.select(station=z_stat[ii],network=z_netw[ii],location=z_loc[ii])[0])

n_netw=[]
n_stat=[]
n_loc=[]
for idx,tr in enumerate(n):
        n[idx].data = n[idx].data[0:numsamp]
        if len(n[idx].data) != numsamp:
            n_stat.append(n[idx].stats.station)
            n_netw.append(n[idx].stats.network)
            n_loc.append(n[idx].stats.location)
for ii in range(0,len(n_netw)):
    n.remove(n.select(station=n_stat[ii],network=n_netw[ii],location=n_loc[ii])[0])

e_netw=[]
e_stat=[]
e_loc=[]
for idx,tr in enumerate(e):
        e[idx].data = e[idx].data[0:numsamp]
        if len(tr.data) != numsamp:
            e_stat.append(e[idx].stats.station)
            e_netw.append(e[idx].stats.network)
            e_loc.append(e[idx].stats.location)
for ii in range(0,len(e_netw)):
    e.remove(e.select(station=e_stat[ii],network=e_netw[ii],location=e_loc[ii])[0])

#Remove duplicates
for tr in z:
   name = "{}_{}_{}".format(tr.stats.network,tr.stats.station,tr.stats.location)
   if name not in z_l:
       z_l.append(name)
   else:
       z.remove(tr)
for tr in n:
   name = "{}_{}_{}".format(tr.stats.network,tr.stats.station,tr.stats.location)
   if name not in n_l:
       n_l.append(name)
   else:
       n.remove(tr)
for tr in e:
   name = "{}_{}_{}".format(tr.stats.network,tr.stats.station,tr.stats.location)
   if name not in e_l:
       e_l.append(name)
   else:
       e.remove(tr)

z_l = []
n_l = []
e_l = []
all_l = []

#Make list of each trace
for tr in z:
   z_l.append("{}_{}_{}".format(tr.stats.network,tr.stats.station,tr.stats.location))
   all_l.append("{}_{}_{}".format(tr.stats.network,tr.stats.station,tr.stats.location))
for tr in n:
   n_l.append("{}_{}_{}".format(tr.stats.network,tr.stats.station,tr.stats.location))
   all_l.append("{}_{}_{}".format(tr.stats.network,tr.stats.station,tr.stats.location))
for tr in e:
   e_l.append("{}_{}_{}".format(tr.stats.network,tr.stats.station,tr.stats.location))
   all_l.append("{}_{}_{}".format(tr.stats.network,tr.stats.station,tr.stats.location))

#Remove traces not common to all three components
for i in (set(all_l)-set(z_l)):
    try:
        for tr in n.select(network=i.split('_')[0],station=i.split('_')[1],location=i.split('_')[2]):
            n.remove(tr)
    except:
        pass
    try:
        for tr in e.select(network=i.split('_')[0],station=i.split('_')[1],location=i.split('_')[2]):
            e.remove(tr)
    except:
        continue
for i in (set(all_l)-set(n_l)):
    try:
        for tr in z.select(network=i.split('_')[0],station=i.split('_')[1],location=i.split('_')[2]):
            z.remove(tr)
    except:
        pass
    try:
        for tr in e.select(network=i.split('_')[0],station=i.split('_')[1],location=i.split('_')[2]):
            e.remove(tr)
    except:
        pass
for i in (set(all_l)-set(e_l)):
    try:
        for tr in n.select(network=i.split('_')[0],station=i.split('_')[1],location=i.split('_')[2]):
            n.remove(tr)
    except:
        pass
    try:
        for tr in z.select(network=i.split('_')[0],station=i.split('_')[1],location=i.split('_')[2]):
            z.remove(tr)
    except:
        pass

z.sort(['network','station','location'])
n.sort(['network','station','location'])
e.sort(['network','station','location'])

print("Aligning on P")
#for idx,tr in enumerate(z):
#    gcarc = tr.stats.sac['gcarc']
#    if tr.stats.sac['evdp'] > 1000:
#        tr.stats.sac['evdp'] *= 1/1000.
#    h = tr.stats.sac['evdp']
#    t = model.get_travel_times(source_depth_in_km=h,
#                               distance_in_degree=gcarc,
#                               phase_list=['ttp'])[0].time
#    s = tr.stats.sampling_rate
#    w = tr.data[int((t-20)*s):int((t+20)*s)]
#    l = int(len(w)/2.)
#    p1 = np.argmax(np.abs(w))
#    z[idx].data = np.roll(z[idx].data,l-p1)
#    e[idx].data = np.roll(e[idx].data,l-p1)
#    n[idx].data = np.roll(n[idx].data,l-p1)   

#z.differentiate()
#n.differentiate()
#e.differentiate()
for tr in z:
    tr.write('z_comp/{}_{}_{}.sac'.format(tr.stats.network,tr.stats.station,tr.stats.location),format='SAC')
for tr in n:
    if tr.stats.sac['evdp'] > 1000:
        tr.stats.sac['evdp'] *= 1/1000.
    tr.write('n_comp/{}_{}_{}.sac'.format(tr.stats.network,tr.stats.station,tr.stats.location),format='SAC')
for tr in e:
    if tr.stats.sac['evdp'] > 1000:
        tr.stats.sac['evdp'] *= 1/1000.
    tr.write('e_comp/{}_{}_{}.sac'.format(tr.stats.network,tr.stats.station,tr.stats.location),format='SAC')

