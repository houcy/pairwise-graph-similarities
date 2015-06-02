
all:
	make -C lib all
	make -C src all
	make -C data all

check:
	make -C lib check
	make -C src check
	make -C data check

clean:
	make -C lib clean
	make -C src clean
	make -C data clean

