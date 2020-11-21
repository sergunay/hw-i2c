--! @file 			top_tb_eeprom.vhd
--! @brief 			Testbench of top (i2c) module
--! @details
--! @author 		Selman Ergunay
------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
------------------------------------------------------------------------------------------
entity top_tb_eeprom is
end entity top_tb_eeprom;
------------------------------------------------------------------------------------------
architecture bench of top_tb_eeprom is
------------------------------------------------------------------------------------------

	component top
	generic(
		CLK_DIV : natural := 256);
	port (
		iClk 	: in  std_logic;
		iRst 	: in  std_logic;

		ioSda	: inout std_logic;
		ioScl	: inout std_logic);
	end component;

	component I2C_EEPROM
	 generic (device : string(1 to 5) := "24C02");  --select from 24C16, 24C08, 24C04, 24C02 and 24C01
	 port (
	  STRETCH            : IN    time := 1 ns;      --pull SCL low for this time-value;
	  E0                 : IN    std_logic := 'L';  --leave unconnected for 24C16, 24C08, 24C04
	  E1                 : IN    std_logic := 'L';  --leave unconnected for 24C16, 24C08
	  E2                 : IN    std_logic := 'L';  --leave unconnected for 24C16
	  WC                 : IN    std_logic := 'L';  --tie high to disable write mode
	  SCL                : INOUT std_logic;
	  SDA                : INOUT std_logic
	);
	end component;

	constant C_CLK_PER 	: time 		:= 10 ns;
	constant C_CLK_DIV	: natural 	:= 256;

	signal sim_clk 		: std_logic := '0';
	signal sim_rst	 	: std_logic := '0';
	signal sim_stop		: boolean 	:= FALSE;				-- stop simulation?


	signal top_sda	 	: std_logic := 'Z';
	signal top_scl	 	: std_logic := 'Z';

	signal eeprom_sda	: std_logic := 'Z';
	signal eeprom_scl	: std_logic := 'Z';

----------------------------------------------------------------------------
begin
----------------------------------------------------------------------------

	DUT: top
	generic map(
		CLK_DIV => C_CLK_DIV)
	port map(
		iClk 	=> sim_clk,
		iRst 	=> sim_rst,

		ioSda	=> top_sda,
		ioScl	=> top_scl);

	I_EEPROM: I2C_EEPROM
	 generic map(
		 device => "24C02")  --select from 24C16, 24C08, 24C04, 24C02 and 24C01
	 port map(
	  STRETCH  => 1 ns,
	  E0       => 'L',
	  E1       => 'L',
	  E2       => 'L',
	  WC       => 'L',
	  SCL      => top_scl,
	  SDA      => top_sda);

----------------------------------------------------------------------------
	--! @brief 100MHz system clock generation
	CLK_STIM : sim_clk 	<= not sim_clk after C_CLK_PER/2 when not sim_stop;
----------------------------------------------------------------------------

	TB_PROC: process

	begin -- process TB_PROC

		sim_rst <= '1';
		wait for 4*C_CLK_PER;
		sim_rst	<= '0';

		wait for 150*C_CLK_DIV*C_CLK_PER;

		sim_stop 	<= TRUE;

		wait;
	end process TB_PROC;
----------------------------------------------------------------------------
end bench;
----------------------------------------------------------------------------
