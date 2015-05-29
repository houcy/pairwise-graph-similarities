>tempRow
for runs in `seq 1 $2`;
do
    ./spgkV/fw/exe/timeFW $1 >> tempRow
    echo '' >> tempRow
done
./averager.sh 1 tempRow
#rm tempRow
