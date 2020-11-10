from sys import argv,exit
if len(argv) != 5:
   print("Usage: python subdivide_array info_file n_clusers stat_min rad_bin")
   print("   Where info_file iis 4 column ascii file of format stla stlo stnm netwk")
   print("   n_clusters: number of subarrays")
   print("   stat_min: minimum number of stations per subarray")
   print("   rad_bin: radius of subarray bin (degrees)")
   exit()

from sklearn.cluster import KMeans
import numpy as np
import obspy
from obspy.geodetics import gps2dist_azimuth


coords = np.genfromtxt(argv[1])[:,0:2]
names = open(argv[1],'r').readlines()
kmeans = KMeans(n_clusters=int(argv[2]))
kmeans.fit(coords)
centers = kmeans.cluster_centers_


subcount=0
for idx,ii in enumerate(centers):
   count=0
   for jdx,jj in enumerate(coords):
      dist = gps2dist_azimuth(ii[0],ii[1],jj[0],jj[1])[0]/111195.
      if dist < float(argv[4]):
         count += 1

   if count > int(argv[3]): 
      subcount += 1
      f = open("subarray_{}.txt".format(str(subcount)),"w")
      for jdx,jj in enumerate(coords):
         dist = gps2dist_azimuth(ii[0],ii[1],jj[0],jj[1])[0]/111195.
         if dist < float(argv[4]):
            f.write("%8.4f %8.4f %4s %4s\n"%(jj[0],jj[1],names[jdx].split()[2],names[jdx].split()[3]))
          
      f.close()

