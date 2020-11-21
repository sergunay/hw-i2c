--! @file           i2c_ctrl_pkg.vhd
--! @brief          List of I2C commands to be executed.
--! @details        24-bit commands stored as:
--!                 DEV_ADDR(8-bit) & REG_ADDR(8-bit) & DATA(8-bit)
--! @author         Selman Ergunay
--! @date           2019-04-11
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package i2c_ctrl_pkg is

	constant C_NB_CMD : natural := 2;

	type I2C_CMD_LIST_TYPE is array(0 to C_NB_CMD-1) of std_logic_vector(23 downto 0);

	constant I2C_CMD_LIST : I2C_CMD_LIST_TYPE :=
		(
			-- EEPROM read-write test
			X"A0_12_CD",
			X"A1_12_00"
		);
end package i2c_ctrl_pkg;
