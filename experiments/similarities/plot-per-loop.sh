#!/bin/bash

while [ ! -z $1 ]; do
  if   [ "$1" == "-d"   ]; then work_dir=$2;    shift 2;
  elif [ "$1" == "-v"   ]; then versions=$2;    shift 2;
  elif [ "$1" == "-c"   ]; then chunks=$2;      shift 2;
  elif [ "$1" == "-l"   ]; then loops=$2;       shift 2;
  elif [ "$1" == "-t"   ]; then numthreads=$2;  shift 2;
  else exit 1; fi
done

[ -z "$work_dir" ]    && echo "Missing work directory: \"-d work_dir\""        && exit 1

[ -z "$versions" ] && versions=$(seq 1 24)
nversions=$(wc -w <<< "$versions")

[ -z "$loops" ] && loops=$(seq 1 4)
nloops=$(wc -w <<< "$loops")

[ -z "$chunks" ] && chunks=$(for chunk in $(seq 0 8); do echo "$((1<<chunk))"; done)
nchunks=$(wc -w <<< "$chunks")

[ -z "$numthreads" ] && numthreads=$(nproc)
nnumthreads=$(wc -w <<< "$numthreads")

runs_dir=$work_dir/runs
results_dir=$work_dir/plot-loops

rm -rf $results_dir
mkdir -p $results_dir

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

    echo "set output \"$results_dir/spgk-cfg-nodes-v_$omp_spgk-l_$omp_spgk_loop.png\"" >> plot-per-loop-cfg-nodes.plg
    echo "set multiplot layout $nchunks,$nnumthreads title \"SPGK computation time,\\nfunction of the number of Nodes.\\nLoop permutation #$omp_spgk.\\nLoop #$omp_spgk_loop is parallelized with OpenMP.\"" >> plot-per-loop-cfg-nodes.plg
    outs0="$outs0 $results_dir/spgk-cfg-nodes-v_$omp_spgk-l_$omp_spgk_loop.png"

    echo "set output \"$results_dir/spgk-cfg-edges-v_$omp_spgk-l_$omp_spgk_loop.png\"" >> plot-per-loop-cfg-edges.plg
    echo "set multiplot layout $nchunks,$nnumthreads title \"SPGK computation time,\\nfunction of the number of Edges (original graph).\\nLoop permutation #$omp_spgk.\\nLoop #$omp_spgk_loop is parallelized with OpenMP.\"" >> plot-per-loop-cfg-edges.plg
    outs1="$outs1 $results_dir/spgk-cfg-edges-v_$omp_spgk-l_$omp_spgk_loop.png"

    echo "set output \"$results_dir/spgk-cfg-edges-after-fw-v_$omp_spgk-l_$omp_spgk_loop.png\"" >> plot-per-loop-cfg-edges-after-fw.plg
    echo "set multiplot layout $nchunks,$nnumthreads title \"SPGK computation time,\\nfunction of the number of Edges (shortest path graph).\\nLoop permutation #$omp_spgk.\\nLoop #$omp_spgk_loop is parallelized with OpenMP.\"" >> plot-per-loop-cfg-edges-after-fw.plg
    outs2="$outs2 $results_dir/spgk-cfg-edges-after-fw-v_$omp_spgk-l_$omp_spgk_loop.png"

    for spgk_chunk in $chunks; do
      for numthread in $numthreads; do

      tag="v_$omp_spgk-l_$omp_spgk_loop-c_$spgk_chunk-n_$numthread"
      cnt=$((cnt+1))

      cat $runs_dir/spgk-$tag.csv | tr ',' ' ' > $tag.data
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

echo "$outs0"
echo "$outs1"
echo "$outs2"

#firefox $outs0 $outs1 $outs2



