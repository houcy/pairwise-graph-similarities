> 3dfw.dat
for i in `seq 1 8`
do
 export OMP_NUM_THREADS=$i
 > testdatafw.dat
 ./fwprof.sh $1 > testdatafw.dat
 ./averages.sh $i >> 3dfw.dat
done
gnuplot warshall.plot
rm testdatafw.dat
