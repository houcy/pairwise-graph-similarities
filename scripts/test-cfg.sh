#!/bin/bash

n=$1
[ -z $n ] && n=10

mkdir -p logs

cnt=0

echo -n "$cnt/$((n*n))"

for li in $(cat samples-routines-num-blocks.csv | awk '{if ($4 > 5) print $0}' | sort -g -k 3 | shuf -n $n | tr ' ' ','); do
  gi=$(echo $li | awk -F, '{print $1}')
  ri=$(echo $li | awk -F, '{print $2}')

  for lj in $(cat samples-routines-num-blocks.csv | awk '{if ($4 > 5) print $0}' | sort -g -k 3 | shuf -n $n | tr ' ' ','); do
    gj=$(echo $lj | awk -F, '{print $1}')
    rj=$(echo $lj | awk -F, '{print $2}')

    cnt=$((cnt+1))

    [ -e logs/$gi-$ri-$gj-$rj.log ] && continue;

    ./test-cfg samples/$gi/$gi-$ri.json samples/$gj/$gj-$rj.json > logs/$gi-$ri-$gj-$rj.log
    echo -ne "\r                                    \r$cnt/$((n*n))"
  done
done
echo
