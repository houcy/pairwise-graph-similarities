#!/bin/bash

SIMILARITIES_DIR=.
RUNS_DIR=$SIMILARITIES_DIR/runs
RESULTS_DIR=$SIMILARITIES_DIR/$1

mkdir -p $RESULTS_DIR

versions=$2
[ -z "$versions" ] && versions=$(seq 1 24)
nversions=$(wc -w <<< "$versions")

chunks=$3
[ -z "$chunks" ] && chunks=$(for chunk in $(seq 0 8); do echo "$((1<<chunk))"; done)
nchunks=$(wc -w <<< "$chunks")

loops=$4
[ -z "$loops" ] && loops=$(seq 1 4)
nloops=$(wc -w <<< "$loops")

numthreads=$5
[ -z "$numthreads" ] && numthreads=$(nproc)
nnumthreads=$(wc -w <<< "$numthreads")

rm -rf $RESULTS_DIR
mkdir -p $RESULTS_DIR

n=$((nversions*nloops*nchunks*nnumthreads))
cnt=0

for spgk_chunk in $chunks; do
  for numthread in $numthreads; do
    for omp_spgk in $versions; do
      for omp_spgk_loop in $loops; do

        tag="v_$omp_spgk-l_$omp_spgk_loop-c_$spgk_chunk-n_$numthread"
        cnt=$((cnt+1))

        cat $RUNS_DIR/spgk-$tag.csv | tr ',' ' ' \
                                    | awk '{print $1"-"$2"-"$3"-"$4"-"$5"-"$6, $7}' \
                                    | awk '{c[$1]+=1; d[$1]+=$2}END{for (k in c) print k","d[k]/c[k]}' \
                          > $RESULTS_DIR/$tag.tmp

        for d in $(cat $RESULTS_DIR/$tag.tmp); do
          sizes=$(echo $d | awk -F, '{print $1}' | tr '-' ',')
          v=$(echo $d | awk -F, '{print $2}')
#         echo "$omp_spgk,$omp_spgk_loop,$spgk_chunk,$numthread,$v" >> $RESULTS_DIR/sizes-$sizes.csv
          echo "$omp_spgk,$omp_spgk_loop,$spgk_chunk,$numthread,$sizes,$v" >> $RESULTS_DIR/data.csv
        done
        echo -ne "\r                     \r($cnt/$n)"
      done
    done
  done
done
echo

cat $RESULTS_DIR/data.csv | awk -F, '{print $5"-"$6"-"$7"-"$8"-"$9"-"$10","$1"-"$2"-"$3"-"$4","$11}' \
                          | awk -F, '{if (time[$1] == 0 || $3 < time[$1]) {time[$1] = $3; best[$1] = $2}}END{for (k in time) print k","best[k]","time[k]}' \
                          | tr '-' ',' \
                          | awk -F, '{print $1","$2","$3","$4","$5","$6","$7"-"$8"-"$9"-"$10","$11}' \
    > $RESULTS_DIR/best.csv

> $RESULTS_DIR/versions.desc
> $RESULTS_DIR/versions.names
awk -F, '{print $1 "," $2 "," $3 "," $4 "," $5 "," $6 "," $7}' $RESULTS_DIR/best.csv > $RESULTS_DIR/versions.data
cnt=0
for v in $(cat $RESULTS_DIR/versions.data | awk -F, '{print $7}' | sort | uniq); do
  echo $v | awk -F- -v cnt=$cnt '{print "Version #" cnt ": V=" $1 ", L=" $2 ", C=" $3 ", T=" $4}' >> $RESULTS_DIR/versions.desc
  echo -n "$cnt," >> $RESULTS_DIR/versions.names
  cat $RESULTS_DIR/versions.data | sed "s/$v/$cnt/" > $RESULTS_DIR/versions.data~
  mv $RESULTS_DIR/versions.data~ $RESULTS_DIR/versions.data
  cnt=$((cnt+1))
done

cat $RESULTS_DIR/versions.names | sed 's/,$/./' > $RESULTS_DIR/versions.names~
mv $RESULTS_DIR/versions.names~ $RESULTS_DIR/versions.names
echo >> $RESULTS_DIR/versions.names
echo "n1:continuous." >> $RESULTS_DIR/versions.names
echo "e1:continuous." >> $RESULTS_DIR/versions.names
echo "efw1:continuous." >> $RESULTS_DIR/versions.names
echo "n2:continuous." >> $RESULTS_DIR/versions.names
echo "e2:continuous." >> $RESULTS_DIR/versions.names
echo "efw2:continuous." >> $RESULTS_DIR/versions.names

echo
echo "****************************************************************"
echo

echo "C 5.0 data in  $RESULTS_DIR/versions.names and $RESULTS_DIR/versions.data"
echo "Description of the best versions in $RESULTS_DIR/versions.desc"
cat $RESULTS_DIR/versions.desc | sed 's/^/    /'

echo
echo "****************************************************************"
echo

