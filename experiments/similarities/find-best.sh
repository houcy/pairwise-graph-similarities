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
results_dir=$work_dir/bests

rm -rf $results_dir
mkdir -p $results_dir

n=$((nversions*nloops*nchunks*nnumthreads))
cnt=0

for spgk_chunk in $chunks; do
  for numthread in $numthreads; do
    for omp_spgk in $versions; do
      for omp_spgk_loop in $loops; do

        tag="v_$omp_spgk-l_$omp_spgk_loop-c_$spgk_chunk-n_$numthread"
        cnt=$((cnt+1))

        cat $runs_dir/spgk-$tag.csv | tr ',' ' ' \
                                    | awk '{print $1"-"$2"-"$3"-"$4"-"$5"-"$6, $7}' \
                                    | awk '{c[$1]+=1; d[$1]+=$2}END{for (k in c) print k","d[k]/c[k]}' \
                          > $results_dir/$tag.tmp

        for d in $(cat $results_dir/$tag.tmp); do
          sizes=$(echo $d | awk -F, '{print $1}' | tr '-' ',')
          v=$(echo $d | awk -F, '{print $2}')
#         echo "$omp_spgk,$omp_spgk_loop,$spgk_chunk,$numthread,$v" >> $results_dir/sizes-$sizes.csv
          echo "$omp_spgk,$omp_spgk_loop,$spgk_chunk,$numthread,$sizes,$v" >> $results_dir/data.csv
        done
        echo -ne "\r                     \r($cnt/$n)"
      done
    done
  done
done
echo

cat $results_dir/data.csv | awk -F, '{print $5"-"$6"-"$7"-"$8"-"$9"-"$10","$1"-"$2"-"$3"-"$4","$11}' \
                          | awk -F, '{if (time[$1] == 0 || $3 < time[$1]) {time[$1] = $3; best[$1] = $2}}END{for (k in time) print k","best[k]","time[k]}' \
                          | tr '-' ',' \
                          | awk -F, '{print $1","$2","$3","$4","$5","$6","$7"-"$8"-"$9"-"$10","$11}' \
    > $results_dir/best.csv

> $results_dir/versions.desc
> $results_dir/versions.names
awk -F, '{print $1 "," $2 "," $3 "," $4 "," $5 "," $6 "," $7}' $results_dir/best.csv > $results_dir/versions.data
cnt=0
for v in $(cat $results_dir/versions.data | awk -F, '{print $7}' | sort | uniq); do
  echo $v | awk -F- -v cnt=$cnt '{print "Version #" cnt ": V=" $1 ", L=" $2 ", C=" $3 ", T=" $4}' >> $results_dir/versions.desc
  echo -n "$cnt," >> $results_dir/versions.names
  cat $results_dir/versions.data | sed "s/$v/$cnt/" > $results_dir/versions.data~
  mv $results_dir/versions.data~ $results_dir/versions.data
  cnt=$((cnt+1))
done

cat $results_dir/versions.names | sed 's/,$/./' > $results_dir/versions.names~
mv $results_dir/versions.names~ $results_dir/versions.names
echo >> $results_dir/versions.names
echo "n1:continuous." >> $results_dir/versions.names
echo "e1:continuous." >> $results_dir/versions.names
echo "efw1:continuous." >> $results_dir/versions.names
echo "n2:continuous." >> $results_dir/versions.names
echo "e2:continuous." >> $results_dir/versions.names
echo "efw2:continuous." >> $results_dir/versions.names

echo
echo "****************************************************************"
echo

echo "C 5.0 data in  $results_dir/versions.names and $results_dir/versions.data"
echo "Description of the best versions in $results_dir/versions.desc"
cat $results_dir/versions.desc | sed 's/^/    /'

echo
echo "****************************************************************"
echo

