from sys import argv,exit

print(len(argv))
if len(argv) != 2:
   print("usage: python auto_dirty_pick.py SNR")
   print("SNR: Signal/Noise ratio below which a trace is rejected")
   exit()

import obspy
import numpy as np
from matplotlib import pyplot as plt
from obspy.taup import TauPyModel
model = TauPyModel(model='prem')


st = obspy.read("data/*BHZ*")
st.interpolate(2)
st.filter('bandpass',freqmin=1./25,freqmax=1./2,zerophase=True)
st.normalize()
fig,ax = plt.subplots(1,2)
dirty_list = []

for tr in st:
    plt.ioff()
    name = tr.stats.network+'.'+tr.stats.station+'.'+tr.stats.location
    evdp = tr.stats.sac['evdp']
    if evdp > 1000:
        evdp *= 1./1000
    gcarc = tr.stats.sac['gcarc']
    time = model.get_travel_times(source_depth_in_km=evdp,
                           distance_in_degree=gcarc,
                           phase_list=['ttp'])[0].time
    
    sr = tr.stats.sampling_rate
    itime = int(sr*(time-400))
    p_wave = tr.data[itime-int(20*sr):itime+int(20*sr)]
    n_w = ((125./30)*gcarc-175)
    
    noise = tr.data[itime-int(n_w*sr):itime-int(25*sr)]

    p_energy = np.sum(p_wave**2)/len(p_wave)
    noise_energy = np.sum(noise**2)/len(noise)

    if np.isnan(np.sum(tr.data)):
        dirty_list.append(name)

    try: 
        #if noise_energy > p_energy*0.8 or np.max(np.abs(noise)) > np.max(np.abs(p_wave)*0.3):
        if np.max(np.abs(noise)) > np.max(np.abs(p_wave)*(1/float(argv[1]))):
            dirty_list.append(name)
            ax[0].plot(tr.times(),tr.data+gcarc,lw=0.5,alpha=0.5,color='r')
            ax[0].scatter(time-400,gcarc,color='k',marker='x')
            ax[0].scatter(time-400-n_w,gcarc,color='b',marker='|')
            ax[0].scatter(time-400-25,gcarc,color='b',marker='|')
            ax[0].scatter(time-400-20,gcarc,color='g',marker='|')
            ax[0].scatter(time-400+20,gcarc,color='g',marker='|')
        else:
            ax[1].plot(tr.times(),tr.data+gcarc,lw=0.5,alpha=0.5,color='k')
            ax[1].scatter(time-400,gcarc,color='k',marker='x')
            ax[1].scatter(time-400-n_w,gcarc,color='b',marker='|')
            ax[1].scatter(time-400-25,gcarc,color='b',marker='|')
            ax[1].scatter(time-400-20,gcarc,color='g',marker='|')
            ax[1].scatter(time-400+20,gcarc,color='g',marker='|')
    except ValueError:
        dirty_list.append(name)
        continue
 

plt.show()

with open("dirty_list.txt",'a') as f:
    for ii in set(dirty_list):
        f.write(ii+'\n')

