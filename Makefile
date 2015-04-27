
DEBUG_FLAGS=-Wall -g -O0

all: test-spgk pairwise-spgk

check: check-spgk check-pairwise

check-spgk: test-spgk
	./test-spgk 10 10 5 500 # 10 nodes per graph, 5 features per node, and 50% chance for an edge to exist

check-pairwise: pairwise-spgk samples
	./pairwise-spgk 0BZQIJak6Pu2tyAXfrzR 0WQtf1pNPdRqUI7KJFAT samples instructions.lst

samples: samples.tgz
	tar xzf samples.tgz

clean:
	rm -f test-spgk pairwise-spgk
	rm -f *.o *.dot *.svg

test-spgk: test-spgk.o spgk.o vector-kernels.o timer.o
	c++ -lrt vector-kernels.o spgk.o timer.o test-spgk.o -o test-spgk

pairwise-spgk: pairwise-spgk.o spgk.o vector-kernels.o pairwise-similarity.o graph-loader.o jsonxx.o
	c++ vector-kernels.o spgk.o jsonxx.o graph-loader.o pairwise-similarity.o pairwise-spgk.o -o pairwise-spgk

pairwise-spgk.o: pairwise-spgk.cpp spgk.hpp
	c++ $(DEBUG_FLAGS) -c pairwise-spgk.cpp -o pairwise-spgk.o

test-spgk.o: test-spgk.cpp spgk.hpp timer.h
	c++ $(DEBUG_FLAGS) -c test-spgk.cpp -o test-spgk.o

pairwise-similarity.o: pairwise-similarity.cpp pairwise-similarity.hpp
	c++ $(DEBUG_FLAGS) -c pairwise-similarity.cpp -o pairwise-similarity.o

jsonxx.o: jsonxx.cpp jsonxx.hpp
	c++ $(DEBUG_FLAGS) -c jsonxx.cpp -o jsonxx.o

graph-loader.o: graph-loader.cpp graph-loader.hpp vector-kernels.hpp jsonxx.hpp
	c++ $(DEBUG_FLAGS) -c graph-loader.cpp -o graph-loader.o

spgk.o: spgk.cpp spgk.hpp vector-kernels.hpp
	c++ $(DEBUG_FLAGS) -c spgk.cpp -o spgk.o

vector-kernels.o: vector-kernels.cpp vector-kernels.hpp
	c++ $(DEBUG_FLAGS) -c vector-kernels.cpp -o vector-kernels.o

timer.o: timer.c timer.h
	cc $(DEBUG_FLAGS) -c timer.c -o timer.o

