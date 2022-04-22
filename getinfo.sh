#!/bin/bash

BASEDIR=`pwd`
for I in `seq $1 $2`; do 
  if [ -f ${BASEDIR}/TRAJ${I}/RESULTS/nx.log ]; then
    echo -n "${I}: "
    grep FINISHING ${BASEDIR}/TRAJ${I}/RESULTS/nx.log|tail -n1;
    tail -n 20 ${BASEDIR}/TRAJ${I}/RESULTS/nx.log|grep "::ERROR::" 
    tail -n 20 ${BASEDIR}/TRAJ${I}/RESULTS/nx.log|grep "End of dynamics"
  fi
done
