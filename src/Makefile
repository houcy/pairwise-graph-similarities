DEBUG_FLAGS=-Wall -g -O0 -pg 
PROD_FLAGS=-Wall -O3 

#CXX_FLAGS=-fopenmp $(DEBUG_FLAGS) -I../include
CXX_FLAGS=-fopenmp $(PROD_FLAGS) -I../include

LD_FLAGS=-lrt

all: run-fw run-cfg

check: check-fw check-cfg

clean:
	rm -f run-fw run-cfg
	rm -f *.o

### TARGETS

run-fw.o: run-fw.cpp ../include/spgk.hpp ../include/timer.h
	c++ $(CXX_FLAGS) -c run-fw.cpp -o run-fw.o

run-fw: run-fw.o ../lib/jsonxx.o ../lib/graph-loader.o ../lib/spgk.o ../lib/vector-kernels.o ../lib/timer.o
	c++ $(LD_FLAGS) run-fw.o ../lib/jsonxx.o ../lib/graph-loader.o ../lib/spgk.o ../lib/vector-kernels.o ../lib/timer.o -o run-fw

check-fw: run-fw ../data/samples
	./run-fw ../data/samples/0BZQIJak6Pu2tyAXfrzR/0BZQIJak6Pu2tyAXfrzR-sub_41F46A.json
	./run-fw ../data/samples/FdCMeDTY76jcz1EpqLhQ/FdCMeDTY76jcz1EpqLhQ-sub_4E671E.json

run-cfg.o: run-cfg.cpp ../include/spgk.hpp ../include/timer.h
	c++ $(CXX_FLAGS) -c run-cfg.cpp -o run-cfg.o

run-cfg: run-cfg.o ../lib/jsonxx.o ../lib/graph-loader.o ../lib/spgk.o ../lib/vector-kernels.o ../lib/timer.o
	c++ $(LD_FLAGS) run-cfg.o ../lib/jsonxx.o ../lib/graph-loader.o ../lib/spgk.o ../lib/vector-kernels.o ../lib/timer.o -o run-cfg

check-cfg: run-cfg ../data/samples
	./run-cfg ../data/samples/0BZQIJak6Pu2tyAXfrzR/0BZQIJak6Pu2tyAXfrzR-sub_41F46A.json ../data/samples/FdCMeDTY76jcz1EpqLhQ/FdCMeDTY76jcz1EpqLhQ-sub_4E671E.json

### LIBS

../lib/jsonxx.o:
	make -C ../lib/ jsonxx.o

../lib/graph-loader.o:
	make -C ../lib/ graph-loader.o

../lib/spgk.o:
	make -C ../lib/ spgk.o

../lib/vector-kernels.o:
	make -C ../lib/ vector-kernels.o

../lib/timer.o:
	make -C ../lib/ timer.o

../data/samples: 
	make -C ../data/ samples

