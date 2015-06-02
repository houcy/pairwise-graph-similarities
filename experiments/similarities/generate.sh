#!/bin/bash

#
# USAGE: ./generate.sh work_dir "1 2 3" "1 16 64"
#   - param 1: work directory
#   - param 2: list of versions    [default: 1 through 24]
#   - param 3: list of chunk sizes [default: 1 2 4 ... 256]
#

work_dir=$1

versions=$2
[ -z "$versions" ] && versions=$(seq 1 24)
nversions=$(wc -w <<< "$versions")

chunks=$3
[ -z "$chunks" ] && chunks=$(for chunk in $(seq 0 8); do echo "$((1<<chunk))"; done)
nchunks=$(wc -w <<< "$chunks")

loops=$4
[ -z "$loops" ] && loops=$(seq 1 4)
nloops=$(wc -w <<< "$loops")

n=$((nversions*nloops*nchunks))

objs_dir=$work_dir/objs
bins_dir=$work_dir/bins

spgk_src=../../lib/spgk.cpp

make -C ../../lib vector-kernels.o timer.o graph-loader.o jsonxx.o &> /dev/null
make -C ../../src run-cfg.o &> /dev/null
objs="../../src/run-cfg.o ../../lib/vector-kernels.o ../../lib/timer.o ../../lib/graph-loader.o ../../lib/jsonxx.o"

mkdir -p $objs_dir $bins_dir

#CXX_FLAGS="-O0 -g -fopenmp -I../../include"
CXX_FLAGS="-O3 -fopenmp -I../../include"
LD_FLAGS="-fopenmp -lrt"

cnt=0
> $work_dir/errors.log
for omp_spgk in $versions; do
  for omp_spgk_loop in $loops; do
    for spgk_chunk in $chunks; do

      config="-DOMP_SPGK=$omp_spgk -DOMP_SPGK_LOOP=$omp_spgk_loop -DSPGK_CHUNK=$spgk_chunk"
      suffix="v_$omp_spgk-l_$omp_spgk_loop-c_$spgk_chunk"

      cnt=$((cnt+1))

      echo -ne "\r                                                                 \rBuilding spgk-$suffix ($cnt/$n)"

      g++ $CXX_FLAGS $config -c $spgk_src -o $objs_dir/spgk-$suffix.o &> $objs_dir/spgk-$suffix.log
      [ $? -ne 0 ] && echo "  compile: $objs_dir/spgk-$suffix.log" >> $work_dir/errors.log && continue

      g++ $LD_FLAGS $objs_dir/spgk-$suffix.o $objs -o $bins_dir/spgk-$suffix &> $bins_dir/spgk-$suffix.log
      [ $? -ne 0 ] && echo "  link:    $bins_dir/spgk-$suffix.log" >> $work_dir/errors.log
    done
  done
done
echo

if [ -s $work_dir/errors.log ]; then
  echo "Errors:"
  cat $work_dir/errors.log
fi

