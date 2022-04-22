#!/bin/bash

BASEDIR=`pwd`
for I in `seq $1 $2`; do 
  if [ -f ${BASEDIR}/I${I}/initcond.log ]; then
    echo -n "${I}: "
    grep "= Done" ${BASEDIR}/I${I}/initcond.log | tail -1
  fi
done
