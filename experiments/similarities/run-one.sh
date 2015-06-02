#!/bin/bash

#
# USAGE: ./run-one.sh cfg1.json cfg2.json 3 "1 2 3" "1 16 64" "4 8"
#   - param 1: First CFG           [no default]
#   - param 2: Second CFG          [no default]
#   - param 3: work directory      [no default]
#   - param 4: samples directory   [no default]
#   - param 5: number of runs      [default: 3]
#   - param 6: list of versions    [default: 1 through 24]
#   - param 7: list of chunk sizes [default: 1 2 4 ... 256]
#   - param 8: list of num threads [default: result of 'nproc' command]
#

if [ "$1" == "-v" ]; then
  verbose=1
  shift 1
else
  verbose=0
fi

cfg1=$1
[ -z $cfg1 ] && echo "Missing 1st CFG !" && exit

cfg2=$2
[ -z $cfg2 ] && echo "Missing 2nd CFG !" && exit

work_dir=$3
[ -z $work_dir ] && echo "Missing work directory !" && exit

samples_dir=$4
[ -z $samples_dir ] && echo "Missing samples directory !" && exit

shift 4

nruns=$1
[ -z $nruns ] && nruns=3

#echo "nruns=$nruns"

versions=$2
[ -z "$versions" ] && versions=$(seq 1 24)
nversions=$(wc -w <<< "$versions")

#echo "versions=$versions"

chunks=$3
[ -z "$chunks" ] && chunks=$(for chunk in $(seq 0 8); do echo "$((1<<chunk))"; done)
nchunks=$(wc -w <<< "$chunks")

#echo "chunks=$chunks"

loops=$4
[ -z "$loops" ] && loops=$(seq 1 4)
nloops=$(wc -w <<< "$loops")

numthreads=$5
[ -z "$numthreads" ] && numthreads=$(nproc)
nnumthreads=$(wc -w <<< "$numthreads")

#echo "numthreads=$numthreads"

n=$((nversions*nloops*nchunks*nnumthreads))
cnt=0

bins_dir=$work_dir/bins
runs_dir=$work_dir/runs

mkdir -p $runs_dir

[ $verbose -ne 0 ] && echo " > $samples_dir"
[ $verbose -ne 0 ] && echo " > $cfg1"
[ $verbose -ne 0 ] && echo " > $cfg2"

for omp_spgk in $versions; do
  for omp_spgk_loop in $loops; do
    for spgk_chunk in $chunks; do
      suffix="v_$omp_spgk-l_$omp_spgk_loop-c_$spgk_chunk"
      for numthread in $numthreads; do
        cnt=$((cnt+1))
        [ $verbose -ne 0 ] && echo -ne "\r                                                                   \r > Running spgk-$suffix ($cnt/$n) for $numthread"

        for c in $(seq 1 $nruns); do
          OMP_NUM_THREADS=$numthread ./$bins_dir/spgk-$suffix $samples_dir/$cfg1 $samples_dir/$cfg2 >> $runs_dir/spgk-$suffix-n_$numthread.csv
        done
      done
    done
  done
done
echo

