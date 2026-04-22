open_project PE.xpr
set_property top tb_processing_element_core_demo [get_filesets sim_1]
launch_simulation -mode behavioral
run all
close_sim