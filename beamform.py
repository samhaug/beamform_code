import numpy as np
from numpy import sin,cos
from numpy import radians as rad
from matplotlib import pyplot as plt
import obspy
from obspy.geodetics import gps2dist_azimuth as gps
from obspy.signal.filter import envelope
from sys import exit

#328,142
theta=np.radians(142)
i=np.radians(22.76)
v_o=8.

st = obspy.read("./2010*/*BHZ*filtered")
#st.interpolate(2)
#st.filter('bandpass',freqmin=1./120,freqmax=1./10,zerophase=True)
#st.normalize()
#shape = []
#for tr in st:
#    shape.append(tr.stats.npts)

#for idx,tr in enumerate(st):
#    st[idx].data = tr.data[0:int(np.mean(shape)-1)]


#print(st[0].stats.npts)
lat = []
lon = []
for tr in st:
    lat.append(tr.stats.sac['stla'])
    lon.append(tr.stats.sac['stlo'])

a_lat = np.mean(lat)
a_lon = np.mean(lon)

x_vec_list = []
y_vec_list = []
#    if a_lon > tr.stats.sac['stlo']:
#    if a_lat > tr.stats.sac['stla']:
for tr in st:
    x_vec = gps(a_lat,a_lon,a_lat,tr.stats.sac['stlo'])[0]/1000.
    y_vec = gps(a_lat,a_lon,tr.stats.sac['stla'],a_lon)[0]/1000.
    if a_lat > tr.stats.sac['stla']:
        #print(tr.stats.network,tr.stats.station,"slat")
        y_vec *= -1
    if a_lon > tr.stats.sac['stlo']:
        #print(tr.stats.network,tr.stats.station,"slon")
        x_vec *= -1
    x_vec_list.append(x_vec)
    y_vec_list.append(y_vec)
    print("{} {} {:8.3f} {:8.3f}".format(tr.stats.network,tr.stats.station,x_vec,y_vec))
    #print("{} {} {:8.3f} {:8.3f}".format(tr.stats.network,tr.stats.station,tr.stats.sac['stla']
    #                                   ,tr.stats.sac['stlo']))
exit()

st_a = st.copy()
index = int(474*st[0].stats.sampling_rate)
for theta in np.arange(0,361,1):
    print(theta/361.*100)
    for i in np.arange(0,61,1):
        stack = np.zeros(st[0].data.shape)
        for idx,tr in enumerate(st):
            x_vec = x_vec_list[idx]
            y_vec = y_vec_list[idx]
            shift = sin(rad(i))*sin(rad(theta))*x_vec/v_o + \
                    sin(rad(i))*cos(rad(theta))*y_vec/v_o
            roll = int(shift*tr.stats.sampling_rate)
            st_a[idx].data = np.roll(st_a[idx].data,roll)
            stack += st_a[idx].data
            st_a[idx].data = np.roll(st_a[idx].data,-1*roll)
        stack = stack**2
        stack = stack**1
        envelope(stack)
        #dprint(theta,i,stack[index]) 
        
          
   
    
    






