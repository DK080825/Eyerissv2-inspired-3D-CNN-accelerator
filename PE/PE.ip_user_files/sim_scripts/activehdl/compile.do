transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib activehdl/xpm
vlib activehdl/blk_mem_gen_v8_4_9
vlib activehdl/xil_defaultlib

vmap xpm activehdl/xpm
vmap blk_mem_gen_v8_4_9 activehdl/blk_mem_gen_v8_4_9
vmap xil_defaultlib activehdl/xil_defaultlib

vlog -work xpm  -sv2k12 "+incdir+../../../../../" -l xpm -l blk_mem_gen_v8_4_9 -l xil_defaultlib \
"D:/Xilinx/Vivado/2024.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93  \
"D:/Xilinx/Vivado/2024.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work blk_mem_gen_v8_4_9  -v2k5 "+incdir+../../../../../" -l xpm -l blk_mem_gen_v8_4_9 -l xil_defaultlib \
"../../ipstatic/simulation/blk_mem_gen_v8_4.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../../" -l xpm -l blk_mem_gen_v8_4_9 -l xil_defaultlib \
"../../../PE.gen/sources_1/ip/IP_Weight_DATA_Spad_BRAM/sim/IP_Weight_DATA_Spad_BRAM.v" \
"../../../hdl/Iact_addr_Spad.v" \
"../../../hdl/Iact_data_Spad.v" \
"../../../hdl/Proccesing_Element_Core_demo.v" \
"../../../hdl/Psum_Spad_2R2W.v" \
"../../../hdl/Weight_addr_Spad.v" \
"../../../hdl/Weight_data_Spad.v" \

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../../../" -l xpm -l blk_mem_gen_v8_4_9 -l xil_defaultlib \
"../../../hdl/tb/tb_processing_element_core_demo.sv" \

vlog -work xil_defaultlib \
"glbl.v"

