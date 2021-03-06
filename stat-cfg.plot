
set term pngcairo enhanced font 'Verdana,12' size 800, 800

set hidden3d
set dgrid3d 100,100 qnorm 2

set pm3d
set palette

set log

set xlabel "Graph 1"
set ylabel "Graph 2"
set zlabel "Seconds"

#set term wxt 0
set output "stat-cfg-nodes.png"
set title "SPGK computation time, function of the number of Nodes."
splot 'stat-cfg.data' using 1:4:7 notitle

#set term wxt 1
set output "stat-cfg-edges.png"
set title "SPGK computation time, function of the number of Edges (original graph)."
splot 'stat-cfg.data' using 2:5:7 notitle

#set term wxt 2
set output "stat-cfg-edges-after-fw.png"
set title "SPGK computation time, function of the number of Edges (shortest path graph)."
splot 'stat-cfg.data' using 3:6:7 notitle

#set term wxt 0 size 800,600
#set title "SPGK computation time, function of the number of Edges (shortest path graph)."
#splot 'stat-cfg.data' using 3:6:7 notitle

