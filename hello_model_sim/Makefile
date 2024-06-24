# C:/intelFPGA/18.1/modelsim_ase/win32aloem

PWD=$(shell pwd)
FILE="hello.sv"

.PHONY: build
build:
	mkdir -p build
	sleep .2  # make sure directory will be created and available

.PHONY: compile
compile: build
	- sh ../run.sh vlog -reportprogress 300 -work build $(FILE) -sv 1> /dev/null 2> /dev/null
	sleep .2
	sh ../run.sh vlog -reportprogress 300 -work build $(FILE) -sv

.PHONY: run
run:
# -keepstdout -geometry 1000x1000+0+0 -do "run"
	vsim -i build.$(MODULE) \
		-displaymsgmode tran \
		-msgmode tran \
		-wlfdeleteonquit \
		&

.PHONY: wlf
wlf:
	vsim -view vsim.wlf

.PHONY: clean
clean:
	rm -rf build
