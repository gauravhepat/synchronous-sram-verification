# ===============================
# Parameterized Vivado Simulation
# ===============================

# Arguments from Python
set DATA_WIDTH  [lindex $argv 0]
set ADDR_WIDTH  [lindex $argv 1]

puts "Running simulation with:"
puts "DATA_WIDTH = $DATA_WIDTH"
puts "ADDR_WIDTH = $ADDR_WIDTH"

open_project "D:/Verilog Projects/My_Project_AI/My_Project_AI.xpr"

# Set parameters for simulation
set_property generic "DATA_WIDTH=$DATA_WIDTH ADDR_WIDTH=$ADDR_WIDTH" [get_filesets sim_1]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

launch_simulation
run 200 ns
close_sim

exit
