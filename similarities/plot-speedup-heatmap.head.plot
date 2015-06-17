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
