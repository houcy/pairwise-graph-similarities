#!/bin/bash

#
# USAGE: ./run.sh -d work_dir -s samples_dir -cfg cfgs.lst -v "loop nest versions list" -l "parallel loop list" -c "chunks size list" -t "num threads list" -n number_runs
#
# Lists of different length are provided:
#     Xshort-cfg.lst :     5
#      short-cfg.lst :    15
#     medium-cfg.lst :    55
#      large-cfg.lst :   179
#     Xlarge-cfg.lst :   691
#        all-cfg.lst : 12962
#

while [ ! -z $1 ]; do
  if   [ "$1" == "-d"   ]; then work_dir=$2;    shift 2;
  elif [ "$1" == "-s"   ]; then samples_dir=$2; shift 2;
  elif [ "$1" == "-cfg" ]; then cfg_lst=$2;     shift 2;
  elif [ "$1" == "-v"   ]; then versions=$2;    shift 2;
  elif [ "$1" == "-c"   ]; then chunks=$2;      shift 2;
  elif [ "$1" == "-l"   ]; then loops=$2;       shift 2;
  elif [ "$1" == "-t"   ]; then numthreads=$2;  shift 2;
  elif [ "$1" == "-n"   ]; then nruns=$2;       shift 2;
  else echo "Unknown option: \"$1\""; shift 1; fi
done

[ -z "$work_dir" ]    && echo "Missing work directory: \"-d work_dir\""        && exit 1
[ -z "$samples_dir" ] && echo "Missing samples directory:  \"-s samples_dir\"" && exit 1
[ -z "$cfg_lst" ]     && echo "Missing list of CFGs:  \"-cfg cfgs.lst\""       && exit 1

[ -z "$versions" ] && versions="1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24"
nversions=$(echo $versions | tr ',' ' ' | wc -w)

[ -z "$loops" ] && loops="1,2,3,4"
nloops=$(echo $loops | tr ',' ' ' | wc -w)

[ -z "$chunks" ] && chunks="1,2,4,8,16,32,64,128,256"
nchunks=$(echo $chunks | tr ',' ' ' | wc -w)

[ -z "$numthreads" ] && numthreads=$(nproc)
nnumthreads=$(echo $numthreads | tr ',' ' ' | wc -w)

[ -z "$nruns" ] && nruns=3

n=$(cat $cfg_lst | wc -l)
cnt=0

for cfg1 in $(shuf $cfg_lst); do
for cfg2 in $(shuf $cfg_lst); do

  cnt=$((cnt+1))
  clear
  echo "$cnt/$((n*n))"

  ./run-one.sh -verbose -cfgs $cfg1 $cfg2 -d $work_dir -s $samples_dir -v "$versions" -l "$loops" -c "$chunks" -t "$numthreads" -n $nruns
done; done

