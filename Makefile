
all: test-spgk pairwise-spgk

check: test-spgk
	./test-spgk

clean:
	rm -f pairwise-spgk.o test-spgk.o spgk.o vector-kernels.o
	rm -f test-spgk pairwise-spgk

test-spgk: test-spgk.o spgk.o vector-kernels.o
	c++ vector-kernels.o spgk.o test-spgk.o -o test-spgk

pairwise-spgk: pairwise-spgk.o spgk.o vector-kernels.o
	c++ vector-kernels.o spgk.o pairwise-spgk.o -o pairwise-spgk

pairwise-spgk.o: pairwise-spgk.cpp spgk.hpp
	c++ -O0 -g -c pairwise-spgk.cpp -o pairwise-spgk.o

test-spgk.o: test-spgk.cpp spgk.hpp
	c++ -O0 -g -c test-spgk.cpp -o test-spgk.o

spgk.o: spgk.cpp spgk.hpp vector-kernels.hpp
	c++ -O0 -g -c spgk.cpp -o spgk.o

vector-kernels.o: vector-kernels.cpp vector-kernels.hpp
	c++ -O0 -g -c vector-kernels.cpp -o vector-kernels.o

