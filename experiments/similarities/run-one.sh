#!/bin/bash

verbose=0
while [ ! -z $1 ]; do
  if   [ "$1" == "-verbose" ]; then verbose=1;        shift 1;
  elif [ "$1" == "-cfgs"    ]; then cfg1=$2; cfg2=$3; shift 3;
  elif [ "$1" == "-d"       ]; then work_dir=$2;      shift 2;
  elif [ "$1" == "-s"       ]; then samples_dir=$2;   shift 2;
  elif [ "$1" == "-v"       ]; then versions=$2;      shift 2;
  elif [ "$1" == "-c"       ]; then chunks=$2;        shift 2;
  elif [ "$1" == "-l"       ]; then loops=$2;         shift 2;
  elif [ "$1" == "-t"       ]; then numthreads=$2;    shift 2;
  elif [ "$1" == "-n"       ]; then nruns=$2;         shift 2;
  else echo "Unknown option: \"$1\""; shift 1; fi
done

[ -z "$work_dir" ]    && echo "Missing work directory: \"-d work_dir\""        && exit 1
[ -z "$samples_dir" ] && echo "Missing samples directory:  \"-s samples_dir\"" && exit 1
[ -z "$cfg1" ]        && echo "Missing CFG 1:  \"-cfgs cfg1 cfg2\""            && exit 1
[ -z "$cfg2" ]        && echo "Missing CFG 2:  \"-cfgs cfg1 cfg2\""            && exit 1

[ -z "$versions" ] && versions="1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24"
nversions=$(echo $versions | tr ',' ' ' | wc -w)

[ -z "$loops" ] && loops="1,2,3,4"
nloops=$(echo $loops | tr ',' ' ' | wc -w)

[ -z "$chunks" ] && chunks="1,2,4,8,16,32,64,128,256"
nchunks=$(echo $chunks | tr ',' ' ' | wc -w)

[ -z "$numthreads" ] && numthreads=$(nproc)
nnumthreads=$(echo $numthreads | tr ',' ' ' | wc -w)

[ -z "$nruns" ] && nruns=3

n=$((nversions*nloops*nchunks*nnumthreads))
cnt=0

bins_dir=$work_dir/bins
runs_dir=$work_dir/runs

mkdir -p $runs_dir

[ $verbose -ne 0 ] && echo " > $samples_dir"
[ $verbose -ne 0 ] && echo " > $cfg1"
[ $verbose -ne 0 ] && echo " > $cfg2"

for omp_spgk in $(echo $versions | tr ',' ' '); do
  for omp_spgk_loop in $(echo $loops | tr ',' ' '); do
    for spgk_chunk in $(echo $chunks | tr ',' ' '); do

      suffix="v_$omp_spgk-l_$omp_spgk_loop-c_$spgk_chunk"

      for numthread in $(echo $numthreads | tr ',' ' '); do
        cnt=$((cnt+1))
        [ $verbose -ne 0 ] && echo -ne "\r                                                                   \r > Running spgk-$suffix for $numthread ($cnt/$n)"

        for c in $(seq 1 $nruns); do
          OMP_NUM_THREADS=$numthread $bins_dir/spgk-$suffix $samples_dir/$cfg1 $samples_dir/$cfg2 >> $runs_dir/spgk-$suffix-n_$numthread.csv
        done
      done
    done
  done
done
echo

