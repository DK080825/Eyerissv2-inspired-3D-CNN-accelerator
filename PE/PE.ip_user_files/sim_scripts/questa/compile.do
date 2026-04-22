vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xpm
vlib questa_lib/msim/blk_mem_gen_v8_4_9
vlib questa_lib/msim/xil_defaultlib

vmap xpm questa_lib/msim/xpm
vmap blk_mem_gen_v8_4_9 questa_lib/msim/blk_mem_gen_v8_4_9
vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xpm  -incr -mfcu  -sv "+incdir+../../../../../" \
"D:/Xilinx/Vivado/2024.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm  -93  \
"D:/Xilinx/Vivado/2024.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work blk_mem_gen_v8_4_9  -incr -mfcu  "+incdir+../../../../../" \
"../../ipstatic/simulation/blk_mem_gen_v8_4.v" \

vlog -work xil_defaultlib  -incr -mfcu  "+incdir+../../../../../" \
"../../../PE.gen/sources_1/ip/IP_Weight_DATA_Spad_BRAM/sim/IP_Weight_DATA_Spad_BRAM.v" \
"../../../hdl/Iact_addr_Spad.v" \
"../../../hdl/Iact_data_Spad.v" \
"../../../hdl/Proccesing_Element_Core_demo.v" \
"../../../hdl/Psum_Spad_2R2W.v" \
"../../../hdl/Weight_addr_Spad.v" \
"../../../hdl/Weight_data_Spad.v" \

vlog -work xil_defaultlib  -incr -mfcu  -sv "+incdir+../../../../../" \
"../../../hdl/tb/tb_processing_element_core_demo.sv" \

vlog -work xil_defaultlib \
"glbl.v"

