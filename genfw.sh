#!/bin/bash
RUNS=$5
FILES=spgkV/fw/exe/*
threadmin=$2
threadmax=$3
> hashed.txt
echo ""
if [ "$#" -ge 6 ]
then
    baseline=$(eval "./baseline.sh $1 $RUNS");
    echo "baseline: "$baseline
else
    baseline=$(eval "./readbaseline.sh");
fi

echo ""

mkdir -p tests
while IFS= read -r dir
do
    > tests/$dir
    while IFS= read -r file
    do
        TEMP=''
        > tests/tempdata
        for logb2thread in  $2 $3 $4
        do
            THREADS=$logb2thread
            export OMP_NUM_THREADS=$THREADS
            > tempRow
            for runs in `seq 1 $RUNS`;
            do
                ./spgkV/$dir/exe/$file $1 >> tempRow
                #cat tempRow
                echo '' >> tempRow
            done
            echo $(eval ./averager.sh 1 tempRow $baseline) speedup
            ./averager.sh 1 tempRow $baseline >> tests/tempdata

            echo "processed $file with $THREADS thread(s)"
            echo ""
        done
        echo '' >> tests/tempdata
        cat tests/tempdata tests/$dir > temp && mv temp tests/$dir
    done < "$dir"
done < "fwverMaster"
rm tempRow
