--! @file 			top_tb.vhd
--! @brief
--! @details
--! @author 		Selman Ergunay
--! @date 			2019-04-11
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
------------------------------------------------------------------------------------------
entity top_tb is
end entity top_tb;
------------------------------------------------------------------------------------------
architecture bench of top_tb is
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

	constant C_CLK_PER 	: time 		:= 10 ns;
	constant C_CLK_DIV	: natural 	:= 256;

	signal sim_clk 		: std_logic := '0';
	signal sim_rst	 	: std_logic := '0';
	signal sim_stop		: boolean 	:= FALSE;				-- stop simulation?

	signal sda 			: std_logic := 'Z';
	signal scl 			: std_logic := 'Z';

	type verif_phase is (
		INIT,
		READ,
		WRITE);
	signal phase 		: verif_phase;

----------------------------------------------------------------------------
begin
----------------------------------------------------------------------------

	DUT: top
	generic map(
		CLK_DIV => C_CLK_DIV)
	port map(
		iClk 	=> sim_clk,
		iRst 	=> sim_rst,

		ioSda	=> sda,
		ioScl	=> scl);

----------------------------------------------------------------------------
	--! @brief 100MHz system clock generation
	CLK_STIM : sim_clk 	<= not sim_clk after C_CLK_PER/2 when not sim_stop;
----------------------------------------------------------------------------

	TB_PROC: process

		procedure ack is
		begin
			sda		<= '0';
			wait for C_CLK_PER*C_CLK_DIV;
			wait for 20 ns;
			sda		<= 'Z';
		end procedure ack;

	begin -- process TB_PROC

		phase	<= INIT;
		sim_rst <= '1';
		wait for 4*C_CLK_PER;
		sim_rst	<= '0';

		wait for 100*C_CLK_PER;

		phase	<= READ;
		wait for 9*C_CLK_PER*C_CLK_DIV;
		scl 	<= '0';
		wait for 10*C_CLK_PER*C_CLK_DIV;
		scl 	<= 'Z';
		ack;
		wait for 8*C_CLK_PER*C_CLK_DIV;
		ack;
		wait for 9*C_CLK_PER*C_CLK_DIV;
		ack;
		wait for 10*C_CLK_PER*C_CLK_DIV;
		phase	<= WRITE;
		wait for 9*C_CLK_PER*C_CLK_DIV;
		ack;
		wait for 8*C_CLK_PER*C_CLK_DIV;
		ack;
		wait for 8*C_CLK_PER*C_CLK_DIV;
		ack;
		wait for 4*C_CLK_PER*C_CLK_DIV;
		sim_stop 	<= TRUE;

		wait;
	end process TB_PROC;
----------------------------------------------------------------------------
end bench;
----------------------------------------------------------------------------
