#!/bin/bash

SIMILARITIES_DIR=.
RUNS_DIR=$SIMILARITIES_DIR/runs
RESULTS_DIR=$SIMILARITIES_DIR/results

mkdir -p $RESULTS_DIR

versions=$1
[ -z "$versions" ] && versions=$(seq 1 24)
nversions=$(wc -w <<< "$versions")

chunks=$2
[ -z "$chunks" ] && chunks=$(for chunk in $(seq 0 8); do echo "$((1<<chunk))"; done)
nchunks=$(wc -w <<< "$chunks")

loops=$3
[ -z "$loops" ] && loops=$(seq 1 4)
nloops=$(wc -w <<< "$loops")

numthreads=$4
[ -z "$numthreads" ] && numthreads=$(nproc)
nnumthreads=$(wc -w <<< "$numthreads")

n=$((nversions*nloops*nchunks*nnumthreads))
cnt=0

echo "set term pngcairo enhanced font 'Verdana,12' size $((400*$nnumthreads)),$((400*$nchunks))" > plot-per-loop-cfg-nodes.plg
echo "set term pngcairo enhanced font 'Verdana,12' size $((400*$nnumthreads)),$((400*$nchunks))" > plot-per-loop-cfg-edges.plg
echo "set term pngcairo enhanced font 'Verdana,12' size $((400*$nnumthreads)),$((400*$nchunks))" > plot-per-loop-cfg-edges-after-fw.plg

cat plot.head.plg >> plot-per-loop-cfg-nodes.plg
cat plot.head.plg >> plot-per-loop-cfg-edges.plg
cat plot.head.plg >> plot-per-loop-cfg-edges-after-fw.plg

outs0=""
outs1=""
outs2=""
datafiles=""

for omp_spgk in $versions; do
  for omp_spgk_loop in $loops; do

    echo "set output \"$RESULTS_DIR/spgk-cfg-nodes-v_$omp_spgk-l_$omp_spgk_loop.png\"" >> plot-per-loop-cfg-nodes.plg
    echo "set multiplot layout $nchunks,$nnumthreads title \"SPGK computation time,\\nfunction of the number of Nodes.\\nLoop permutation #$omp_spgk.\\nLoop #$omp_spgk_loop is parallelized with OpenMP.\"" >> plot-per-loop-cfg-nodes.plg
    outs0="$outs0 $RESULTS_DIR/spgk-cfg-nodes-v_$omp_spgk-l_$omp_spgk_loop.png"

    echo "set output \"$RESULTS_DIR/spgk-cfg-edges-v_$omp_spgk-l_$omp_spgk_loop.png\"" >> plot-per-loop-cfg-edges.plg
    echo "set multiplot layout $nchunks,$nnumthreads title \"SPGK computation time,\\nfunction of the number of Edges (original graph).\\nLoop permutation #$omp_spgk.\\nLoop #$omp_spgk_loop is parallelized with OpenMP.\"" >> plot-per-loop-cfg-edges.plg
    outs1="$outs1 $RESULTS_DIR/spgk-cfg-edges-v_$omp_spgk-l_$omp_spgk_loop.png"

    echo "set output \"$RESULTS_DIR/spgk-cfg-edges-after-fw-v_$omp_spgk-l_$omp_spgk_loop.png\"" >> plot-per-loop-cfg-edges-after-fw.plg
    echo "set multiplot layout $nchunks,$nnumthreads title \"SPGK computation time,\\nfunction of the number of Edges (shortest path graph).\\nLoop permutation #$omp_spgk.\\nLoop #$omp_spgk_loop is parallelized with OpenMP.\"" >> plot-per-loop-cfg-edges-after-fw.plg
    outs2="$outs2 $RESULTS_DIR/spgk-cfg-edges-after-fw-v_$omp_spgk-l_$omp_spgk_loop.png"

    for spgk_chunk in $chunks; do
      for numthread in $numthreads; do

      tag="v_$omp_spgk-l_$omp_spgk_loop-c_$spgk_chunk-n_$numthread"
      cnt=$((cnt+1))

      cat $RUNS_DIR/spgk-$tag.csv | tr ',' ' ' > $tag.data
      datafiles="$datafiles $tag.data"

      echo "set title \"$spgk_chunk chunks and $numthread threads.\"" >> plot-per-loop-cfg-nodes.plg
      echo "splot '$tag.data' using 1:4:7 notitle" >> plot-per-loop-cfg-nodes.plg

      echo "set title \"$spgk_chunk chunks and $numthread threads.\"" >> plot-per-loop-cfg-edges.plg
      echo "splot '$tag.data' using 1:4:7 notitle" >> plot-per-loop-cfg-edges.plg

      echo "set title \"$spgk_chunk chunks and $numthread threads.\"" >> plot-per-loop-cfg-edges-after-fw.plg
      echo "splot '$tag.data' using 1:4:7 notitle" >> plot-per-loop-cfg-edges-after-fw.plg

      done
    done
    echo "unset multiplot" >> plot-per-loop-cfg-nodes.plg
    echo "unset multiplot" >> plot-per-loop-cfg-edges.plg
    echo "unset multiplot" >> plot-per-loop-cfg-edges-after-fw.plg
  done
done

gnuplot plot-per-loop-cfg-nodes.plg
gnuplot plot-per-loop-cfg-edges.plg
gnuplot plot-per-loop-cfg-edges-after-fw.plg

rm -f $datafiles
rm -f plot-per-loop-cfg-nodes.plg plot-per-loop-cfg-edges.plg plot-per-loop-cfg-edges-after-fw.plg

firefox $outs0 $outs1 $outs2



