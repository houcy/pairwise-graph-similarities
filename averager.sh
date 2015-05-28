for i in `seq 1 $1`
do
  awk '{ total += $'''$i'''; count++ } END { printf "%d ",total/count }' $2
done
