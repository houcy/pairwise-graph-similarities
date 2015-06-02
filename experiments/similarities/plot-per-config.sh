#!/bin/bash

work_dir=$1

shift 1

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

runs_dir=$work_dir/runs
results_dir=$work_dir/plot-configs

rm -rf $results_dir
mkdir -p $results_dir

n=$((nversions*nloops*nchunks*nnumthreads))
cnt=0

echo "set term pngcairo enhanced font 'Verdana,12' size $((400*$nloops)),$((400*$nversions))" > $results_dir/plot-per-config-cfg-nodes.plg
echo "set term pngcairo enhanced font 'Verdana,12' size $((400*$nloops)),$((400*$nversions))" > $results_dir/plot-per-config-cfg-edges.plg
echo "set term pngcairo enhanced font 'Verdana,12' size $((400*$nloops)),$((400*$nversions))" > $results_dir/plot-per-config-cfg-edges-after-fw.plg

cat plot.head.plg >> $results_dir/plot-per-config-cfg-nodes.plg
cat plot.head.plg >> $results_dir/plot-per-config-cfg-edges.plg
cat plot.head.plg >> $results_dir/plot-per-config-cfg-edges-after-fw.plg

outs0=""
outs1=""
outs2=""
datafiles=""

for spgk_chunk in $chunks; do
  for numthread in $numthreads; do

    echo "set output \"$results_dir/spgk-cfg-nodes-c_$spgk_chunk-n_$numthread.png\"" >> $results_dir/plot-per-config-cfg-nodes.plg
    echo "set multiplot layout $nversions,$nloops title \"SPGK computation time,\\nfunction of the number of Nodes.\\n$spgk_chunk chunks and $numthread threads.\"" >> $results_dir/plot-per-config-cfg-nodes.plg
    outs0="$outs0 $results_dir/spgk-cfg-nodes-c_$spgk_chunk-n_$numthread.png"

    echo "set output \"$results_dir/spgk-cfg-edges-c_$spgk_chunk-n_$numthread.png\"" >> $results_dir/plot-per-config-cfg-edges.plg
    echo "set multiplot layout $nversions,$nloops title \"SPGK computation time,\\nfunction of the number of Edges (original graph).\\n$spgk_chunk chunks and $numthread threads.\"" >> $results_dir/plot-per-config-cfg-edges.plg
    outs1="$outs1 $results_dir/spgk-cfg-edges-c_$spgk_chunk-n_$numthread.png"

    echo "set output \"$results_dir/spgk-cfg-edges-after-fw-c_$spgk_chunk-n_$numthread.png\"" >> $results_dir/plot-per-config-cfg-edges-after-fw.plg
    echo "set multiplot layout $nversions,$nloops title \"SPGK computation time,\\nfunction of the number of Edges (shortest path graph).\\n$spgk_chunk chunks and $numthread threads.\"" >> $results_dir/plot-per-config-cfg-edges-after-fw.plg
    outs2="$outs2 $results_dir/spgk-cfg-edges-after-fw-c_$spgk_chunk-n_$numthread.png"

    for omp_spgk in $versions; do
      for omp_spgk_loop in $loops; do

      tag="v_$omp_spgk-l_$omp_spgk_loop-c_$spgk_chunk-n_$numthread"
      cnt=$((cnt+1))

      cat $runs_dir/spgk-$tag.csv | tr ',' ' ' > $results_dir/$tag.data
      datafiles="$datafiles $results_dir/$tag.data"

      echo "set title \"Loop permutation #$omp_spgk.\\nLoop #$omp_spgk_loop is parallelized with OpenMP.\"" >> $results_dir/plot-per-config-cfg-nodes.plg
      echo "splot '$results_dir/$tag.data' using 1:4:7 notitle" >> $results_dir/plot-per-config-cfg-nodes.plg

      echo "set title \"Loop permutation #$omp_spgk.\\nLoop #$omp_spgk_loop is parallelized with OpenMP.\"" >> $results_dir/plot-per-config-cfg-edges.plg
      echo "splot '$results_dir/$tag.data' using 1:4:7 notitle" >> $results_dir/plot-per-config-cfg-edges.plg

      echo "set title \"Loop permutation #$omp_spgk.\\nLoop #$omp_spgk_loop is parallelized with OpenMP.\"" >> $results_dir/plot-per-config-cfg-edges-after-fw.plg
      echo "splot '$results_dir/$tag.data' using 1:4:7 notitle" >> $results_dir/plot-per-config-cfg-edges-after-fw.plg

      done
    done
    echo "unset multiplot" >> $results_dir/plot-per-config-cfg-nodes.plg
    echo "unset multiplot" >> $results_dir/plot-per-config-cfg-edges.plg
    echo "unset multiplot" >> $results_dir/plot-per-config-cfg-edges-after-fw.plg
  done
done

gnuplot $results_dir/plot-per-config-cfg-nodes.plg
gnuplot $results_dir/plot-per-config-cfg-edges.plg
gnuplot $results_dir/plot-per-config-cfg-edges-after-fw.plg

#rm -f $datafiles
#rm -f $results_dir/plot-per-config-cfg-nodes.plg $results_dir/plot-per-config-cfg-edges.plg $results_dir/plot-per-config-cfg-edges-after-fw.plg

echo "$outs0"
echo "$outs1"
echo "$outs2"

#firefox $outs0 $outs1 $outs2

