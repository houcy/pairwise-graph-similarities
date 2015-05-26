#!/bin/bash
for i in `seq 1 10`;
do
 ./fw-time $1 
 ./fw-time-0 $1 
 ./fw-time-1 $1 
 ./fw-time-2 $1 
 ./fw-time-3 $1 
 ./fw-time-4 $1 
 ./fw-time-5 $1 
 echo ''
done
