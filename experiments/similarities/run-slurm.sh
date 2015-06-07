#!/bin/bash

while [ ! -z $1 ]; do
  if   [ "$1" == "-d"   ]; then base_dir=$2;    shift 2;
  elif [ "$1" == "-s"   ]; then samples_dir=$2; shift 2;
  elif [ "$1" == "-j"   ]; then job_name=$2;    shift 2;
  elif [ "$1" == "-cfg" ]; then cfg_lst=$2;     shift 2;
  elif [ "$1" == "-v"   ]; then versions=$2;    shift 2;
  elif [ "$1" == "-c"   ]; then chunks=$2;      shift 2;
  elif [ "$1" == "-l"   ]; then loops=$2;       shift 2;
  elif [ "$1" == "-t"   ]; then numthreads=$2;  shift 2;
  elif [ "$1" == "-n"   ]; then nruns=$2;       shift 2;
  else echo "Unknown option: \"$1\""; shift 1; fi
done

[ -z "$job_name" ]    && echo "Missing job name: \"-j job_name\""        && exit 1
[ -z "$samples_dir" ] && echo "Missing samples directory:  \"-s samples_dir\"" && exit 1
[ -z "$cfg_lst" ]     && echo "Missing list of CFGs:  \"-cfg cfgs.lst\""       && exit 1

[ -z "$base_dir" ]    && base_dir=$(pwd)

[ -z "$versions" ] && versions="1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24"
nversions=$(echo $versions | tr ',' ' ' | wc -w)

[ -z "$loops" ] && loops="1,2,3,4"
nloops=$(echo $loops | tr ',' ' ' | wc -w)

[ -z "$chunks" ] && chunks="1,2,4,8,16,32,64,128,256"
nchunks=$(echo $chunks | tr ',' ' ' | wc -w)

[ -z "$numthreads" ] && numthreads=$(nproc)
nnumthreads=$(echo $numthreads | tr ',' ' ' | wc -w)

[ -z "$nruns" ] && nruns=3

script_dir=$(pwd)

cd $base_dir

for cfg1 in $(shuf $cfg_lst); do
for cfg2 in $(shuf $cfg_lst); do
  echo "$cfg1,$cfg2"
done; done | shuf > $job_name.csv

[ ! -e $base_dir/$job_name-data ] && ./generate.sh -d $base_dir/$job_name-data -v $versions -l $loops -c $chunks

stool-batch $script_dir/run-one.sh $job_name 10 1 -d $base_dir/$job_name-data -s $samples_dir -v $versions -l $loops -c $chunks -t $numthreads -n $nruns -cfgs

