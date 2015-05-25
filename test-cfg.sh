#!/bin/bash

mkdir -p logs

for li in $(cat samples-routines-num-blocks.csv | sort -g -k 3 | tr ' ' ','); do
  gi=$(echo $li | awk -F, '{print $1}')
  ri=$(echo $li | awk -F, '{print $2}')

  [ $(echo $li | awk -F, '{print $4}') -lt 6 ] && continue;

  for lj in $(cat samples-routines-num-blocks.csv | sort -g -k 3 | tr ' ' ','); do
    gj=$(echo $lj | awk -F, '{print $1}')
    rj=$(echo $lj | awk -F, '{print $2}')

    [ $(echo $lj | awk -F, '{print $4}') -lt 6 ] && continue;

    ./test-cfg samples/$gi/$gi-$ri.json samples/$gj/$gj-$rj.json > logs/$gi-$ri-$gj-$rj.log
    cat logs/$gi-$ri-$gj-$rj.log
  done
done

