
all: test-Xshort

check: test-Xshort/bests test-Xshort/plot-configs test-Xshort/plot-loops

test-Xshort:
	./generate.sh test-Xshort "1 2" "16" "1 2"

test-Xshort/runs:
	./run.sh test-Xshort $(shell pwd)/../../data/samples $(shell pwd)/../Xshort-cfg.lst 1  "1 2" "16" "1 2"

test-Xshort/bests: test-Xshort/runs
	./find-best.sh test-Xshort "1 2" "16" "1 2"

test-Xshort/plot-configs: test-Xshort/runs
	./plot-per-config.sh test-Xshort "1 2" "16" "1 2"

test-Xshort/plot-loops: test-Xshort/runs
	./plot-per-loop.sh test-Xshort "1 2" "16" "1 2"

clean:
	rm -rf test-Xshort

