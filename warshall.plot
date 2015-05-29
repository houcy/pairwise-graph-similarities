set xlabel "Threads"
set ylabel "Chunk Size"
set cblabel "Speedup"
set term png
set output "fw00speedup_heat.png"

unset key
#unset cbtics

set xtics ( "24" 0, "48" 1, "96" 2 )
set ytics ( "4" 0,"16" 1,"64" 2,"128" 3 )
#set logscale x 2

#set pm3d map
#set pm3d interpolate 0,0
#splot "results/fw00speedup" matrix
plot "results/fw00speedup" matrix with image, \
      '' matrix using 1:2:(sprintf('%.2f', $3)) with labels font ',16'
