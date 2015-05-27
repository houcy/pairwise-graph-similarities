for i in `seq 1 7`
do
  #printf "$1 " 
  awk '{ total += $'''$i'''; count++ } END { printf "%d ",total/count }' testdatafw.dat 
done
  echo ''
