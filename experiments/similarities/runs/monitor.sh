#!/bin/bash

while true; do
  clear

  for i in 1 2 3 4; do
    prefix="test$i-v_"
    echo "Experiment $i:"
    for d in $(ls | grep -v csv | grep "$prefix" | sort -g -t_ -k 2 -k 3); do
      c=0
      [ -e $d/$d-0.out ] && c=$(cat $d/$d-0.out | wc -l)
      echo "$d : $((c*100/225))%"
    done | sed "s/$prefix//" | sed 's/-l_/-/' | column # | sed 's/^/ /'
  done

  echo

  echo -n "Total: "
  for d in $(ls | grep -v csv | grep -v data); do
    echo -ne "$d\t"
    if [ -e $d/$d-0.out ]; then
      cat $d/$d-0.out | wc -l
    else
      echo 0
    fi
  done | awk '{s+=$2; n+=225}END{print int((s/n)*10000)/100"%"}'

  echo

  echo "Jobs: $(squeue | grep vanderbr | grep -v PD | wc -l)/$(squeue | grep vanderbr | wc -l)"

  sleep 15s
done

