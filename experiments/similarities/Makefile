
all: test-Xshort

check: test-Xshort/bests test-Xshort/plot-configs test-Xshort/plot-loops

test-Xshort:
	./generate.sh -d test-Xshort -v "1 2" -l "1 2" -c "16"

test-Xshort/runs:
	./run.sh -d test-Xshort -s $(shell pwd)/../../data/samples -cfg $(shell pwd)/../Xshort-cfg.lst -n 1 -v "1 2" -c "16" -l "1 2"

test-Xshort/bests: test-Xshort/runs
	./find-best.sh -d test-Xshort -v "1 2" -l "1 2" -c "16"

test-Xshort/plot-configs: test-Xshort/runs
	./plot-per-config.sh -d test-Xshort -v "1 2" -l "1 2" -c "16"

test-Xshort/plot-loops: test-Xshort/runs
	./plot-per-loop.sh -d test-Xshort -v "1 2" -l "1 2" -c "16"

clean:
	rm -rf test-Xshort

