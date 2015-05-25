#!/bin/bash

n=$1
[ -z $n ] && n=10

mkdir -p logs

for li in $(cat samples-routines-num-blocks.csv | sort -g -k 3 | shuf -n $n | tr ' ' ','); do
  gi=$(echo $li | awk -F, '{print $1}')
  ri=$(echo $li | awk -F, '{print $2}')

  for lj in $(cat samples-routines-num-blocks.csv | sort -g -k 3 | shuf -n $n | tr ' ' ','); do
    gj=$(echo $lj | awk -F, '{print $1}')
    rj=$(echo $lj | awk -F, '{print $2}')

    ./test-cfg samples/$gi/$gi-$ri.json samples/$gj/$gj-$rj.json > logs/$gi-$ri-$gj-$rj.log
    cat logs/$gi-$ri-$gj-$rj.log
  done
done

