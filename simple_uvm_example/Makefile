PWD_W = $(shell (exec 2>/dev/null; cd / && pwd -W ) | grep ':' >/dev/null && echo "pwd -W" || echo "pwd")

# UVM_PATH = $(shell realpath ~/UVM/1800.2-2020-1.1)
UVM_PATH = $(shell (cd ~/uvm-1.2; $(PWD_W)))
MODEL_SIM_PATH = $(shell realpath ~/intelFPGA/20.1/modelsim_ase/)
MSI_FILE = $(MODEL_SIM_PATH)/modelsim.ini


.PHONY: com
com:
	../questa_license/run.sh vlog \
		-reportprogress 300 -work work -sv -stats=none -lint\
		+incdir+$(UVM_PATH)/src +define+CL_USE_MODELSIM \
		-ccflags "-DQUESTA" -ccflags "-Wno-missing-declarations" -ccflags "-Wno-return-type" \
		$(UVM_PATH)/src/uvm_pkg.sv $(UVM_PATH)/src/dpi/uvm_dpi.cc testbench.sv


.PHONY: run
run:
	# -keepstdout -geometry 1000x1000+0+0 -do "run"
	../questa_license/run.sh vsim -i work.$(MODULE) \
		-displaymsgmode tran \
		-msgmode tran \
		-wlfdeleteonquit \
		> /dev/null 2>&1 \
		&


.PHONY: uvm
uvm:
	# get from http://www.accellera.org/images/downloads/standards/uvm/uvm-1.2.tar.gz
	wget -nc http://www.accellera.org/images/downloads/standards/uvm/uvm-1.2.tar.gz
	mkdir -p ~/uvm-1.2
	- tar -xvzf uvm-1.2.tar.gz -C ~/
	rm uvm-1.2.tar.gz


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
