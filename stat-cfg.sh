#!/bin/bash

> stat-cfg.csv

for f in logs/*.log
do
  s00=$(cat $f | grep "CFG\[0\]::Stats\[0\]" | sed 's/nodes://g' | sed 's/edges://g' | sed 's/,//g' | awk '{print $3","$4}')
  s01=$(cat $f | grep "CFG\[0\]::Stats\[1\]" | sed 's/nodes://g' | sed 's/edges://g' | sed 's/,//g' | awk '{print $3","$4}')
  s10=$(cat $f | grep "CFG\[1\]::Stats\[0\]" | sed 's/nodes://g' | sed 's/edges://g' | sed 's/,//g' | awk '{print $3","$4}')
  s11=$(cat $f | grep "CFG\[1\]::Stats\[1\]" | sed 's/nodes://g' | sed 's/edges://g' | sed 's/,//g' | awk '{print $3","$4}')
  t0=$(cat $f | grep "CFG\[0\]::floyd_warshall()" | sed 's/ms)//g' | awk '{print $3}')
  t1=$(cat $f | grep "CFG\[1\]::floyd_warshall()" | sed 's/ms)//g' | awk '{print $3}')
  t2=$(cat $f | grep "SPGK(CFG\[0\], CFG\[1\])"   | sed 's/ms)//g' | awk '{print $6}')
  echo "$s00,$s01,$s10,$s11,$t0,$t1,$t2" >> stat-cfg.csv
done

cat stat-cfg.csv | awk -F, '{print log($1)/log(2), log($5)/log(2), log($4)/log(2), log($8)/log(2), log($11)}' > stat-cfg.data
gnuplot stat-cfg.plot

