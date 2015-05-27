
DEBUG_FLAGS=-Wall -g -O0 -pg -fopenmp 

all: test-cfg test-spgk pairwise-spgk test-fw fw-time

warshall: fw-time fw-time-0 fw-time-1 fw-time-2 fw-time-3 fw-time-4 fw-time-5
plot-warshall-small: fw-time fw-time-0 fw-time-1 fw-time-2 fw-time-3 fw-time-4 fw-time-5
	./genfw.sh samples/FdCMeDTY76jcz1EpqLhQ/FdCMeDTY76jcz1EpqLhQ-rtn_3.json

plot-warshall: fw-time fw-time-0 fw-time-1 fw-time-2 fw-time-3 fw-time-4 fw-time-5
	./genfw.sh samples/85lCRjIZmV670qYBJSNo/85lCRjIZmV670qYBJSNo-rtn_80.json

check: check-cfg check-spgk check-pairwise test-fw

check-cfg: test-cfg
	./test-cfg samples/0BZQIJak6Pu2tyAXfrzR/0BZQIJak6Pu2tyAXfrzR-sub_41F46A.json samples/FdCMeDTY76jcz1EpqLhQ/FdCMeDTY76jcz1EpqLhQ-sub_4E671E.json

check-spgk: test-spgk
	./test-spgk 10 10 5 500 # 10 nodes per graph, 5 features per node, and 50% chance for an edge to exist

check-pairwise: pairwise-spgk samples
	./pairwise-spgk 0BZQIJak6Pu2tyAXfrzR 0WQtf1pNPdRqUI7KJFAT samples instructions.lst
	
check-fw: test-fw samples
	./test-fw samples/7h32P6rADjMVEQuoOJIB/7h32P6rADjMVEQuoOJIB-rtn_1.json

samples: samples.tgz
	tar xzf samples.tgz

clean:
	rm -f test-cfg test-spgk pairwise-spgk
	rm -f *.o *.dot *.svg
	rm -f fw-time* warshall_heat.png gmon.out 3dfw.dat testdatafw.dat test-fw

test-fw: test-fw.o spgk.o graph-loader.o timer.o vector-kernels.o 
	c++ $(DEBUG_FLAGS) -lrt vector-kernels.o test-fw.o spgk.o graph-loader.o jsonxx.o timer.o -o test-fw

fw-time: time-fw.o spgk.o graph-loader.o timer.o vector-kernels.o 
	c++ $(DEBUG_FLAGS) -lrt vector-kernels.o time-fw.o spgk.o graph-loader.o jsonxx.o timer.o -o fw-time

fw-time-0: time-fw.o spgk0.o graph-loader.o timer.o vector-kernels.o 
	c++ $(DEBUG_FLAGS) -DOMP_FW=0 -lrt vector-kernels.o time-fw.o spgk0.o graph-loader.o jsonxx.o timer.o -o fw-time-0

fw-time-1: time-fw.o spgk1.o graph-loader.o timer.o vector-kernels.o 
	c++ $(DEBUG_FLAGS) -DOMP_FW=1 -lrt vector-kernels.o time-fw.o spgk1.o graph-loader.o jsonxx.o timer.o -o fw-time-1

fw-time-2: time-fw.o spgk2.o graph-loader.o timer.o vector-kernels.o 
	c++ $(DEBUG_FLAGS) -DOMP_FW=2 -lrt vector-kernels.o time-fw.o spgk2.o graph-loader.o jsonxx.o timer.o -o fw-time-2

fw-time-3: time-fw.o spgk3.o graph-loader.o timer.o vector-kernels.o 
	c++ $(DEBUG_FLAGS) -DOMP_FW=3 -lrt vector-kernels.o time-fw.o spgk3.o graph-loader.o jsonxx.o timer.o -o fw-time-3

fw-time-4: time-fw.o spgk4.o graph-loader.o timer.o vector-kernels.o 
	c++ $(DEBUG_FLAGS) -DOMP_FW=4 -lrt vector-kernels.o time-fw.o spgk4.o graph-loader.o jsonxx.o timer.o -o fw-time-4

fw-time-5: time-fw.o spgk5.o graph-loader.o timer.o vector-kernels.o 
	c++ $(DEBUG_FLAGS) -DOMP_FW=5 -lrt vector-kernels.o time-fw.o spgk5.o graph-loader.o jsonxx.o timer.o -o fw-time-5

test-cfg: test-cfg.o spgk.o vector-kernels.o timer.o graph-loader.o jsonxx.o
	c++  $(DEBUG_FLAGS) -lrt vector-kernels.o spgk.o timer.o test-cfg.o graph-loader.o jsonxx.o -o test-cfg

test-spgk: test-spgk.o spgk.o vector-kernels.o timer.o
	c++  $(DEBUG_FLAGS) -lrt vector-kernels.o spgk.o timer.o test-spgk.o -o test-spgk

pairwise-spgk: pairwise-spgk.o timer.o spgk.o vector-kernels.o pairwise-similarity.o graph-loader.o jsonxx.o
	c++ $(DEBUG_FLAGS) vector-kernels.o timer.o spgk.o jsonxx.o graph-loader.o pairwise-similarity.o pairwise-spgk.o -o pairwise-spgk

test-fw.o: test-fw.cpp spgk.hpp graph-loader.hpp timer.h
	c++ $(DEBUG_FLAGS) -c test-fw.cpp -o test-fw.o

time-fw.o: time-fw.cpp spgk.hpp graph-loader.hpp timer.h
	c++ $(DEBUG_FLAGS) -c time-fw.cpp -o time-fw.o

pairwise-spgk.o: pairwise-spgk.cpp spgk.hpp
	c++ $(DEBUG_FLAGS) -c pairwise-spgk.cpp -o pairwise-spgk.o

test-spgk.o: test-spgk.cpp spgk.hpp timer.h
	c++ $(DEBUG_FLAGS) -c test-spgk.cpp -o test-spgk.o

test-cfg.o: test-cfg.cpp spgk.hpp timer.h
	c++ $(DEBUG_FLAGS) -c test-cfg.cpp -o test-cfg.o

pairwise-similarity.o: pairwise-similarity.cpp pairwise-similarity.hpp
	c++ $(DEBUG_FLAGS) -c pairwise-similarity.cpp -o pairwise-similarity.o

jsonxx.o: jsonxx.cpp jsonxx.hpp
	c++ $(DEBUG_FLAGS) -c jsonxx.cpp -o jsonxx.o

graph-loader.o: graph-loader.cpp graph-loader.hpp vector-kernels.hpp jsonxx.hpp
	c++ $(DEBUG_FLAGS) -c graph-loader.cpp -o graph-loader.o

spgk.o: spgk.cpp spgk.hpp vector-kernels.hpp
	c++ $(DEBUG_FLAGS) -c spgk.cpp -o spgk.o
	
spgk0.o: spgk.cpp spgk.hpp vector-kernels.hpp
	c++ $(DEBUG_FLAGS) -DOMP_FW=0 -c spgk.cpp -o spgk0.o

spgk1.o: spgk.cpp spgk.hpp vector-kernels.hpp
	c++ $(DEBUG_FLAGS) -DOMP_FW=1 -c spgk.cpp -o spgk1.o

spgk2.o: spgk.cpp spgk.hpp vector-kernels.hpp
	c++ $(DEBUG_FLAGS) -DOMP_FW=2 -c spgk.cpp -o spgk2.o

spgk3.o: spgk.cpp spgk.hpp vector-kernels.hpp
	c++ $(DEBUG_FLAGS) -DOMP_FW=3 -c spgk.cpp -o spgk3.o

spgk4.o: spgk.cpp spgk.hpp vector-kernels.hpp
	c++ $(DEBUG_FLAGS) -DOMP_FW=4 -c spgk.cpp -o spgk4.o

spgk5.o: spgk.cpp spgk.hpp vector-kernels.hpp
	c++ $(DEBUG_FLAGS) -DOMP_FW=5 -c spgk.cpp -o spgk5.o

vector-kernels.o: vector-kernels.cpp vector-kernels.hpp
	c++ $(DEBUG_FLAGS) -c vector-kernels.cpp -o vector-kernels.o

timer.o: timer.c timer.h
	cc $(DEBUG_FLAGS) -c timer.c -o timer.o

