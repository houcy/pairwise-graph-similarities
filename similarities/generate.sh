#!/bin/bash

#
# USAGE: ./generate.sh "1 2 3" "1 16 64"
#   - param 1: list of versions    [default: 1 through 24]
#   - param 2: list of chunk sizes [default: 1 2 4 ... 256]
#

SIMILARITIES_DIR=.
OBJS_DIR=$SIMILARITIES_DIR/objs
BINS_DIR=$SIMILARITIES_DIR/bins

SPGK_SRC=../lib/spgk.cpp

make -C ../lib vector-kernels.o timer.o graph-loader.o jsonxx.o &> /dev/null
make -C ../src run-cfg.o &> /dev/null
BASE_OBJS="../src/run-cfg.o ../lib/vector-kernels.o ../lib/timer.o ../lib/graph-loader.o ../lib/jsonxx.o"

mkdir -p $OBJS_DIR $BINS_DIR

#CXX_FLAGS="-O0 -g -fopenmp"
CXX_FLAGS="-O3 -fopenmp"
LD_FLAGS="-fopenmp -lrt"

> $SIMILARITIES_DIR/errors.log

versions=$1
[ -z "$versions" ] && versions=$(seq 1 24)
nversions=$(wc -w <<< "$versions")

chunks=$2
[ -z "$chunks" ] && chunks=$(for chunk in $(seq 0 8); do echo "$((1<<chunk))"; done)
nchunks=$(wc -w <<< "$chunks")

loops=$3
[ -z "$loops" ] && loops=$(seq 1 4)
nloops=$(wc -w <<< "$loops")

n=$((nversions*nloops*nchunks))
cnt=0

for omp_spgk in $versions; do
  for omp_spgk_loop in $loops; do
    for spgk_chunk in $chunks; do

      config="-DOMP_SPGK=$omp_spgk -DOMP_SPGK_LOOP=$omp_spgk_loop -DSPGK_CHUNK=$spgk_chunk"
      suffix="v_$omp_spgk-l_$omp_spgk_loop-c_$spgk_chunk"

      cnt=$((cnt+1))

      echo -ne "\r                                                                 \rBuilding spgk-$suffix ($cnt/$n)"

      g++ $CXX_FLAGS $config -c $SPGK_SRC -o $OBJS_DIR/spgk-$suffix.o &> $OBJS_DIR/spgk-$suffix.log
      [ $? -ne 0 ] && echo "  compile: $OBJS_DIR/spgk-$suffix.log" >> $SIMILARITIES_DIR/errors.log && continue
      g++ $LD_FLAGS $OBJS_DIR/spgk-$suffix.o $BASE_OBJS -o $BINS_DIR/spgk-$suffix &> $BINS_DIR/spgk-$suffix.log
      [ $? -ne 0 ] && echo "  link:    $BINS_DIR/spgk-$suffix.log" >> $SIMILARITIES_DIR/errors.log
    done
  done
done
echo

if [ -s $SIMILARITIES_DIR/errors.log ]; then
  echo "Errors:"
  cat $SIMILARITIES_DIR/errors.log
fi
