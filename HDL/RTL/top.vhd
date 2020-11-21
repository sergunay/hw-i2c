--! @file 			top.vhd
--! @brief 			top module
--! @details
--! @author 		Selman Ergunay
--! @date 			2019-04-11
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;
----------------------------------------------------------------------------
entity top is
	generic (
		CLK_DIV		: natural := 256);
	port (
		iClk 		: in  std_logic;
		iRst 		: in  std_logic;

		ioSda		: inout std_logic;
		ioScl		: inout std_logic
	);
end entity top;

----------------------------------------------------------------------------
architecture rtl of top is
----------------------------------------------------------------------------
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
		iError 		: in std_logic_vector(2 downto 0));
	end component;

	component i2c_master
    generic(
        CLK_DIV     : natural := 256);
    port(
        iClk        : in std_logic;
        iRst        : in std_logic;

        iReq        : in std_logic;
        iR_wn       : in std_logic;

        iDev_addr   : in std_logic_vector(6 downto 0);
        iReg_addr   : in std_logic_vector(7 downto 0);
        iData   	: in std_logic_vector(7 downto 0);
        oData   	: out std_logic_vector(7 downto 0);

        oAck       	: out std_logic;
        oError      : out std_logic_vector(2 downto 0);

		iSda_in		: in std_logic;
		iScl_in		: in std_logic;
		oSda_out	: out std_logic;
		oScl_out	: out std_logic);
	end component;

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

	signal clk        	: std_logic := '0';
	signal rst        	: std_logic := '0';
	signal req        	: std_logic := '0';
	signal r_wn       	: std_logic := '0';

	signal dev_addr   	: std_logic_vector(6 downto 0) := (others=>'0');
	signal reg_addr   	: std_logic_vector(7 downto 0) := (others=>'0');
	signal wr_data  	: std_logic_vector(7 downto 0) := (others=>'0');
	signal rd_data   	: std_logic_vector(7 downto 0) := (others=>'0');

	signal ack       	: std_logic := '1';
	signal err_code   	: std_logic_vector(2 downto 0) := (others=>'0');

	signal sda_in		: std_logic := '1';
	signal scl_in		: std_logic := '1';
	signal sda_out		: std_logic := '1';
	signal scl_out		: std_logic := '1';

----------------------------------------------------------------------------
begin -- architecture
----------------------------------------------------------------------------

	clk 	<= iClk;
	rst		<= iRst;

	I_I2C_CTRL: i2c_ctrl
	  port map(
		iClk 		=> clk,
		iRst 		=> rst,
		oDev_addr	=> dev_addr,
		oReg_addr	=> reg_addr,
		oData		=> wr_data,
		iData		=> rd_data,
		oReq 		=> req,
		oR_wn		=> r_wn,
		iAck		=> ack,
		iError 		=> err_code);

	I_I2C_MASTER: i2c_master
    generic map(
        CLK_DIV     => CLK_DIV)
    port map(
        iClk        => clk,
        iRst        => rst,
        iReq        => req,
        iR_wn       => r_wn,
        iDev_addr   => dev_addr,
        iReg_addr   => reg_addr,
        iData   	=> wr_data,
        oData   	=> rd_data,
        oAck       	=> ack,
        oError      => err_code,
		iSda_in		=> sda_in,
		iScl_in		=> scl_in,
		oSda_out	=> sda_out,
		oScl_out	=> scl_out);

	I_I2C_PHY: i2c_phy
	port map(
		iClk 		=> clk,
		iRst 		=> rst,
		iSda_out	=> sda_out,
		iScl_out	=> scl_out,
		oSda_in 	=> sda_in,
		oScl_in		=> scl_in,
		ioSda		=> ioSda,
		ioScl		=> ioScl);


----------------------------------------------------------------------------
end rtl;
----------------------------------------------------------------------------


-- component top
-- port (
-- 	iClk 	: in  std_logic;
-- 	iRst 	: in  std_logic;
--
-- 	ioSda	: inout std_logic;
-- 	ioScl	: inout std_logic);
-- end component;

-- DUT: top
-- port map(
-- 	iClk 	=> sim_clk,
-- 	iRst 	=> sim_rst,
--
-- 	ioSda	=> sda,
-- 	ioScl	=> scl);

