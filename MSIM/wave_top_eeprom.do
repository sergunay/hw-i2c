onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label sim_clk /top_tb_eeprom/sim_clk
add wave -noupdate -divider CTRL
add wave -noupdate -label state_reg /top_tb_eeprom/DUT/I_I2C_CTRL/state_reg
add wave -noupdate -label cmd_cnt -radix unsigned /top_tb_eeprom/DUT/I_I2C_CTRL/cmd_cnt
add wave -noupdate -label data_wr -radix hexadecimal /top_tb_eeprom/DUT/I_I2C_CTRL/data_wr
add wave -noupdate -label dev_addr -radix hexadecimal /top_tb_eeprom/DUT/I_I2C_CTRL/dev_addr
add wave -noupdate -label reg_addr -radix hexadecimal /top_tb_eeprom/DUT/I_I2C_CTRL/reg_addr
add wave -noupdate -label oR_wn /top_tb_eeprom/DUT/I_I2C_CTRL/oR_wn
add wave -noupdate -divider MASTER
add wave -noupdate -label state_reg /top_tb_eeprom/DUT/I_I2C_MASTER/state_reg
add wave -noupdate -label ack_received_clear /top_tb_eeprom/DUT/I_I2C_MASTER/ack_received_clear
add wave -noupdate -label ack_received_flag /top_tb_eeprom/DUT/I_I2C_MASTER/ack_received_flag
add wave -noupdate -label ack_received_set /top_tb_eeprom/DUT/I_I2C_MASTER/ack_received_set
add wave -noupdate -label scl_rising /top_tb_eeprom/DUT/I_I2C_MASTER/scl_rising
add wave -noupdate -label scl_in /top_tb_eeprom/DUT/scl_in
add wave -noupdate -label sda_in /top_tb_eeprom/DUT/sda_in
add wave -noupdate -label scl_out /top_tb_eeprom/DUT/scl_out
add wave -noupdate -label sda_out /top_tb_eeprom/DUT/sda_out
add wave -noupdate -label ioScl /top_tb_eeprom/DUT/I_I2C_PHY/ioScl
add wave -noupdate -label ioSda /top_tb_eeprom/DUT/I_I2C_PHY/ioSda
add wave -noupdate -label wr_data -radix hexadecimal /top_tb_eeprom/DUT/wr_data
add wave -noupdate -label rd_data -radix hexadecimal /top_tb_eeprom/DUT/rd_data
add wave -noupdate -label data_wr_reg -radix hexadecimal /top_tb_eeprom/DUT/I_I2C_MASTER/data_wr_reg
add wave -noupdate -divider EEPROM
add wave -noupdate -label THIS_STATE /top_tb_eeprom/I_EEPROM/THIS_STATE
add wave -noupdate -label DEVICE_SEL /top_tb_eeprom/I_EEPROM/DEVICE_SEL
add wave -noupdate -label RECV_BYTE /top_tb_eeprom/I_EEPROM/RECV_BYTE
add wave -noupdate -label SDA_IN /top_tb_eeprom/I_EEPROM/SDA_IN
add wave -noupdate -label SDA_OUT /top_tb_eeprom/I_EEPROM/SDA_OUT
add wave -noupdate -label SCL_IN /top_tb_eeprom/I_EEPROM/SCL_IN
add wave -noupdate -label SCL_OUT /top_tb_eeprom/I_EEPROM/SCL_OUT
add wave -noupdate -label SCL /top_tb_eeprom/I_EEPROM/SCL
add wave -noupdate -label SDA /top_tb_eeprom/I_EEPROM/SDA
add wave -noupdate -divider I2C
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {69512461 ps} 0}
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
WaveRestoreZoom {0 ps} {268847250 ps}
