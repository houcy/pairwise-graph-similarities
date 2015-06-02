
DEBUG_FLAGS=-Wall -g -O0 -pg 
PROD_FLAGS=-Wall -O3 

#FLAGS=-fopenmp $(DEBUG_FLAGS)
FLAGS=-fopenmp $(PROD_FLAGS) -I../include

all: jsonxx.o graph-loader.o vector-kernels.o timer.o spgk.o

check:

clean:
	rm -f *.o

### TARGETS

jsonxx.o: jsonxx.cpp ../include/jsonxx.hpp
	c++ $(FLAGS) -c jsonxx.cpp -o jsonxx.o

graph-loader.o: graph-loader.cpp ../include/graph-loader.hpp ../include/vector-kernels.hpp ../include/jsonxx.hpp
	c++ $(FLAGS) -DINST_FILE="\"$(shell pwd)/../data/instructions.lst\"" -c graph-loader.cpp -o graph-loader.o

vector-kernels.o: vector-kernels.cpp ../include/vector-kernels.hpp
	c++ $(FLAGS) -c vector-kernels.cpp -o vector-kernels.o

timer.o: timer.c ../include/timer.h
	cc $(FLAGS) -c timer.c -o timer.o

spgk.o: spgk.cpp ../include/spgk.hpp ../include/vector-kernels.hpp
	c++ $(FLAGS) -c spgk.cpp -o spgk.o

