for i in `seq 1 5`
do
  awk '{ total += $'''$i'''; count++ } END { printf "%d ",total/count }' testdatafw.dat
done
  echo ''
