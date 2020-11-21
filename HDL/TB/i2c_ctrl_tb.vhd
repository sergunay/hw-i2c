library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
------------------------------------------------------------------------------------------
entity i2c_ctrl_tb is
end entity i2c_ctrl_tb;
------------------------------------------------------------------------------------------
architecture bench of i2c_ctrl_tb is
------------------------------------------------------------------------------------------

	constant C_CLK_PER 	: time 		:= 10 ns;
	constant C_CLK_DIV	: natural 	:= 256;

	signal sim_clk 		: std_logic := '0';
	signal sim_rst	 	: std_logic := '0';
	signal sim_stop		: boolean 	:= FALSE;				-- stop simulation?
	signal i2c_req		: std_logic := '0';
	signal i2c_r_wn		: std_logic := '0';
	signal sim_rd_data	: std_logic_vector(7 downto 0) := (others=>'0');

	signal sim_ack		: std_logic := '0';

	signal i2c_ack		: std_logic := '0';
	signal i2c_wr_data 	: std_logic_vector(7 downto 0) := (others=>'0');
	signal i2c_dev_addr	: std_logic_vector(6 downto 0) := (others=>'0');
	signal i2c_reg_addr	: std_logic_vector(7 downto 0) := (others=>'0');
	signal sim_error	: std_logic_vector(2 downto 0) := (others=>'0');

	type verif_phase is (
		INIT,
		READ,
		WRITE);
	signal phase 		: verif_phase;

	component i2c_ctrl
	  port(
		iClk 		: in  std_logic;
		iRst 		: in  std_logic;
		oDev_addr	: out std_logic_vector(6 downto 0);
		oReg_addr	: out std_logic_vector(7 downto 0);
		oData		: out std_logic_vector(7 downto 0);
		iData		: in  std_logic_vector(7 downto 0);
		oReq 		: out std_logic;
		oR_wn		: out std_logic;
		iAck		: in  std_logic;
		iError 		: in  std_logic_vector(2 downto 0));
	end component;

----------------------------------------------------------------------------
begin
----------------------------------------------------------------------------

	DUT: i2c_ctrl
	  port map(
		iClk 		=> sim_clk,
		iRst 		=> sim_rst,
		oDev_addr	=> i2c_dev_addr,
		oReg_addr	=> i2c_reg_addr,
		oData		=> i2c_wr_data,
		iData		=> sim_rd_data,
		oReq 		=> i2c_req,
		oR_wn		=> i2c_r_wn,
		iAck		=> sim_ack,
		iError 		=> sim_error);

----------------------------------------------------------------------------
	--! @brief 100MHz system clock generation
	CLK_STIM : sim_clk 	<= not sim_clk after C_CLK_PER/2 when not sim_stop;
----------------------------------------------------------------------------

	TB_PROC: process

	begin -- process TB_PROC

		phase	<= INIT;
		sim_rst <= '1';
		wait for 4*C_CLK_PER;
		sim_rst		<= '0';

		wait for 100*C_CLK_PER;

		sim_ack 	<= '1';
		wait for 1*C_CLK_PER;
		sim_ack 	<= '0';
		----------------------------
		phase	<= READ;
		wait for 10*C_CLK_PER;
		sim_ack 	<= '1';
		sim_rd_data	<= X"AB";
		wait for 1*C_CLK_PER;
		sim_ack 	<= '0';
		wait for 1*C_CLK_PER;
		sim_ack 	<= '1';
		wait for 1*C_CLK_PER;
		sim_ack 	<= '0';
		wait for 1*C_CLK_PER;
		sim_ack 	<= '1';
		wait for 1*C_CLK_PER;
		sim_ack 	<= '0';
		----------------------------
		phase	<= WRITE;
		wait for 20*C_CLK_PER;
		sim_ack 	<= '1';
		wait for 1*C_CLK_PER;
		sim_ack 	<= '0';

		wait for 20*C_CLK_PER;
		sim_stop 	<= TRUE;

		wait;
	end process TB_PROC;
----------------------------------------------------------------------------
end bench;
----------------------------------------------------------------------------
