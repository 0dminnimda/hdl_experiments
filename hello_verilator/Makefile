.PHONY: all
all: compile

.PHONY: compile_super_new
compile_super_new:
	verilator --cc --exe --build -j 0 -Wall sim_main.cpp our.v

.PHONY: compile_new
compile_new:
	verilator --cc --exe --build -Wall sim_main.cpp our.v

.PHONY: compile
compile:
	verilator --cc --exe -Wall sim_main.cpp our.v
	make -C obj_dir -f Vour.mk

.PHONY: compile_sc
compile_sc:
	verilator --sc --exe -Wall sc_main.cpp our.v
	make -j -C obj_dir -f Vour.mk Vour

.PHONY: run
run:
	./obj_dir/Vour

.PHONY: clean
clean:
	rm -rf obj_dir
