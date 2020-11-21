onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider SIM
add wave -noupdate -label sim_clk /top_tb/sim_clk
add wave -noupdate -label sim-phase /top_tb/phase
add wave -noupdate -divider TOP
add wave -noupdate -label scl_in /top_tb/DUT/scl_in
add wave -noupdate -label scl_out /top_tb/DUT/scl_out
add wave -noupdate -label ack_received_flag /top_tb/DUT/I_I2C_MASTER/ack_received_flag
add wave -noupdate -label sda_in /top_tb/DUT/sda_in
add wave -noupdate -label sda_out /top_tb/DUT/sda_out
add wave -noupdate -label dev_addr -radix hexadecimal /top_tb/DUT/dev_addr
add wave -noupdate -label reg_addr -radix hexadecimal /top_tb/DUT/reg_addr
add wave -noupdate -label wr_data -radix hexadecimal /top_tb/DUT/wr_data
add wave -noupdate -label rd_data -radix hexadecimal /top_tb/DUT/rd_data
add wave -noupdate -label r_wn /top_tb/DUT/r_wn
add wave -noupdate -divider CTRL
add wave -noupdate -label state_reg /top_tb/DUT/I_I2C_CTRL/state_reg
add wave -noupdate -label ack /top_tb/DUT/I_I2C_CTRL/ack
add wave -noupdate -label cmd_cnt -radix unsigned /top_tb/DUT/I_I2C_CTRL/cmd_cnt
add wave -noupdate -label cmd_cnt_en /top_tb/DUT/I_I2C_CTRL/cmd_cnt_en
add wave -noupdate -label dev_addr -radix hexadecimal /top_tb/DUT/I_I2C_CTRL/dev_addr
add wave -noupdate -label reg_addr -radix hexadecimal /top_tb/DUT/I_I2C_CTRL/reg_addr
add wave -noupdate -label data_rd_reg -radix hexadecimal /top_tb/DUT/I_I2C_CTRL/data_rd_reg
add wave -noupdate -divider MASTER
add wave -noupdate -label state_reg /top_tb/DUT/I_I2C_MASTER/state_reg
add wave -noupdate -label req /top_tb/DUT/I_I2C_MASTER/req
add wave -noupdate -label op /top_tb/DUT/I_I2C_MASTER/op
add wave -noupdate -label data_rd_reg -radix hexadecimal /top_tb/DUT/I_I2C_MASTER/data_rd_reg
add wave -noupdate -label data_wr_reg -radix hexadecimal /top_tb/DUT/I_I2C_MASTER/data_wr_reg
add wave -noupdate -label dev_addr_reg -radix hexadecimal /top_tb/DUT/I_I2C_MASTER/dev_addr_reg
add wave -noupdate -label bit_cnt_reg -radix unsigned /top_tb/DUT/I_I2C_MASTER/bit_cnt_reg
add wave -noupdate -label reg_addr_reg -radix hexadecimal /top_tb/DUT/I_I2C_MASTER/reg_addr_reg
add wave -noupdate -label oAck /top_tb/DUT/I_I2C_MASTER/oAck
add wave -noupdate -divider I2C-OUT
add wave -noupdate -label scl /top_tb/scl
add wave -noupdate -label sda /top_tb/sda
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {119175997 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 179
configure wave -valuecolwidth 139
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {218951250 ps}
