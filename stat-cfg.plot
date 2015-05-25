
#set term pngcairo enhanced font 'Verdana,12' size 800, 400
#set output "stat-cfg.png"
#set multiplot layout 1,2

#splot 'stat-cfg.data' u 1:2:5
splot 'stat-cfg.data' u 3:4:5, 'stat-cfg.data' u 3:4:2

#unset multiplot

