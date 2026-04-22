onbreak {quit -f}
onerror {quit -f}

vsim  -lib xil_defaultlib tb_processing_element_core_demo_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {tb_processing_element_core_demo.udo}

run 1000ns

quit -force
