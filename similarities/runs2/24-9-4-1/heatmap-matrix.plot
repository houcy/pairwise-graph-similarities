set terminal png transparent nocrop enhanced size 4000,800 font "arial,8"
set output 'speedup-heatmap-matrix.png'
unset key
set view map scale 1
set style data lines
set xtics border in scale 0,0 mirror norotate  autojustify
set ytics border in scale 0,0 mirror norotate  autojustify
set ztics border in scale 0,0 nomirror norotate  autojustify
unset cbtics

# set xrange [ -0.500000 : 4.50000 ] noreverse nowriteback
# set yrange [ -0.500000 : 4.50000 ] noreverse nowriteback
set cblabel "Score"
set cbrange [ 0.00000 : 50.00000 ] noreverse nowriteback
# set palette rgbformulae -7, 2, -7
x = 0.0
## Last datafile plotted: "$map2"
set term pngcairo enhanced font 'Verdana,12' size 12000,2000
set title 'Speedup of Parallel Permutations on XShort Dataset (SPGK2)'
set multiplot layout 5,5
set ylabel '47 69 1778'
set x2label '47 69 1778'
plot './runs2/24-9-4-1/4769177847691778-speedup.ssv' using 2:1:3 with image, './runs2/24-9-4-1/4769177847691778-speedup.ssv' using 2:1:($3 == 0 ? '' : sprintf('%0.2f',$3) ) with labels
unset key
unset ylabel
set x2label '47 69 1778'
plot './runs2/24-9-4-1/47691778871291157-speedup.ssv' using 2:1:3 with image, './runs2/24-9-4-1/47691778871291157-speedup.ssv' using 2:1:($3 == 0 ? '' : sprintf('%0.2f',$3) ) with labels
unset key
unset ylabel
set x2label '47 69 1778'
plot './runs2/24-9-4-1/476917781411621767-speedup.ssv' using 2:1:3 with image, './runs2/24-9-4-1/476917781411621767-speedup.ssv' using 2:1:($3 == 0 ? '' : sprintf('%0.2f',$3) ) with labels
unset key
unset ylabel
set x2label '47 69 1778'
plot './runs2/24-9-4-1/47691778398528792-speedup.ssv' using 2:1:3 with image, './runs2/24-9-4-1/47691778398528792-speedup.ssv' using 2:1:($3 == 0 ? '' : sprintf('%0.2f',$3) ) with labels
unset key
unset ylabel
set x2label '47 69 1778'
plot './runs2/24-9-4-1/47691778912194251-speedup.ssv' using 2:1:3 with image, './runs2/24-9-4-1/47691778912194251-speedup.ssv' using 2:1:($3 == 0 ? '' : sprintf('%0.2f',$3) ) with labels
unset key
unset ylabel
set ylabel '87 129 1157 \nSpeedup'
plot './runs2/24-9-4-1/87129115747691778-speedup.ssv' using 2:1:3 with image, './runs2/24-9-4-1/87129115747691778-speedup.ssv' using 2:1:($3 == 0 ? '' : sprintf('%0.2f',$3) ) with labels
unset key
unset ylabel
plot './runs2/24-9-4-1/871291157871291157-speedup.ssv' using 2:1:3 with image, './runs2/24-9-4-1/871291157871291157-speedup.ssv' using 2:1:($3 == 0 ? '' : sprintf('%0.2f',$3) ) with labels
unset key
unset ylabel
plot './runs2/24-9-4-1/8712911571411621767-speedup.ssv' using 2:1:3 with image, './runs2/24-9-4-1/8712911571411621767-speedup.ssv' using 2:1:($3 == 0 ? '' : sprintf('%0.2f',$3) ) with labels
unset key
unset ylabel
plot './runs2/24-9-4-1/871291157398528792-speedup.ssv' using 2:1:3 with image, './runs2/24-9-4-1/871291157398528792-speedup.ssv' using 2:1:($3 == 0 ? '' : sprintf('%0.2f',$3) ) with labels
unset key
unset ylabel
plot './runs2/24-9-4-1/871291157912194251-speedup.ssv' using 2:1:3 with image, './runs2/24-9-4-1/871291157912194251-speedup.ssv' using 2:1:($3 == 0 ? '' : sprintf('%0.2f',$3) ) with labels
unset key
unset ylabel
set ylabel '141 162 1767 \nSpeedup'
plot './runs2/24-9-4-1/141162176747691778-speedup.ssv' using 2:1:3 with image, './runs2/24-9-4-1/141162176747691778-speedup.ssv' using 2:1:($3 == 0 ? '' : sprintf('%0.2f',$3) ) with labels
unset key
unset ylabel
plot './runs2/24-9-4-1/1411621767871291157-speedup.ssv' using 2:1:3 with image, './runs2/24-9-4-1/1411621767871291157-speedup.ssv' using 2:1:($3 == 0 ? '' : sprintf('%0.2f',$3) ) with labels
unset key
unset ylabel
plot './runs2/24-9-4-1/14116217671411621767-speedup.ssv' using 2:1:3 with image, './runs2/24-9-4-1/14116217671411621767-speedup.ssv' using 2:1:($3 == 0 ? '' : sprintf('%0.2f',$3) ) with labels
unset key
unset ylabel
plot './runs2/24-9-4-1/1411621767398528792-speedup.ssv' using 2:1:3 with image, './runs2/24-9-4-1/1411621767398528792-speedup.ssv' using 2:1:($3 == 0 ? '' : sprintf('%0.2f',$3) ) with labels
unset key
unset ylabel
plot './runs2/24-9-4-1/1411621767912194251-speedup.ssv' using 2:1:3 with image, './runs2/24-9-4-1/1411621767912194251-speedup.ssv' using 2:1:($3 == 0 ? '' : sprintf('%0.2f',$3) ) with labels
unset key
unset ylabel
set ylabel '398 528 792 \nSpeedup'
plot './runs2/24-9-4-1/39852879247691778-speedup.ssv' using 2:1:3 with image, './runs2/24-9-4-1/39852879247691778-speedup.ssv' using 2:1:($3 == 0 ? '' : sprintf('%0.2f',$3) ) with labels
unset key
unset ylabel
plot './runs2/24-9-4-1/398528792871291157-speedup.ssv' using 2:1:3 with image, './runs2/24-9-4-1/398528792871291157-speedup.ssv' using 2:1:($3 == 0 ? '' : sprintf('%0.2f',$3) ) with labels
unset key
unset ylabel
plot './runs2/24-9-4-1/3985287921411621767-speedup.ssv' using 2:1:3 with image, './runs2/24-9-4-1/3985287921411621767-speedup.ssv' using 2:1:($3 == 0 ? '' : sprintf('%0.2f',$3) ) with labels
unset key
unset ylabel
plot './runs2/24-9-4-1/398528792398528792-speedup.ssv' using 2:1:3 with image, './runs2/24-9-4-1/398528792398528792-speedup.ssv' using 2:1:($3 == 0 ? '' : sprintf('%0.2f',$3) ) with labels
unset key
unset ylabel
plot './runs2/24-9-4-1/398528792912194251-speedup.ssv' using 2:1:3 with image, './runs2/24-9-4-1/398528792912194251-speedup.ssv' using 2:1:($3 == 0 ? '' : sprintf('%0.2f',$3) ) with labels
unset key
unset ylabel
set ylabel '912 194 251 \nSpeedup'
plot './runs2/24-9-4-1/91219425147691778-speedup.ssv' using 2:1:3 with image, './runs2/24-9-4-1/91219425147691778-speedup.ssv' using 2:1:($3 == 0 ? '' : sprintf('%0.2f',$3) ) with labels
unset key
unset ylabel
plot './runs2/24-9-4-1/912194251871291157-speedup.ssv' using 2:1:3 with image, './runs2/24-9-4-1/912194251871291157-speedup.ssv' using 2:1:($3 == 0 ? '' : sprintf('%0.2f',$3) ) with labels
unset key
unset ylabel
plot './runs2/24-9-4-1/9121942511411621767-speedup.ssv' using 2:1:3 with image, './runs2/24-9-4-1/9121942511411621767-speedup.ssv' using 2:1:($3 == 0 ? '' : sprintf('%0.2f',$3) ) with labels
unset key
unset ylabel
plot './runs2/24-9-4-1/912194251398528792-speedup.ssv' using 2:1:3 with image, './runs2/24-9-4-1/912194251398528792-speedup.ssv' using 2:1:($3 == 0 ? '' : sprintf('%0.2f',$3) ) with labels
unset key
unset ylabel
plot './runs2/24-9-4-1/912194251912194251-speedup.ssv' using 2:1:3 with image, './runs2/24-9-4-1/912194251912194251-speedup.ssv' using 2:1:($3 == 0 ? '' : sprintf('%0.2f',$3) ) with labels
unset key
unset ylabel
