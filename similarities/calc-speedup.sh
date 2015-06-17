#!/bin/bash

SIMILARITIES_DIR=.
RUNS_DIR=$SIMILARITIES_DIR/runs2


versions=$1
[ -z "$versions" ] && versions=$(seq 1 24)
nversions=$(wc -w <<< "$versions")

static=" static"
chunks=$2
[ -z "$chunks" ] && chunks=$(for chunk in $(seq 0 7); do echo "$((1<<chunk))"; done)
chunks=$chunks$static
nchunks=$(wc -w <<< "$chunks")

loops=$3
[ -z "$loops" ] && loops=$(seq 1 4)
nloops=$(wc -w <<< "$loops")

numthreads=$4
[ -z "$numthreads" ] && numthreads=$(nproc)
nnumthreads=$(wc -w <<< "$numthreads")


n=$((nversions*nloops*nchunks*nnumthreads))
cnt=0

seq_results_file=$RUNS_DIR/spgk-seq-results.csv
chunk=0
for spgk_chunk in $chunks; do
for numthread in $numthreads; do
for omp_spgk in $versions; do
for omp_spgk_loop in $loops; do

  tag="v_$omp_spgk-l_$omp_spgk_loop-s_d-c_$spgk_chunk-n_$numthread"
  echo $tag
  cnt=$((cnt+1))
  # tag="v_1-l_1-s_d-c_1-n_48"
  while read -r seq_line
  do
      seq_comp=$(echo $seq_line | awk -F, '{print $1$2$3$4$5$6}')
      # echo $seq_comp
      # seq_res=$(echo $line | awk -F, '{print $7}')
      # echo $seq_res
      seq_time=$(echo $seq_line | awk -F, '{print $8}')

      while read -r par_line
      do
        par_comp=$(echo $par_line | awk -F, '{print $1$2$3$4$5$6}')
        par_time=$(echo $par_line | awk -F, '{print $8}')
        if [ "$seq_comp" = "$par_comp" ]
          then
            speedup=$(bc -l <<< $seq_time/$par_time)
            echo "$par_line,$speedup" >> $RUNS_DIR/spgk-$tag-speedup.csv
            # version=$(($omp_spgk - 1))
            # version=$(($version * 4))
            # version=$(($version+$omp_spgk_loop))
            # echo "$version $chunk $speedup" >> $RUNS_DIR/$seq_comp-speedup.csv
        fi
      done < $RUNS_DIR/spgk-$tag.csv
  done < $seq_results_file

done
done
done
chunk=$(($chunk + 1))
done
