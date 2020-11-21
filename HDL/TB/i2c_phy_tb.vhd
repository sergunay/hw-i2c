library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
------------------------------------------------------------------------------------------
entity i2c_phy_tb is
end entity i2c_phy_tb;
------------------------------------------------------------------------------------------
architecture bench of i2c_phy_tb is
------------------------------------------------------------------------------------------

	component i2c_phy
		port(
			iClk 		: in std_logic;
			iRst 		: in std_logic;

			iSda_out	: in std_logic;
			iScl_out	: in std_logic;

			oSda_in 	: out std_logic;
			oScl_in		: out std_logic;

			ioSda		: inout std_logic;
			ioScl		: inout std_logic);
	end component;

	constant C_CLK_PER 	: time 		:= 10 ns;

	signal sim_sda_out	: std_logic := '1';
	signal sim_scl_out 	: std_logic := '1';

	signal i2c_sda_in	: std_logic := '1';
	signal i2c_scl_in 	: std_logic := '1';

	signal phy_sda		: std_logic := 'Z';
	signal phy_scl 		: std_logic := 'Z';

	signal sim_clk		: std_logic := '1';
	signal sim_rst		: std_logic := '1';
	signal sim_stop		: boolean 	:= FALSE;				-- stop simulation?

	type verif_phase is (
		INIT,
		DRIVE_I2C,
		READ_I2C);
	signal phase 		: verif_phase;

----------------------------------------------------------------------------
begin
----------------------------------------------------------------------------

	DUT: i2c_phy
	port map(
		iClk 		=> sim_clk,
		iRst 		=> sim_rst,
		iSda_out	=> sim_sda_out,
		iScl_out	=> sim_scl_out,
		oSda_in 	=> i2c_sda_in,
		oScl_in		=> i2c_scl_in,
		ioSda		=> phy_sda,
		ioScl		=> phy_scl);

----------------------------------------------------------------------------
	--! @brief 100MHz system clock generation
	CLK_STIM : sim_clk 	<= not sim_clk after C_CLK_PER/2 when not sim_stop;
----------------------------------------------------------------------------

	TB_PROC: process
		-- Initialization procedure
		procedure init is
		begin
			sim_rst <= '1';
			wait for 4*C_CLK_PER;
			sim_rst			<= '0';
		end procedure init;

	begin
		phase 		<= INIT;
		init;

		phase 		<= DRIVE_I2C;
		sim_sda_out <= '1';
		sim_scl_out <= '1';

		wait for 8*C_CLK_PER;

		sim_sda_out <= '0';
		sim_scl_out <= '1';

		wait for 8*C_CLK_PER;

		sim_sda_out <= '0';
		sim_scl_out <= '0';

		wait for 8*C_CLK_PER;

		sim_sda_out <= '1';
		sim_scl_out <= '1';

		wait for 8*C_CLK_PER;

		phase 		<= READ_I2C;
		phy_sda 	<= 'Z';
		phy_scl	 	<= 'Z';

		wait for 8*C_CLK_PER;

		phy_sda 	<= '0';
		phy_scl 	<= 'Z';

		wait for 8*C_CLK_PER;

		phy_sda 	<= '0';
		phy_scl 	<= '0';

		wait for 8*C_CLK_PER;

		phy_sda 	<= 'Z';
		phy_scl 	<= 'Z';

		wait for 8*C_CLK_PER;

		sim_stop 	<= TRUE;

		wait;
	end process TB_PROC;
----------------------------------------------------------------------------
end bench;
----------------------------------------------------------------------------
