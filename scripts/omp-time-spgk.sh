#! /bin/bash
> spgkmatrix.dat
for t in `seq 1 8`
do
    ./spgkV/time-spgk samples/E8vGptxQ9XyHZ3RiJoD0/E8vGptxQ9XyHZ3RiJoD0-rtn_102.json samples/85lCRjIZmV670qYBJSNo/85lCRjIZmV670qYBJSNo-sub_43011D.json >> spgkmatrix.dat 
    export OMP_NUM_THREADS=$i
    for i in `seq 0 1`
    do
        for j in `seq 0 1`
        do
            for k in `seq 0 1`
            do
                for l in `seq 0 1`
                do
                    #> tempavg.dat
                    #for run in `seq 1 10`
                    #do
                    ./spgkV/time-spgk$i$j$k$l samples/E8vGptxQ9XyHZ3RiJoD0/E8vGptxQ9XyHZ3RiJoD0-rtn_102.json samples/85lCRjIZmV670qYBJSNo/85lCRjIZmV670qYBJSNo-sub_43011D.json >> spgkmatrix.dat
                    #done
                    #./averager.sh 1 10 tempavg.dat >> spgkmatrix.dat
                done
            done
        done
    done
echo '' >> spgkmatrix.dat
done
gnuplot timespgk.plot

