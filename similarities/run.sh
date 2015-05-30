#!/bin/bash

#
# USAGE: ./run.sh short-cfg.lst 3 "1 2 3" "1 16 64" "4 8"
#   - param 1: list of CFG file    [no default]
#   - param 2: number of runs      [default: 3]
#   - param 3: list of versions    [default: 1 through 24]
#   - param 4: list of chunk sizes [default: 1 2 4 ... 256]
#   - param 5: OpenMP loops        [default: 1 2 3 4]
#   - param 6: list of num threads [default: result of 'nproc' command]
#
# Lists of different length are provided:
#     Xshort-cfg.lst :     5
#      short-cfg.lst :    15
#     medium-cfg.lst :    55
#      large-cfg.lst :   179
#     Xlarge-cfg.lst :   691
#        all-cfg.lst : 12962

n=$(cat $1 | wc -l)
cnt=0

for cfg1 in $(cat $1); do
for cfg2 in $(cat $1); do

  cnt=$((cnt+1))
  clear
  echo "$cnt/$((n*n))"

  ./run-one.sh ../samples/$cfg1 ../samples/$cfg2 $2 "$3" "$4" "$5" "$6"
done; done

