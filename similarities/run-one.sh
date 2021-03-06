#!/bin/bash

#
# USAGE: ./run-one.sh cfg1.json cfg2.json 3 "1 2 3" "1 16 64" "4 8"
#   - param 1: First CFG           [no default]
#   - param 2: Second CFG          [no default]
#   - param 3: number of runs      [default: 3]
#   - param 4: list of versions    [default: 1 through 24]
#   - param 5: list of chunk sizes [default: 1 2 4 ... 256]
#   - param 6: list of num threads [default: result of 'nproc' command]
#

SIMILARITIES_DIR=.
BINS_DIR=$SIMILARITIES_DIR/bins
RUNS_DIR=$SIMILARITIES_DIR/runs

mkdir -p $RUNS_DIR

n=$((24*4*9))
cnt=0

cfg1=$1
[ -z $cfg1 ] && echo "Missing 1st CFG !" && exit

cfg2=$2
[ -z $cfg2 ] && echo "Missing 2nd CFG !" && exit

nruns=$3
[ -z $nruns ] && nruns=3

#echo "nruns=$nruns"

versions=$4
[ -z "$versions" ] && versions=$(seq 1 24)
nversions=$(wc -w <<< "$versions")

#echo "versions=$versions"

chunks=$5
[ -z "$chunks" ] && chunks=$(for chunk in $(seq 0 7); do echo "$((1<<chunk))"; done)
nchunks=$(wc -w <<< "$chunks")

#echo "chunks=$chunks"

loops=$6
[ -z "$loops" ] && loops=$(seq 1 4)
nloops=$(wc -w <<< "$loops")

numthreads=$7
[ -z "$numthreads" ] && numthreads=$(nproc)
nnumthreads=$(wc -w <<< "$numthreads")

#echo "numthreads=$numthreads"

n=$((nversions*nloops*nchunks))
cnt=0

echo " > $cfg1"
echo " > $cfg2"

seq_results=$( ./../run-cfg-seq $cfg1 $cfg2 )
seq_time=$( echo "$seq_results" | tr ',' ' ' | awk '{print $8}')
echo $seq_results | tr ' ' ',' >> $RUNS_DIR/spgk-seq-results.csv
echo "Sequential time: $seq_time"
seq_time_secs=$(echo "$seq_time" | sed "s/...$//g")
[ -z $seq_time_secs ] && seq_time_secs=1
echo "Sequential secs: $seq_time_secs"
for omp_spgk in $versions; do
  for omp_spgk_loop in $loops; do
    for statruns in $(seq 1 $nruns); do
	for num_thread in $numthreads; do
        export OMP_SCHEDULE="static"
        export OMP_NUM_THREADS=$num_thread
         suffix="v_$omp_spgk-l_$omp_spgk_loop"
	echo -ne "\r                                                                   \r > Running spgk-$suffix ($cnt/$n) for $num_thread for static"
        timeout $seq_time_secs ./$BINS_DIR/spgk-$suffix $cfg1 $cfg2 >> $RUNS_DIR/spgk-$suffix-s_d-c_static-n_$num_thread.csv;
    done    
    done
    for spgk_chunk in $chunks; do

      suffix="v_$omp_spgk-l_$omp_spgk_loop"
      cnt=$((cnt+1))

      for numthread in $numthreads; do

        echo -ne "\r                                                                   \r > Running spgk-$suffix ($cnt/$n) for $numthread for dynamic chunksize $spgk_chunk"

        for c in $(seq 1 $nruns); do
          export OMP_SCHEDULE="dynamic,$spgk_chunk" 
          export OMP_NUM_THREADS=$numthread 
	  timeout $seq_time_secs ./$BINS_DIR/spgk-$suffix $cfg1 $cfg2 >> $RUNS_DIR/spgk-$suffix-s_d-c_$spgk_chunk-n_$numthread.csv;
        done
      done
    done
  done
done
echo

