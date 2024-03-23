uvm:
	vlog -work work -sv -stats=none C:/work/ST/simulation/tb_captur_1.sv C:/Tools/uvm/1800.2-2020.3.0/src/uvm_pkg.sv +incdir+C:/Tools/uvm/1800.2-2020.3.0/src

com:
	# vlib work && vlog '-timescale' '1ns/1ns' '-sv09compat' C:/Tools/uvm/1800.2-2020.3.0/src/uvm_pkg.sv +incdir+C:/Tools/uvm/1800.2-2020.3.0/src design.sv testbench.sv && vsim -c -do "vsim +UVM_VERBOSITY=UVM_HIGH +access+r; run -all; exit"
	# vlib work && vlog -sv -stats=none C:/Tools/uvm/1800.2-2020.3.0/src/uvm_pkg.sv +incdir+C:/Tools/uvm/1800.2-2020.3.0/src design.sv testbench.sv && vsim -c -do "vsim +UVM_VERBOSITY=UVM_HIGH +access+r; run -all; exit"
	# vlib work && vlog -sv -stats=none C:/Tools/uvm/1800.2-2020-1.1/src/uvm_pkg.sv +incdir+C:/Tools/uvm/1800.2-2020-1.1/src design.sv testbench.sv && vsim -c -do "vsim +UVM_VERBOSITY=UVM_HIGH +access+r; run -all; exit"
	vlib work && vlog -sv -stats=none C:/Tools/uvm/1800.2-2020-1.1/src/uvm_pkg.sv +incdir+C:/Tools/uvm/1800.2-2020-1.1/src design.sv testbench.sv && vsim work.top -i -do "vsim +UVM_VERBOSITY=UVM_HIGH +access+r; run -all; exit"
