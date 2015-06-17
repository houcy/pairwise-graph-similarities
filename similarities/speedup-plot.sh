#!/bin/bash

SIMILARITIES_DIR=.
RUNS_DIR=$SIMILARITIES_DIR/runs2

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

n=$((nversions*nloops*nchunks*nnumthreads))
cnt=0
last_comp=" "

plot_file=$SPEEDUP_DIR/heatmap-matrix.plot

seq_results_file=$RUNS_DIR/spgk-seq-results.csv

comp_count=0
while read -r seq_line
do
  comp_count=$((comp_count+1))
done < $seq_results_file
matrix_dim=$(bc <<< "sqrt($comp_count)/1")

cat "plot-speedup-heatmap.head.plot" > $plot_file
echo "set term pngcairo enhanced font 'Verdana,12' size $((100*$matrix_dim*$nversions)),$((100*$matrix_dim*$nloops))" >> $plot_file
echo "set title 'Speedup of Parallel Permutations on XShort Dataset (SPGK2)'" >> $plot_file
echo "set multiplot layout $matrix_dim,$matrix_dim" >> $plot_file

while read -r seq_line
do

    seq_comp=$(echo $seq_line | awk -F, '{print $1$2$3$4$5$6}')
    seq_time=$(echo $seq_line | awk -F, '{print $8}')
    if [ $cnt -lt $matrix_dim ]
      then
        if [ $cnt == 0 ]
          then
          ylabel=$(echo $seq_line | awk -F, '{print $1, $2, $3}')
          echo "set ylabel '$ylabel'" >> $plot_file
          last_comp=$(echo $seq_line | awk -F, '{print $1$2$3}')
        fi
        key=$(echo $seq_line | awk -F, '{print $1, $2, $3}')
        echo "set x2label '$key'" >> $plot_file
    fi
    # [ -z "$last_comp" ] && last_comp=$(echo $seq_line | awk -F, '{print $1$2$3}') && echo "set key center set title comp"
    this_comp=$(echo $seq_line | awk -F, '{print $1$2$3}')
    if [ $last_comp != $this_comp ]
      then
        ylabel=$(echo $seq_line | awk -F, '{print $1, $2, $3}')
        echo "set ylabel '$ylabel \nSpeedup'" >> $plot_file
    fi

    echo "plot '$SPEEDUP_DIR/$seq_comp-speedup.ssv' using 2:1:3 with image, '$SPEEDUP_DIR/$seq_comp-speedup.ssv' using 2:1:(\$3 == 0 ? '' : sprintf('%0.2f',\$3) ) with labels" >> $plot_file
    echo "unset key" >> $plot_file
    echo "unset ylabel" >> $plot_file


    last_comp=$this_comp
    cnt=$((cnt+1))
done < $seq_results_file

gnuplot $plot_file
