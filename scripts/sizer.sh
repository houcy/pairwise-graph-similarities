if [[ $# -ne 2 ]];
then
    echo "usage sizer.sh <lower bound> <upper bound>"
else
    find samples -mindepth 2 -size +$1 -size -$2
fi
