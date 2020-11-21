onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider SIM
add wave -noupdate -label sim_clk /i2c_phy_tb/sim_clk
add wave -noupdate -label sim_rst /i2c_phy_tb/sim_rst
add wave -noupdate -label phase /i2c_phy_tb/phase
add wave -noupdate -label sim_scl_out /i2c_phy_tb/sim_scl_out
add wave -noupdate -label sim_sda_out /i2c_phy_tb/sim_sda_out
add wave -noupdate -divider I2C-INT
add wave -noupdate -label scl_in /i2c_phy_tb/DUT/scl_in
add wave -noupdate -label sda_in /i2c_phy_tb/DUT/sda_in
add wave -noupdate -divider PHY
add wave -noupdate -label phy_scl /i2c_phy_tb/phy_scl
add wave -noupdate -label phy_sda /i2c_phy_tb/phy_sda
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {474419 ps} 0}
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
WaveRestoreZoom {0 ps} {719250 ps}
