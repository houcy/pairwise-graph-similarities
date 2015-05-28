#!/bin/bash
#> 3dfw.dat
RUNS=1
FILES=spgkV/fw/exe/*
#for i in `seq 0 3`
#do
#    THREADS=$(echo "2^$i" | bc)
#    export OMP_NUM_THREADS=$THREADS 
#    for f in $FILES;
#    do
#        > testdatafw.dat
#         for run in `seq 1 $RUNS`
#         do
#            ./$f $1 >> testdatafw.dat
#         done
#         echo '' >> testdatafw.dat
#         echo "processing $f with $THREADS thread(s)"
#        ./averager.sh $RUNS  testdatafw.dat >> 3dfw.dat 
#    done
#done
#gnuplot warshall.plot
#rm testdatafw.dats=3

logb2threadmax=3
while IFS= read -r dir
do
    > tests/$dir
    while IFS= read -r file
    do
        TEMP=''
        > tests/tempdata
        for logb2thread in `seq 0 $logb2threadmax`
        do
            THREADS=$(echo "2^$logb2thread" | bc)
            export OMP_NUM_THREADS=$THREADS
            ./spgkV/$dir/exe/$file $1 >> tests/tempdata

            echo "processing $file with $THREADS thread(s)"
        done
        echo '' >> tests/tempdata
        cat tests/tempdata tests/$dir > temp && mv temp tests/$dir
    done < "$dir"
done < "fwverMaster"
