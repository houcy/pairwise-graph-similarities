set term png size 1200,600 font ',18'
set output "fw00speedup_heat20runsBgd75.png"
unset key

#set title "{ /*1.5 Speedup for the Floyd-Warshall algorithm } \n4 \
#AMD Opteron(Magny Cors) 6164HE 12-core 1.7Ghz CPUs \nCFG of \
#1797 nodes and 898 edges \nouter-loop parallelization" font "Helvetica, 10"
set multiplot layout 1,2 title "Speedup of Floyd-Warshall\n\n 4 AMD Opteron 6164HE 12-core 1.7Ghz CPUs \nCFG of 1797 nodes and 898 edges"

set label 11 center at graph 0.5,char 0.5 "original-loop parallelization" font ",18"

set tmargin 3
set bmargin 5
set rmargin 5

set xlabel "Threads"
set ylabel "Chunk Size"
set cblabel "Speedup"

set cbrange [0:10]

set xtics ( "24" 0, "48" 1, "96" 2 )
set ytics ( "4" 0,"16" 1,"64" 2,"128" 3 )

set palette defined ( 0 "cyan",5 "yellow",10 "red" )

plot "results/fw00speedup20runsBgd75" matrix with image, \
      '' matrix using 1:2:(sprintf('%.2f', $3)) with labels 



set label 11 "flipped-loop parallelization"
plot "results/fw10speedup20runsBgd75" matrix with image, \
      '' matrix using 1:2:(sprintf('%.2f', $3)) with labels

unset multiplot
