for i in `seq 1 $1`
do
    if [ "$#" -eq 2 ]
    then
        awk '{ total += $'''$i'''; count++ } END { printf "%f ",total/count  }' $2
    else
        awk '{ total += $'''$i'''; count++ } END { printf "%f ",'''$3'''/(total/count) }' $2
    fi
done

