--! @file 			i2c_phy.vhd
--! @brief 			i2c phy module
--! @details
--! @author 		Selman Ergunay
--! @date 			2019-04-11
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--------------------------------------------------------------------------------
entity i2c_phy is
	port(
		iClk 		: in std_logic;
		iRst 		: in std_logic;

		iSda_out	: in std_logic;
		iScl_out	: in std_logic;

		oSda_in 	: out std_logic;
		oScl_in		: out std_logic;

		ioSda		: inout std_logic;
		ioScl		: inout std_logic);
end entity i2c_phy;
--------------------------------------------------------------------------------
architecture rtl of i2c_phy is

	signal sda_in 	: std_logic := '1';
	signal sda_in_d	: std_logic := '1';

	signal scl_in 	: std_logic := '1';
	signal scl_in_d	: std_logic := '1';

--------------------------------------------------------------------------------
begin -- architecture
--------------------------------------------------------------------------------

	-- Input regs - stage 1

	SDA_IN_PROC: process (iClk)
	begin
		if rising_edge (iClk) then
			if ioSda = '0' then
				sda_in <= '0';
			else
				sda_in <= '1';
			end if;
		end if;
	end process;

	SCL_IN_PROC: process (iClk)
	begin
		if rising_edge (iClk) then
			if ioScl = '0' then
				scl_in <= '0';
			else
				scl_in <= '1';
			end if;
		end if;
	end process;

--------------------------------------------------------------------------------

	-- Input regs - stage 2

	SDA_IN_REG_PROC: process (iClk)
	begin
		if rising_edge (iClk) then
			if iRst = '1' then
				sda_in_d <= '1';
			else
				sda_in_d <= sda_in;
			end if;
		end if;
	end process;

	SCL_IN_REG_PROC: process (iClk)
	begin
		if rising_edge (iClk) then
			if iRst = '1' then
				scl_in_d <= '1';
			else
				scl_in_d <= scl_in;
			end if;
		end if;
	end process;

--------------------------------------------------------------------------------

	-- PHY OUT:

	SCL_OUT_PROC: process (iClk)
	begin
		if rising_edge (iClk) then
			if iScl_out = '0' then
				ioScl <= '0';
			else
				ioScl <= 'Z';
			end if;
		end if;
	end process;

	SDA_OUT_PROC: process (iClk)
	begin
		if rising_edge (iClk) then
			if iSda_out = '0' then
				ioSda <= '0';
			else
				ioSda <= 'Z';
			end if;
		end if;
	end process;

--------------------------------------------------------------------------------

	-- i2c_master controller out

	oSda_in 	<= sda_in_d;
	oScl_in 	<= scl_in_d;

--------------------------------------------------------------------------------
end architecture rtl;
--------------------------------------------------------------------------------


-- component i2c_phy
-- 	port(
-- 		iClk 		: in std_logic;
-- 		iRst 		: in std_logic;
--
-- 		iSda_out	: in std_logic;
-- 		iScl_out	: in std_logic;
--
-- 		oSda_in 	: out std_logic;
-- 		oScl_in		: out std_logic;
--
-- 		ioSda		: inout std_logic;
-- 		ioScl		: inout std_logic);
-- end component;


-- DUT: i2c_phy
-- 	port map(
-- 		iClk 		=> iClk,
-- 		iRst 		=> iRst,
-- 		iSda_out	=> iSda_out,
-- 		iScl_out	=> iScl_out,
-- 		oSda_in 	=> oSda_in,
-- 		oScl_in		=> oScl_in,
-- 		ioSda		=> ioSda,
-- 		ioScl		=> ioScl);
