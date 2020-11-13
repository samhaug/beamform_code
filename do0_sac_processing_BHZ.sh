#!/bin/bash 

#-- A SAC file retrieved using SOD is called:
#-- NETW.STNM.LOCC.CHAN.sac (LOCC is usually an empty string)

#------- 
#-- the directory "traces_with_issues/" contains traces from SOD with NaNs or channel issues
if [ ! -e traces_with_issues ]; then
  mkdir  traces_with_issues
fi
#-- the directory "original/" contains original traces from SOD
if [ ! -e original ]; then
  mkdir  original
fi


#-------
#-- remove records if DEPMAX <= DEPMIN ---> this could point to NaN in the record
echo ""
echo Checking NaN ...
for sacfile in  *.BHZ.sac ; do
  depmax=$(saclst depmax f $sacfile | awk '{print $2}') 
  depmin=$(saclst depmin f $sacfile | awk '{print $2}') 
  depmen=$(saclst depmen f $sacfile | awk '{print $2}') 
  #--  echo sacfile= $sacfile  depmax= $depmax depmin= $depmin depmen= $depmen
  #--
  #-- Previously I used: "if ( `echo "$depmin >= $depmax" | bc` ) then"
  #-- I am now using ~/src/Utilities/calc.c because "bc" 
  #-- does not work with floats in an exponential form
  #--
  #if ( `calc $depmin ge $depmen` || `calc $depmax le $depmen || calc $depmin ge $depmax` ) then
  printf -v depmax "%.25f" $depmax
  printf -v depmin "%.25f" $depmin
  printf -v depmen "%.25f" $depmen

  if [[ `echo "$depmin >= $depmen" | bc -l` || \
        `echo "$depmax <= $depmen" | bc -l` || \
        `echo "$depmin >= $depmax" | bc -l ` ]]; then
         echo sacfile= $sacfile  depmax= $depmax depmin= $depmin depmen= $depmen
	 echo  "Moving $sacfile to traces_with_issues/"
	 /bin/mv       $sacfile    traces_with_issues/
  fi
done
/bin/rm junk


#------- 
echo ""
echo  SAC processing ...
echo "-------------"                                                                 > sac_processing.txt
echo "SAC_processing NetWork Station StLat StLon SamplingTime OriginTime BeginTime" >> sac_processing.txt
echo "-------------"                                                                >> sac_processing.txt

for sacfile in  *.BHZ.sac ; do 
  #-- Insert the  P and PP traveltimes in T0 and T3
  taup_setsac -mod ak135 -ph P-0,Pdiff-0,PP-3 $sacfile
  #-- Insert the pP and sP traveltimes in T1 and T2 if evdp >= 50 km
  evdp=`saclst evdp f $sacfile | awk '{print $2}'`
  echo $evdp
  printf -v evdp "%.15f" $evdp
  if [ `echo "$evdp ge 50000" | bc -l` ]; then
     taup_setsac -mod ak135 -ph pP-1,pPdiff-1,sP-2,sPdiff-2 $sacfile
  fi
  #-- name = NETW + STNM + LOCC (often "locc" is an empty string)
  name=`echo $sacfile | cut -d '.' -f 1,2,3`

  #-- chan = channel (should be BHZ)
  chan=`echo $sacfile | cut -d '.' -f 4`

  echo Working on name= $name chan= $chan
  #-- resampling and cut traces
  echo "r $sacfile"               > in_sac
  echo "rmean"                   >> in_sac
  echo "rtr"                     >> in_sac
  #-- set sampling time (delta) to 0.2 seconds
  echo "interpolate delta 0.2"   >> in_sac
  #-- adding "disp" in the SAC filename to be clear that this is a displacement record
  echo "w $name.$chan.disp.sac"  >> in_sac
  #-- cut traces between [t0-250, t0+400]; t0= P-wave arrival
  echo "cut t0 -250 N 3250"      >> in_sac
  echo "r $name.$chan.disp.sac"  >> in_sac
  echo "w over"                  >> in_sac
  echo "cut off"                 >> in_sac
  echo "quit"                    >> in_sac
  sac < in_sac

  #-- add info to "sac_processing.txt"
  saclst knetwk kstnm stla stlo delta o b f $name.$chan.disp.sac                    >> sac_processing.txt
done
/bin/rm in_sac


#------- 
#-- move the original seismograms to the directory "original/"
if [ ! -e original ]; then
  mkdir  original
fi
mv *.BH?.sac original/.
