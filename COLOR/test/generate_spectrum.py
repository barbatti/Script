#!/usr/bin/python

from math import exp,log,sqrt

def g(x,a,center,FWMH):
   c = FWMH/(2.*sqrt(2.*log(2.)))
   return a*exp(-((x-center)/(2*c))**2)
   

if __name__ == "__main__":
   for i in range(380,781):
#      print "%5.2f %13.6f"%(i,g(i,1.75,750,30))
      print "%5.2f %13.6f"%(i,g(i,1.75,636,200))
