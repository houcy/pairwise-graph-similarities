#!/bin/bash

SIMILARITIES_DIR=.
RUNS_DIR=$SIMILARITIES_DIR/runs2
mkdir -p $RESULTS_DIR

versions=$1
[ -z "$versions" ] && versions=$(seq 1 24)
nversions=$(wc -w <<< "$versions")

static="static "
chunks=$2
[ -z "$chunks" ] && chunks=$(for chunk in $(seq 0 7); do echo "$((1<<chunk))"; done)
chunks=$static$chunks
nchunks=$(wc -w <<< "$chunks")

loops=$3
[ -z "$loops" ] && loops=$(seq 1 4)
nloops=$(wc -w <<< "$loops")

numthreads=$4
[ -z "$numthreads" ] && numthreads=48
nnumthreads=$(wc -w <<< "$numthreads")



amalg_sig=$nversions-$nchunks-$nloops-$nnumthreads
SPEEDUP_DIR=$RUNS_DIR/$amalg_sig

mkdir -p $SPEEDUP_DIR
n=$((nversions*nloops*nchunks*nnumthreads))
cnt=0

seq_results_file=$RUNS_DIR/spgk-seq-results.csv
while read -r seq_line
do
    seq_comp=$(echo $seq_line | awk -F, '{print $1$2$3$4$5$6}')
    seq_time=$(echo $seq_line | awk -F, '{print $8}')

    chunk=0
    for spgk_chunk in $chunks; do
    for numthread in $numthreads; do
    for omp_spgk in $versions; do
    for omp_spgk_loop in $loops; do

      tag="v_$omp_spgk-l_$omp_spgk_loop-s_d-c_$spgk_chunk-n_$numthread"
      # echo $tag
      version=$(($omp_spgk - 1))
      version=$(($version * $nloops))
      version=$(($version+$omp_spgk_loop))
      speedup=1
      while read -r par_line
      do
        par_comp=$(echo $par_line | awk -F, '{print $1$2$3$4$5$6}')
        if [ $par_comp == $seq_comp ]
          then
            speedup=$(echo $par_line | awk -F, '{print $9}')
            echo "$speedup"
        fi
      done < $RUNS_DIR/spgk-$tag-speedup.csv
      echo "$chunk $version $speedup" >> $SPEEDUP_DIR/$seq_comp-speedup.ssv

    done
    done
    done
    echo "" >> $SPEEDUP_DIR/$seq_comp-speedup.ssv
    chunk=$(($chunk + 1))
    done
done < $seq_results_file
