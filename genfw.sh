#!/bin/bash
RUNS=$4
FILES=spgkV/fw/exe/*
threadmin=$2
threadmax=$3
mkdir -p tests
while IFS= read -r dir
do
    > tests/$dir
    while IFS= read -r file
    do
        TEMP=''
        > tests/tempdata
        for logb2thread in `seq $threadmin $threadmax`
        do
            THREADS=$(echo "2^$logb2thread" | bc)
            export OMP_NUM_THREADS=$THREADS
            > tempRow
            for runs in `seq 1 $RUNS`;
            do
                ./spgkV/$dir/exe/$file $1 >> tempRow
                echo '' >> tempRow
            done
            ./averager.sh 1 tempRow >> tests/tempdata 

            echo "processing $file with $THREADS thread(s)"
        done
        echo '' >> tests/tempdata
        cat tests/tempdata tests/$dir > temp && mv temp tests/$dir
    done < "$dir"
done < "fwverMaster"
