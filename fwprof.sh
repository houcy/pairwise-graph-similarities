#!/bin/bash
for i in `seq 1 10`;
do
 ./time-fw $1 
 ./time-fw-0 $1 
 ./time-fw-1 $1
 ./time-fw-2 $1
 ./time-fw-3 $1
 ./time-fw-4 $1
 ./time-fw-5 $1 
 echo ''
done
