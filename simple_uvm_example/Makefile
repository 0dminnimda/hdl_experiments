# UVM_PATH = $(shell realpath ~/UVM/1800.2-2020-1.1)
UVM_PATH = $(shell realpath ~/uvm-1.2)
MODEL_SIM_PATH = $(shell realpath ~/intelFPGA/20.1/modelsim_ase/)
MSI_FILE = $(MODEL_SIM_PATH)/modelsim.ini


.PHONY: uvm
uvm:
	# vlog -work work -sv -stats=none $(UVM_PATH)/src/uvm_pkg.sv +incdir+$(UVM_PATH)/src

	# vlog -64 -lint -modelsimini $(MSI_FILE) -quiet -sv17compat -work $(LIB_UVM) $(UVM_PATH)/src/uvm_pkg.sv +incdir+$(UVM_PATH)/src
	# vlog -64 -lint -modelsimini $(MSI_FILE) -quiet -sv17compat -work $(LIB_UVM) $(UVM_PATH)/src/uvm.sv     +incdir+$(UVM_PATH)/src

	# get from http://www.accellera.org/images/downloads/standards/uvm/uvm-1.2.tar.gz


.PHONY: com
com:
	# vlib work && vlog '-timescale' '1ns/1ns' '-sv09compat' C:/Tools/uvm/1800.2-2020.3.0/src/uvm_pkg.sv +incdir+C:/Tools/uvm/1800.2-2020.3.0/src design.sv testbench.sv && vsim -c -do "vsim +UVM_VERBOSITY=UVM_HIGH +access+r; run -all; exit"
	# vlib work && vlog -sv -stats=none C:/Tools/uvm/1800.2-2020.3.0/src/uvm_pkg.sv +incdir+C:/Tools/uvm/1800.2-2020.3.0/src design.sv testbench.sv && vsim -c -do "vsim +UVM_VERBOSITY=UVM_HIGH +access+r; run -all; exit"
	# vlib work && vlog -sv -stats=none C:/Tools/uvm/1800.2-2020-1.1/src/uvm_pkg.sv +incdir+C:/Tools/uvm/1800.2-2020-1.1/src design.sv testbench.sv && vsim work.top -i -do "vsim +UVM_VERBOSITY=UVM_HIGH +access+r; run -all; exit"
	# vlib work && vlog -sv -stats=none $(UVM_PATH)/src/uvm_pkg.sv +incdir+$(UVM_PATH)/src design.sv testbench.sv && vsim -c -do "vsim +UVM_VERBOSITY=UVM_HIGH +access+r; run -all; exit"

	# vlog -reportprogress 300 -work work -sv -stats=none $(UVM_PATH)/src/uvm_pkg.sv testbench.sv +incdir+$(UVM_PATH)/src
	vlog -reportprogress 300 -work work -sv -stats=none +incdir+$(UVM_PATH)/src +define+CL_USE_MODELSIM -ccflags "-DQUESTA" $(UVM_PATH)/src/uvm_pkg.sv $(UVM_PATH)/src/dpi/uvm_dpi.cc testbench.sv


.PHONY: run
run:
# -keepstdout -geometry 1000x1000+0+0 -do "run"
	vsim -i work.$(MODULE) \
		-displaymsgmode tran \
		-msgmode tran \
		-wlfdeleteonquit \
		> /dev/null 2>&1 \
		&


.PHONY: verilator
verilator:
	/usr/local/bin/verilator --binary -j 0 /mnt/c/Tools/uvm/uvm-verilator/src/uvm_pkg.sv testbench.sv --top-module top --assert \
		-Wno-CASEINCOMPLETE -Wno-WIDTHTRUNC -Wno-WIDTHEXPAND -Wno-BLKLOOPINIT -Wno-MULTIDRIVEN \
		-I. -I/mnt/c/Tools/uvm/uvm-verilator/src

.PHONY: verilator_run
verilator_run:
	./obj_dir/Vtop


.PHONY: icarus_win
icarus_win:
	/c/msys64/mingw64/bin/iverilog \
		-g2005-sv -s top -I C:/Tools/uvm/1800.2-2020-1.1/src \
		-o testbench testbench.sv
	# "/c/Tools/uvm/1800.2-2020-1.1/src/uvm_pkg.sv"

.PHONY: icarus_win_run
icarus_win_run:
	/c/msys64/mingw64/bin/vvp testbench


.PHONY: icarus_wsl
icarus_wsl:
	iverilog \
		-s top -I /mnt/c/Tools/uvm/1800.2-2020-1.1/src \
		-o testbench testbench.sv
	# /mnt/c/Tools/uvm/1800.2-2020-1.1/src/uvm_pkg.sv

.PHONY: icarus_wsl_run
icarus_wsl_run:
	vvp testbench
