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
          echo "$omp_spgk,$omp_spgk_loop,$spgk_chunk,$numthread,$sizes,$v" >> $results_dir/data.csv
        done
        echo -ne "\r                     \r($cnt/$n)"
      done
    done
  done
done
echo
fi

cat $results_dir/data.csv | awk -F, '{print $5 "-" $6 "-" $7 "-" $8 "-" $9 "-" $10               "," $1 "-" $2 "-" $3 "-" $4 "," $11}' \
                          > $results_dir/data.grp-0.csv
cat $results_dir/data.csv | awk -F, '{print $5 "-" $6 "-" $7 "-" $8 "-" $9 "-" $10 "-" $4        "," $1 "-" $2 "-" $3        "," $11}' \
                          > $results_dir/data.grp-1.csv
cat $results_dir/data.csv | awk -F, '{print $5 "-" $6 "-" $7 "-" $8 "-" $9 "-" $10 "-" $4 "-" $3 "," $1 "-" $2               "," $11}' \
                          > $results_dir/data.grp-2.csv

for i in 0 1 2; do
  cat $results_dir/data.grp-$i.csv | awk -F, '{print $1}' \
                                   | sort | uniq \
                                   > $results_dir/sizes-$i.csv

  for l in $(cat $results_dir/data.grp-$i.csv | sort -g -t, -k 3); do
    tag=$(awk -F, '{print $1}' <<< $l)
    echo $l >> $results_dir/$tag.tmp
  done

  for size in $(cat $results_dir/sizes-$i.csv); do
    min=$(cat $results_dir/$size.tmp | awk -F, '{if (min==0 || min > $3) min=$3}END{print min}');
    cat $results_dir/$size.tmp | awk -F, -v min=$min '{if ($3/min <= 1.01) print $2, $3/min}' \
                               | awk '{s[$1]+=$2;n[$1]+=1;}END{for (k in s) print k","s[k]/n[k]}' \
                               | sort -g -t, -k 2 \
                               > $results_dir/bests-$i-$size.tmp
#    cat $results_dir/bests-$i-$size.tmp | sed "s/^/$(echo $size | tr '-' ','),/"
  done # > $results_dir/bests-$i.csv

  for size in $(cat $results_dir/sizes-$i.csv); do
    cat $results_dir/bests-$i-$size.tmp | awk -F, '{print $1}' > $results_dir/bests-$i-$size.tmp~
    mv $results_dir/bests-$i-$size.tmp~ $results_dir/bests-$i-$size.tmp
    rm -f $results_dir/bests-$i-$size.tmp~ $results_dir/bests-$i-$size.tmp~~
  done

  cont=1
  while [ $cont -eq 1 ]; do
    cont=0;
    most_frequent=$(for size in $(cat $results_dir/sizes-$i.csv); do
                      cat $results_dir/bests-$i-$size.tmp
                    done | sort | uniq -c | sort -g -k 1 | tail -n 1 | awk '{print $2}')
    echo "most_frequent=$most_frequent"
    for size in $(cat $results_dir/sizes-$i.csv); do
      if grep -q "^$most_frequent\$" $results_dir/bests-$i-$size.tmp; then
        cat $results_dir/bests-$i-$size.tmp | grep -v "^$most_frequent\$" > $results_dir/bests-$i-$size.tmp~
        mv $results_dir/bests-$i-$size.tmp~ $results_dir/bests-$i-$size.tmp
        echo $most_frequent >> $results_dir/bests-$i-$size.tmp~~
      elif [ ! -e $results_dir/bests-$i-$size.tmp~~ ]; then
        cont=1;
      fi
    done
  done

  for size in $(cat $results_dir/sizes-$i.csv); do
    [ ! -e $results_dir/bests-$i-$size.tmp~~ ] && echo "ERROR !!! bests-$i-$size.tmp does not exist!!!!" && exit
      mv $results_dir/bests-$i-$size.tmp~~ $results_dir/bests-$i-$size.tmp
  done

  for size in $(cat $results_dir/sizes-$i.csv); do
    cat $results_dir/bests-$i-$size.tmp | sed "s/^/$(echo $size | tr '-' ','),/"
  done > $results_dir/bests-$i.csv

  cat $results_dir/data.grp-$i.csv | awk -F, '{ if (time[$1] == 0 || $3 < time[$1]) {
                                                  time[$1] = $3;
                                                  best[$1] = $2
                                              } }
                                              END {
                                                for (k in time)
                                                  print k","best[k]","time[k];
                                              }' \
                                   | tr '-' ',' > $results_dir/best-$i.csv
done

for tag in best bests; do
  cat $results_dir/$tag-0.csv | awk -F, '{print $1 "," $2 "," $3 "," $4 "," $5 "," $6               "," $7 "-" $8 "-" $9  "-" $10 }' \
                              > $results_dir/$tag-0.data
  cat $results_dir/$tag-1.csv | awk -F, '{print $1 "," $2 "," $3 "," $4 "," $5 "," $6 "," $7        "," $8 "-" $9 "-" $10         }' \
                              > $results_dir/$tag-1.data
  cat $results_dir/$tag-2.csv | awk -F, '{print $1 "," $2 "," $3 "," $4 "," $5 "," $6 "," $7 "," $8 "," $9 "-" $10                }' \
                              > $results_dir/$tag-2.data

  for i in 0 1 2; do
    > $results_dir/$tag-$i.names
    > $results_dir/$tag-$i.desc

    cnt=0
    [ $i -eq 0 ] && versions=$(cat $results_dir/$tag-0.data | awk -F, '{print $7}' | sort -g -t- -k 1 -k 2 -k 3 -k 4 | uniq)
    [ $i -eq 1 ] && versions=$(cat $results_dir/$tag-1.data | awk -F, '{print $8}' | sort -g -t- -k 1 -k 2 -k 3      | uniq)
    [ $i -eq 2 ] && versions=$(cat $results_dir/$tag-2.data | awk -F, '{print $9}' | sort -g -t- -k 1 -k 2           | uniq)
    for v in $versions; do
      [ $i -eq 0 ] && echo $v | awk -F- -v cnt=$cnt '{print "Version #" cnt ": V=" $1 ", L=" $2 ", C=" $3 ", T=" $4}' >> $results_dir/$tag-0.desc
      [ $i -eq 1 ] && echo $v | awk -F- -v cnt=$cnt '{print "Version #" cnt ": V=" $1 ", L=" $2 ", C=" $3          }' >> $results_dir/$tag-1.desc
      [ $i -eq 2 ] && echo $v | awk -F- -v cnt=$cnt '{print "Version #" cnt ": V=" $1 ", L=" $2                    }' >> $results_dir/$tag-2.desc

      echo -n "$cnt," >> $results_dir/$tag-$i.names
      cat $results_dir/$tag-$i.data | sed "s/,$v$/,$cnt/" > $results_dir/$tag-$i.data~
      mv $results_dir/$tag-$i.data~ $results_dir/$tag-$i.data
      cnt=$((cnt+1))
    done

    cat $results_dir/$tag-$i.names | sed 's/,$/./' > $results_dir/$tag-$i.names~
    mv $results_dir/$tag-$i.names~ $results_dir/$tag-$i.names
    echo >> $results_dir/$tag-$i.names
    echo >> $results_dir/$tag-$i.names

    echo "n1:continuous."   >> $results_dir/$tag-$i.names
    echo "e1:continuous."   >> $results_dir/$tag-$i.names
    echo "efw1:continuous." >> $results_dir/$tag-$i.names
    echo "n2:continuous."   >> $results_dir/$tag-$i.names
    echo "e2:continuous."   >> $results_dir/$tag-$i.names
    echo "efw2:continuous." >> $results_dir/$tag-$i.names

    [ $i -ge 1 ] && ( echo "nthreads:24,48." >> $results_dir/$tag-$i.names )

    [ $i -ge 2 ] && ( echo "chunk:1,16,256." >> $results_dir/$tag-$i.names )

    cp $results_dir/$tag-$i.names $results_dir/$tag-log-$i.names
  done

  cat $results_dir/$tag-0.data \
      | awk -F, '{print int(log($1)) "," int(log($2)) "," int(log($3)) "," int(log($4)) "," int(log($5)) "," int(log($6)) "," $7 }' \
      > $results_dir/$tag-log-0.data
  cat $results_dir/$tag-1.data \
      | awk -F, '{print int(log($1)) "," int(log($2)) "," int(log($3)) "," int(log($4)) "," int(log($5)) "," int(log($6)) "," $7 "," $8 }' \
      > $results_dir/$tag-log-1.data
  cat $results_dir/$tag-2.data \
      | awk -F, '{print int(log($1)) "," int(log($2)) "," int(log($3)) "," int(log($4)) "," int(log($5)) "," int(log($6)) "," $7 "," $8 "," $9 }' \
      > $results_dir/$tag-log-2.data
done

if [ ! -z $C50_DIR ]; then
  for tag in best bests best-log bests-log; do
    for i in 0 1 2; do
      $C50_DIR/c5.0 -b -f $results_dir/$tag-$i > $results_dir/$tag-$i.log
    done
  done
fi

