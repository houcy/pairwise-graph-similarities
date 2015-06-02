#!/bin/bash

#
# USAGE: ./run.sh short-cfg.lst 3 "1 2 3" "1 16 64" "4 8"
#   - param 1: work directory      [no default]
#   - param 2: samples directory   [no default]
#   - param 3: list of CFG files   [no default]
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

work_dir=$1
[ -z $work_dir ] && echo "Missing work directory !" && exit

samples_dir=$2
[ -z $samples_dir ] && echo "Missing samples directory !" && exit

cfg_lst=$3

shift 3

n=$(cat $cfg_lst | wc -l)
cnt=0

for cfg1 in $(shuf $cfg_lst); do
for cfg2 in $(shuf $cfg_lst); do

  cnt=$((cnt+1))
  clear
  echo "$cnt/$((n*n))"

  ./run-one.sh -v $cfg1 $cfg2 $work_dir $samples_dir $1 "$2" "$3" "$4" "$5"
done; done

