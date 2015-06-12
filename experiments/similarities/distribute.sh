#!/bin/bash

while [ ! -z $1 ]; do
  if   [ "$1" == "-D"   ]; then data_dir=$2;    shift 2;
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

[ -z "$base_dir" ] && base_dir=$(pwd)

[ -z "$versions" ] && versions="1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24"
nversions=$(echo $versions | tr ',' ' ' | wc -w)

[ -z "$loops" ] && loops="1,2,3,4"
nloops=$(echo $loops | tr ',' ' ' | wc -w)

[ -z "$chunks" ] && chunks="1,2,4,8,16,32,64,128,256"
nchunks=$(echo $chunks | tr ',' ' ' | wc -w)

[ -z "$numthreads" ] && numthreads=$(nproc)
nnumthreads=$(echo $numthreads | tr ',' ' ' | wc -w)

[ -z "$nruns" ] && nruns=3

[ -z "$data_dir" ] && data_dir=$base_dir/$job_name-data

script_dir=$(dirname $(readlink -f $0))

[ ! -e $data_dir ] && $script_dir/generate.sh -d $data_dir -v $versions -l $loops -c $chunks

static_arguments="-d $base_dir -D $data_dir -s $samples_dir -cfg $cfg_lst -n $nruns -N 1"

for v in $(echo $versions   | tr ',' ' '); do
for l in $(echo $loops      | tr ',' ' '); do
#for c in $(echo $chunks     | tr ',' ' '); do
#for t in $(echo $numthreads | tr ',' ' '); do
# sub_job_name=$job_name-v_$v-l_$l-c_$c-t_$t
# $script_dir/run-slurm.sh $static_arguments -j $sub_job_name -v $v -l $l -c $c -t $t
  sub_job_name=$job_name-v_$v-l_$l
  $script_dir/run-slurm.sh $static_arguments -j $sub_job_name -v $v -l $l -c $chunks -t $numthreads
#done; done;
done; done
