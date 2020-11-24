import obspy
import numpy as np
from os.path import isdir
from subprocess import call

if not isdir("./z_comp"):
    call("mkdir ./z_comp",shell=True)

print('reading')
z = obspy.read('data/*BHZ*')
print('read')

z.interpolate(5)
z.detrend()

# Make sure every trace has 6000 samples. (1200 seconds at 5Hz)
# Trim data to numsamp samples. Pad shorter traces with zeros.
# Remove extremely short data (less than 5800 samples)

numsamp=6000
pad_cutoff=5800

for idx,tr in enumerate(z):
   # Don't write a trace with nans
   if np.isnan(np.sum(tr.data)):
       continue

   tr.data = tr.data[0:numsamp]
   tr.stats.sac['npts'] = numsamp
   if len(tr.data) == numsamp:
       tr.write('./z_comp/{}.{}.{}.{}.sac'.format(tr.stats.network,
                                                  tr.stats.station,
                                                  tr.stats.location,
                                                  tr.stats.channel))
   elif len(tr.data) < numsamp and len(tr.data) > pad_cutoff:
       tr.data = np.hstack((tr.data,np.zeros(numsamp-len(tr.data))))
       tr.stats.sac['npts'] = numsamp
       tr.write('./z_comp/{}.{}.{}.{}.sac'.format(tr.stats.network,
                                                  tr.stats.station,
                                                  tr.stats.location,
                                                  tr.stats.channel))
   else:
       continue
       


