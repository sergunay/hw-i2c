onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label sim_clk /i2c_ctrl_tb/sim_clk
add wave -noupdate -label sim_rd_data -radix hexadecimal /i2c_ctrl_tb/sim_rd_data
add wave -noupdate -label sim_phase /i2c_ctrl_tb/phase
add wave -noupdate -label sim_ack /i2c_ctrl_tb/sim_ack
add wave -noupdate -divider INT
add wave -noupdate -label timer_cnt -radix unsigned /i2c_ctrl_tb/DUT/timer_cnt
add wave -noupdate -label state_reg /i2c_ctrl_tb/DUT/state_reg
add wave -noupdate -label i2c_ack /i2c_ctrl_tb/i2c_ack
add wave -noupdate -label i2c_dev_addr -radix hexadecimal /i2c_ctrl_tb/i2c_dev_addr
add wave -noupdate -label i2c_reg_addr -radix hexadecimal /i2c_ctrl_tb/i2c_reg_addr
add wave -noupdate -label i2c_wr_data -radix hexadecimal /i2c_ctrl_tb/i2c_wr_data
add wave -noupdate -label i2c_req /i2c_ctrl_tb/i2c_req
add wave -noupdate -label i2c_r_wn /i2c_ctrl_tb/i2c_r_wn
add wave -noupdate -label data_rd -radix hexadecimal /i2c_ctrl_tb/DUT/data_rd
add wave -noupdate -divider CMD
add wave -noupdate -label cmd_cnt -radix unsigned /i2c_ctrl_tb/DUT/cmd_cnt
add wave -noupdate -label cmd -radix hexadecimal /i2c_ctrl_tb/DUT/cmd
add wave -noupdate -label cmd_cnt_en /i2c_ctrl_tb/DUT/cmd_cnt_en
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1050000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {1695750 ps}
