
all:
	make -C lib all
	make -C src all
	make -C data all
	make -C experiments all

check:
	make -C lib check
	make -C src check
	make -C data check
	make -C experiments check

clean:
	make -C lib clean
	make -C src clean
	make -C data clean
	make -C experiments clean

