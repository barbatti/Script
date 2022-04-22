#!/bin/bash

BASEDIR=`pwd`
for I in `seq $1 $2`; do 
  if [ -f ${BASEDIR}/TRAJ${I}/RESULTS/nx.log ]; then
    echo -n "${I}: "
    if ( grep -q FINISHING ${BASEDIR}/TRAJ${I}/RESULTS/nx.log>/dev/null ); then
      tail -n 12000 ${BASEDIR}/TRAJ${I}/RESULTS/nx.log|grep FINISHING|tail -n1;
      tail -n 20 ${BASEDIR}/TRAJ${I}/RESULTS/nx.log|grep "::ERROR::" 
      tail -n 20 ${BASEDIR}/TRAJ${I}/RESULTS/nx.log|grep "End of dynamics"
    else
      echo "             Trajectory ${I} is currently in step ZERO   -------" 
    fi
  fi
done
