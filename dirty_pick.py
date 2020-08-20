import obspy
from matplotlib import pyplot as plt
from sys import argv 

st = obspy.read("data/*BHZ*")
st.interpolate(1)
st.filter('bandpass',freqmin=1./120,freqmax=1./10,zerophase=True)
st.normalize()
fig,ax = plt.subplots()
dirty_list = []

print(len(st))
for tr in st:
    plt.ioff()
    name = tr.stats.network+'.'+tr.stats.station+'.'+tr.stats.location
    ax.plot(tr.times()[::5],tr.data[::5]*0.1+tr.stats.sac['gcarc'],
            color='k',lw=0.5,alpha=0.5,label=name,picker=3)

def onclick(event):
    dirty_list.append(event.artist.get_label())
    event.artist.set_alpha(0)
    fig.canvas.draw()

cid = fig.canvas.mpl_connect('pick_event', onclick)

plt.show()

with open("dirty_list.txt",'a') as f:
    for ii in set(dirty_list):
        f.write(ii+'\n')

