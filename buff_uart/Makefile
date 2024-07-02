# C:/intelFPGA/18.1/modelsim_ase/win32aloem

PWD_W = $(shell (exec 2>/dev/null; cd / && pwd -W ) | grep ':' >/dev/null && echo "pwd -W" || echo "pwd")

# UVM_PATH = $(shell realpath ~/UVM/1800.2-2020-1.1)
UVM_PATH = $(shell (cd ~/uvm-1.2; $(PWD_W)))
MODEL_SIM_PATH = $(shell realpath ~/intelFPGA/20.1/modelsim_ase/)
MSI_FILE = $(MODEL_SIM_PATH)/modelsim.ini

FILE="mod.sv"

.PHONY: build
build:
	mkdir -p build
	sleep .2  # make sure directory will be created and available

.PHONY: compile
compile: build
	../questa_license/run.sh vlog \
		-reportprogress 300 -work build -sv -stats=none -lint \
		+incdir+$(UVM_PATH)/src +define+CL_USE_MODELSIM \
		-ccflags "-DQUESTA" -ccflags "-Wno-missing-declarations" -ccflags "-Wno-return-type" \
		$(UVM_PATH)/src/uvm_pkg.sv $(UVM_PATH)/src/dpi/uvm_dpi.cc $(FILE)

.PHONY: run
run:
	# -keepstdout -geometry 1000x1000+0+0 -do "run"
	../questa_license/run.sh vsim -i build.$(MODULE) \
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

.PHONY: wlf
wlf:
	../questa_license/run.sh vsim -view vsim.wlf

# make compile FILE=tb/addressable_tb.sv
# make run MODULE=tb_rw_addressable

# make compile FILE=tb/fifo_tb.sv
# make run MODULE=tb_fifo

# make compile FILE=tb/uart_rx_tb.sv
# make run MODULE=tb_uart_rx

# make compile FILE=tb/uart_tx_tb.sv
# make run MODULE=tb_uart_tx

# make compile FILE=tb/buff_uart_tb.sv
# make run MODULE=tb_buff_uart

# make compile FILE=tb/buff_uart_uvm/buff_uart_tb_top.sv
# make run MODULE=top

# vsim tb_top +UVM_TESTNAME=my_test

.PHONY: verilator
verilator:
	/usr/local/bin/verilator --binary -j 0 tb/buff_uart_tb.sv -I. -Iif -Itb --top-module tb_buff_uart --assert \
		-Wno-CASEINCOMPLETE -Wno-WIDTHTRUNC -Wno-WIDTHEXPAND -Wno-BLKLOOPINIT -Wno-MULTIDRIVEN

.PHONY: verilator_dr
verilator_dr:
	verilator --binary -j 0 tb/buff_uart_tb.sv -I. -Iif -Itb --top-module tb_buff_uart --assert \
		-Wno-CASEINCOMPLETE -Wno-WIDTHTRUNC -Wno-WIDTHEXPAND -Wno-BLKLOOPINIT -Wno-MULTIDRIVEN

.PHONY: verilator_run
verilator_run:
	./obj_dir/Vtb_buff_uart



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
	# iverilog \
	# 	-s top -I /mnt/c/Tools/uvm/1800.2-2020-1.1/src \
	# 	-o testbench testbench.sv
	iverilog \
		-s tb_buff_uart -I. -Itb -Iif \
		-o testbench tb/buff_uart_tb.sv
	# /mnt/c/Tools/uvm/1800.2-2020-1.1/src/uvm_pkg.sv

.PHONY: icarus_wsl_run
icarus_wsl_run:
	vvp testbench


# .PHONY: icarus_dr
# icarus_dr:
# 	iverilog \
# 		-s top -I /mnt/c/Tools/uvm/1800.2-2020-1.1/src \
# 		-o testbench testbench.sv
# 	# /mnt/c/Tools/uvm/1800.2-2020-1.1/src/uvm_pkg.sv

# .PHONY: icarus_dr_run
# icarus_dr_run:
# 	vvp testbench


.PHONY: clean
clean:
	rm -rf build
