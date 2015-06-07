#!/bin/bash

restart=0
while [ ! -z $1 ]; do
  if   [ "$1" == "-r"   ]; then restart=1;      shift 1;
  elif [ "$1" == "-d"   ]; then work_dir=$2;    shift 2;
  elif [ "$1" == "-v"   ]; then versions=$2;    shift 2;
  elif [ "$1" == "-c"   ]; then chunks=$2;      shift 2;
  elif [ "$1" == "-l"   ]; then loops=$2;       shift 2;
  elif [ "$1" == "-t"   ]; then numthreads=$2;  shift 2;
  else echo "Unknown option: \"$1\""; shift 1; fi
done

[ -z "$work_dir" ]    && echo "Missing work directory: \"-d work_dir\""        && exit 1

[ -z "$versions" ] && versions="1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24"
nversions=$(echo $versions | tr ',' ' ' | wc -w)

[ -z "$loops" ] && loops="1,2,3,4"
nloops=$(echo $loops | tr ',' ' ' | wc -w)

[ -z "$chunks" ] && chunks="1,2,4,8,16,32,64,128,256"
nchunks=$(echo $chunks | tr ',' ' ' | wc -w)

[ -z "$numthreads" ] && numthreads=$(nproc)
nnumthreads=$(echo $numthreads | tr ',' ' ' | wc -w)

runs_dir=$work_dir/runs
results_dir=$work_dir/bests

if [ $restart -eq 1 ]; then
rm -rf $results_dir
mkdir -p $results_dir

n=$((nversions*nloops*nchunks*nnumthreads))
cnt=0

for spgk_chunk in $(echo $chunks | tr ',' ' '); do
  for numthread in $(echo $numthreads | tr ',' ' '); do
    for omp_spgk in $(echo $versions | tr ',' ' '); do
      for omp_spgk_loop in $(echo $loops | tr ',' ' '); do

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
fi

cat $results_dir/data.csv | awk -F, '{print $5"-"$6"-"$7"-"$8"-"$9"-"$10"-"$4","$1"-"$2"-"$3","$11}' \
                          | awk -F, '{if (time[$1] == 0 || $3 < time[$1]) {time[$1] = $3; best[$1] = $2}}END{for (k in time) print k","best[k]","time[k]}' \
                          | tr '-' ',' \
                          | awk -F, '{print $1","$2","$3","$4","$5","$6","$7","$8"-"$9"-"$10","$11}' \
    > $results_dir/best.csv

> $results_dir/versions.desc
> $results_dir/versions.names
#awk -F, '{print $1 "," $2 "," $3 "," $4 "," $5 "," $6 "," $7}' $results_dir/best.csv > $results_dir/versions.data
awk -F, '{print $1 "," $2 "," $3 "," $4 "," $5 "," $6 "," $7 "," $8}' $results_dir/best.csv > $results_dir/versions.data
cnt=0
for v in $(cat $results_dir/versions.data | awk -F, '{print $8}' | sort -g -t- -k 2 -k 1 -k 3 | uniq); do
  echo $v | awk -F- -v cnt=$cnt '{print "Version #" cnt ": V=" $1 ", L=" $2 ", C=" $3}' >> $results_dir/versions.desc
# echo $v | awk -F- -v cnt=$cnt '{print "Version #" cnt ": V=" $1 ", L=" $2 ", C=" $3 ", T=" $4}' >> $results_dir/versions.desc
  echo -n "$cnt," >> $results_dir/versions.names
  cat $results_dir/versions.data | sed "s/,$v$/,$cnt/" > $results_dir/versions.data~
  mv $results_dir/versions.data~ $results_dir/versions.data
  cnt=$((cnt+1))
done
awk -F, '{print int(log($1)) "," int(log($2)) "," int(log($3)) "," int(log($4)) "," int(log($5)) "," int(log($6)) "," $7 "," $8}' $results_dir/versions.data > $results_dir/versions-log.data

cat $results_dir/versions.names | sed 's/,$/./' > $results_dir/versions.names~
mv $results_dir/versions.names~ $results_dir/versions.names
echo >> $results_dir/versions.names
echo "n1:continuous." >> $results_dir/versions.names
echo "e1:continuous." >> $results_dir/versions.names
echo "efw1:continuous." >> $results_dir/versions.names
echo "n2:continuous." >> $results_dir/versions.names
echo "e2:continuous." >> $results_dir/versions.names
echo "efw2:continuous." >> $results_dir/versions.names
echo "nthreads:24,48." >> $results_dir/versions.names

cp $results_dir/versions.names $results_dir/versions-log.names

echo
echo "****************************************************************"
echo

echo "C 5.0 data in  $results_dir/versions.names and $results_dir/versions.data"
echo "Description of the best versions in $results_dir/versions.desc"
cat $results_dir/versions.desc | sed 's/^/    /'

echo
echo "****************************************************************"
echo

