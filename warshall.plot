set xlabel "FW version"
set ylabel "OMP_NUM_THREADS-1"
set zlabel "time(ms)"
set term png
set output "warshall_heat.png"
stats "3dfw.dat" matrix using 3 nooutput
set palette defined (STATS_min "red",STATS_max "blue")
set cbrange [20000:40000]
plot "3dfw.dat" matrix with image
#set pm3d map
#set pm3d interpolate 1,1
#splot "3dfw.dat" matrix
