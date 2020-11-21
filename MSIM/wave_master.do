onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider SIM
add wave -noupdate -label sim_clk /i2c_master_tb/sim_clk
add wave -noupdate -label sim_rst /i2c_master_tb/sim_rst
add wave -noupdate -label sim_req /i2c_master_tb/sim_req
add wave -noupdate -label sim_r_wn /i2c_master_tb/sim_r_wn
add wave -noupdate -label sim_dev_addr -radix hexadecimal /i2c_master_tb/sim_dev_addr
add wave -noupdate -label sim_reg_addr -radix hexadecimal /i2c_master_tb/sim_reg_addr
add wave -noupdate -label sim_data -radix hexadecimal /i2c_master_tb/sim_data
add wave -noupdate -divider I2C-INT
add wave -noupdate -label clk_cnt -radix unsigned /i2c_master_tb/DUT/clk_cnt
add wave -noupdate -label bit_cnt_reg -radix unsigned /i2c_master_tb/DUT/bit_cnt_reg
add wave -noupdate -label state_reg /i2c_master_tb/DUT/state_reg
add wave -noupdate -label scl_clk /i2c_master_tb/DUT/scl_clk
add wave -noupdate -label scl_rising /i2c_master_tb/DUT/scl_rising
add wave -noupdate -label scl_in /i2c_master_tb/DUT/scl_in
add wave -noupdate -label sda_in /i2c_master_tb/DUT/sda_in
add wave -noupdate -label op /i2c_master_tb/DUT/op
add wave -noupdate -label sda_tick /i2c_master_tb/DUT/sda_tick
add wave -noupdate -label ack_received_flag /i2c_master_tb/DUT/ack_received_flag
add wave -noupdate -label ack_received_set /i2c_master_tb/DUT/ack_received_set
add wave -noupdate -label ack_received_clear /i2c_master_tb/DUT/ack_received_clear
add wave -noupdate -label dev_addr_reg -radix hexadecimal /i2c_master_tb/DUT/dev_addr_reg
add wave -noupdate -label reg_addr_reg -radix hexadecimal /i2c_master_tb/DUT/reg_addr_reg
add wave -noupdate -label data_wr_reg -radix hexadecimal /i2c_master_tb/DUT/data_wr_reg
add wave -noupdate -label data_rd_reg -radix hexadecimal /i2c_master_tb/DUT/data_rd_reg
add wave -noupdate -label sda_out /i2c_master_tb/DUT/sda_out
add wave -noupdate -label scl_out /i2c_master_tb/DUT/scl_out
add wave -noupdate -divider I2C-OUT
add wave -noupdate -label i2c_ack /i2c_master_tb/i2c_ack
add wave -noupdate -label i2c_error /i2c_master_tb/i2c_error
add wave -noupdate -label i2c_data -radix hexadecimal /i2c_master_tb/i2c_data
add wave -noupdate -divider SIM-EVAL
add wave -noupdate -label phase /i2c_master_tb/phase
add wave -noupdate -label i2c_start /i2c_master_tb/i2c_start
add wave -noupdate -label i2c_stop /i2c_master_tb/i2c_stop
add wave -noupdate -label sim_ack /i2c_master_tb/sim_ack
add wave -noupdate -label bit_cnt -radix unsigned /i2c_master_tb/bit_cnt
add wave -noupdate -label byte_cnt -radix unsigned /i2c_master_tb/byte_cnt
add wave -noupdate -label i2c_listen_data -radix hexadecimal /i2c_master_tb/i2c_listen_data
add wave -noupdate -label byte_receiving /i2c_master_tb/byte_receiving
add wave -noupdate -label scl_line /i2c_master_tb/scl_line
add wave -noupdate -label sim_scl /i2c_master_tb/sim_scl
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {334345653 ps} 0}
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
WaveRestoreZoom {307142997 ps} {353077307 ps}
