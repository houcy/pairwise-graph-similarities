DEBUG_FLAGS=-Wall -g -O0 -pg
PROD_FLAGS=-Wall -O3 -fopenmp

#FLAGS=-fopenmp $(DEBUG_FLAGS)
FLAGS=-fopenmp $(PROD_FLAGS)

all: install test-cfg test-spgk pairwise-spgk test-fw fw-time fw-time-ver

warshall: fw-time fw-time-0 fw-time-1 fw-time-2 fw-time-3 fw-time-4 fw-time-5
plot-warshall-small: fw-time fw-time-0 fw-time-1 fw-time-2 fw-time-3 fw-time-4 \
	fw-time-5
	./genfw.sh samples/FdCMeDTY76jcz1EpqLhQ/FdCMeDTY76jcz1EpqLhQ-rtn_3.json

plot-warshall: fw-time fw-time-0 fw-time-1 fw-time-2 fw-time-3 fw-time-4       \
	fw-time-5
	./genfw.sh samples/85lCRjIZmV670qYBJSNo/85lCRjIZmV670qYBJSNo-rtn_80.json

check: check-cfg check-spgk check-pairwise test-fw

check-cfg: test-cfg
	./test-cfg samples/0BZQIJak6Pu2tyAXfrzR/0BZQIJak6Pu2tyAXfrzR-sub_41F46A.jso\
		n samples/FdCMeDTY76jcz1EpqLhQ/FdCMeDTY76jcz1EpqLhQ-sub_4E671E.json

check-spgk: test-spgk
	./test-spgk 10 10 5 500 # 10 nodes per graph, 5 features per node, and 50% \
		chance for an edge to exist

check-pairwise: pairwise-spgk samples
	./pairwise-spgk 0BZQIJak6Pu2tyAXfrzR 0WQtf1pNPdRqUI7KJFAT samples \
		instructions.lst

check-fw: test-fw samples
	./test-fw samples/7h32P6rADjMVEQuoOJIB/7h32P6rADjMVEQuoOJIB-rtn_1.json

samples: samples.tgz
	tar xzf samples.tgz

install:
	mkdir -p spgkV/fw/exe
	$(foreach fwv,0 1, $(foreach inner,0 1, mkdir -p spgkV/fw$(fwv)$(inner)/exe\
		;))

clean:
	rm -f test-cfg test-spgk pairwise-spgk
	rm -f *.o *.dot *.svg spgkV/* tests/* -r
	rm -f fw-time* warshall_heat.png gmon.out 3dfw.dat testdatafw.dat test-fw
	rm -f fw00 fw01 fw10 fw11 fwverMaster
	rm -f tempRow hashed.txt

genFW: fw-time fw-time-ver
	./genfw.sh samples/ADzc7SVJd1YE69kCZv5y/ADzc7SVJd1YE69kCZv5y-rtn_3.json

test-fw: test-fw.o spgk.o graph-loader.o timer.o vector-kernels.o
	c++ $(FLAGS) -lrt vector-kernels.o test-fw.o spgk.o graph-loader.o jsonxx.o\
		timer.o -o test-fw

fw-time: time-fw.o spgk.o graph-loader.o timer.o vector-kernels.o
	c++ $(FLAGS) -lrt vector-kernels.o time-fw.o spgk.o graph-loader.o jsonxx.o\
		timer.o -o spgkV/fw/exe/timeFW

fw-time-ver: time-fw.o spgkFWX graph-loader.o timer.o vector-kernels.o
	> fwverMaster
	$(foreach i,0 1, \
		$(foreach j, 0, \
			> fw$(i)$(j);\
			echo "fw$(i)$(j)" >> fwverMaster; \
			$(foreach chunkSize, 4 16 64 128, \
				echo "timeFW$(i)$(j)chunk_$(chunkSize)" >> fw$(i)$(j); \
				c++ $(FLAGS) -lrt vector-kernels.o time-fw.o \
				spgkV/fw/spgkFW$(i)$(j)chunk_$(chunkSize).o \
				graph-loader.o jsonxx.o timer.o -o \
				spgkV/fw$(i)$(j)/exe/timeFW$(i)$(j)chunk_$(chunkSize); \
			)))

test-cfg: test-cfg.o spgk.o vector-kernels.o timer.o graph-loader.o jsonxx.o
	c++  $(FLAGS) -lrt vector-kernels.o spgk.o timer.o test-cfg.o \
		graph-loader.o jsonxx.o -o test-cfg

test-spgk: test-spgk.o spgk.o vector-kernels.o timer.o
	c++  $(FLAGS) -lrt vector-kernels.o spgk.o timer.o test-spgk.o -o test-spgk

pairwise-spgk: pairwise-spgk.o timer.o spgk.o vector-kernels.o \
	pairwise-similarity.o graph-loader.o jsonxx.o
	c++ $(FLAGS) vector-kernels.o timer.o spgk.o jsonxx.o graph-loader.o \
		pairwise-similarity.o pairwise-spgk.o -o pairwise-spgk

test-fw.o: test-fw.cpp spgk.hpp graph-loader.hpp timer.h
	c++ $(FLAGS) -c test-fw.cpp -o test-fw.o

time-fw.o: time-fw.cpp spgk.hpp graph-loader.hpp timer.h
	c++ $(FLAGS) -c time-fw.cpp -o time-fw.o

pairwise-spgk.o: pairwise-spgk.cpp spgk.hpp
	c++ $(FLAGS) -c pairwise-spgk.cpp -o pairwise-spgk.o

test-spgk.o: test-spgk.cpp spgk.hpp timer.h
	c++ $(FLAGS) -c test-spgk.cpp -o test-spgk.o

test-cfg.o: test-cfg.cpp spgk.hpp timer.h
	c++ $(FLAGS) -c test-cfg.cpp -o test-cfg.o

run-cfg.o: run-cfg.cpp spgk.hpp timer.h
	c++ $(FLAGS) -c run-cfg.cpp -o run-cfg.o

pairwise-similarity.o: pairwise-similarity.cpp pairwise-similarity.hpp
	c++ $(FLAGS) -c pairwise-similarity.cpp -o pairwise-similarity.o

jsonxx.o: jsonxx.cpp jsonxx.hpp
	c++ $(FLAGS) -c jsonxx.cpp -o jsonxx.o

graph-loader.o: graph-loader.cpp graph-loader.hpp vector-kernels.hpp jsonxx.hpp
	c++ $(FLAGS) -c graph-loader.cpp -o graph-loader.o

spgk.o: spgk.cpp spgk.hpp vector-kernels.hpp
	c++ $(FLAGS) -c spgk.cpp -o spgk.o

spgkV.o: spgk.cpp spgk.hpp vector-kernels.hpp
	$(foreach i,0 1, \
		$(foreach j, 0 1, \
		$(foreach k, 0 1, \
		$(foreach l, 0 1, \
		$(foreach chunk, 1 2 4 8, \
		c++ $(FLAGS) -DOMP_SPGK=0 -DOMP_SPGKA=$(i) -DOMP_SPGKB=$(j) \
		-DOMP_SPGKC=$(k)  -DOMP_SPGKD=$(l) -DSPGK_CHUNK=$(chunk) -c \
		spgk.cpp -o spgkV/spgk$(i)$(j)$(k)$(l)chunk_$(chunk).o ; \
	)))))

spgkFWX: spgk.cpp spgk.hpp vector-kernels.hpp
	$(foreach chunk,4 16 64 128, \
		$(foreach fwv,0 1, \
		$(foreach inner,0, \
			c++ $(FLAGS) -DOMP_FW=$(fwv) -DFW_CHUNK=$(chunk) \
			-DOMP_FW_INNER=$(inner) -c spgk.cpp -o \
			spgkV/fw/spgkFW$(fwv)$(inner)chunk_$(chunk).o ; \
		)))

vector-kernels.o: vector-kernels.cpp vector-kernels.hpp
	c++ $(FLAGS) -c vector-kernels.cpp -o vector-kernels.o

timer.o: timer.c timer.h
	cc $(FLAGS) -c timer.c -o timer.o

run-cfg-seq: run-cfg.o timer.o spgk.o graph-loader.o jsonxx.o vector-kernels.o
	c++  $(FLAGS) -lrt run-cfg.o timer.o spgk.o graph-loader.o jsonxx.o vector-kernels.o -o run-cfg-seq
