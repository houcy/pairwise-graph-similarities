#!/bin/bash

#
# USAGE: ./generate.sh -d work_dir -v "loop nest versions list" -l "parallel loop list" -c "chunks size list"
#

while [ ! -z $1 ]; do
  if   [ "$1" == "-d"   ]; then work_dir=$2;    shift 2;
  elif [ "$1" == "-v"   ]; then versions=$2;    shift 2;
  elif [ "$1" == "-c"   ]; then chunks=$2;      shift 2;
  elif [ "$1" == "-l"   ]; then loops=$2;       shift 2;
  else echo "Unknown option: \"$1\""; shift 1; fi
done

[ -z "$work_dir" ] && echo "Missing work directory argument: \"-d work_dir\"" && exit 1

[ -z "$versions" ] && versions="1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24"
nversions=$(echo $versions | tr ',' ' ' | wc -w)

[ -z "$loops" ] && loops="1,2,3,4"
nloops=$(echo $loops | tr ',' ' ' | wc -w)

[ -z "$chunks" ] && chunks="1,2,4,8,16,32,64,128,256"
nchunks=$(echo $chunks | tr ',' ' ' | wc -w)

n=$((nversions*nloops*nchunks))

script_dir=$(dirname $(readlink -f $0))

objs_dir=$work_dir/objs
bins_dir=$work_dir/bins

spgk_src=$script_dir/../../lib/spgk.cpp

make -C $script_dir/../../lib vector-kernels.o timer.o graph-loader.o jsonxx.o &> /dev/null
make -C $script_dir/../../src run-cfg.o &> /dev/null
objs="$script_dir/../../src/run-cfg.o $script_dir/../../lib/vector-kernels.o $script_dir/../../lib/timer.o $script_dir/../../lib/graph-loader.o $script_dir/../../lib/jsonxx.o"

mkdir -p $objs_dir $bins_dir

#CXX_FLAGS="-O0 -g -fopenmp -I$script_dir/../../include"
CXX_FLAGS="-O3 -fopenmp -I$script_dir/../../include"
LD_FLAGS="-fopenmp -lrt"

cnt=0
> $work_dir/errors.log
for omp_spgk in $(echo $versions | tr ',' ' '); do
  for omp_spgk_loop in $(echo $loops | tr ',' ' '); do
    for spgk_chunk in $(echo $chunks | tr ',' ' '); do

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

