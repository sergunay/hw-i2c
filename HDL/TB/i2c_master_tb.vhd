--! @file           i2c_master_tb
--! @brief          Testbench for i2c_master module
--! @author         Selman Ergunay
--! @date           2019-04-11
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
------------------------------------------------------------------------------------------
entity i2c_master_tb is
end entity i2c_master_tb;
------------------------------------------------------------------------------------------
architecture bench of i2c_master_tb is
------------------------------------------------------------------------------------------

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

	constant C_CLK_PER 	: time 		:= 10 ns;
	constant C_CLK_DIV	: natural 	:= 256;

	signal sim_clk 		: std_logic := '0';
	signal sim_rst	 	: std_logic := '0';
	signal sim_stop		: boolean 	:= FALSE;				-- stop simulation?
	signal sim_req		: std_logic := '0';
	signal sim_dev_addr	: std_logic_vector(6 downto 0) := (others=>'0');
	signal sim_reg_addr	: std_logic_vector(7 downto 0) := (others=>'0');
	signal sim_r_wn		: std_logic := '0';
	signal sim_data		: std_logic_vector(7 downto 0) := (others=>'0');
	signal sim_sda		: std_logic := '0';
	signal sim_scl 		: std_logic := '0';
	signal scl_line		: std_logic := '0';
	signal sda_line		: std_logic := '0';

	signal sim_ack		: std_logic := '0';

	signal i2c_ack		: std_logic := '0';
	signal i2c_data 	: std_logic_vector(7 downto 0) := (others=>'0');
	signal i2c_error	: std_logic_vector(2 downto 0) := (others=>'0');
	signal i2c_sda		: std_logic := '1';
	signal i2c_scl	: std_logic := '1';

	signal i2c_start	: std_logic := '0';
	signal i2c_stop		: std_logic := '0';



	signal bit_cnt 			: integer := 0;
	signal byte_cnt 		: integer := 0;
	signal byte_receiving 	: std_logic := '0';

	signal i2c_listen_data 	: std_logic_vector(7 downto 0) := (others=>'0');

	type verif_phase is (
		INIT,
		WRITE_SUCCESS,
		WRITE_ERROR_1,
		WRITE_ERROR_2,
		WRITE_ERROR_3,
		READ_SUCCESS);
	signal phase 		: verif_phase;

----------------------------------------------------------------------------
begin
----------------------------------------------------------------------------

	DUT: i2c_master
    generic map(
        CLK_DIV		=> C_CLK_DIV)
    port map(
        iClk        => sim_clk,
        iRst        => sim_rst,
        iReq        => sim_req,
        iR_wn       => sim_r_wn,
        iDev_addr   => sim_dev_addr,
        iReg_addr   => sim_reg_addr,
        iData   	=> sim_data,
        oData   	=> i2c_data,
        oAck       	=> i2c_ack,
        oError      => i2c_error,
		iSda_in     => sda_line,
		iScl_in     => scl_line,
		oSda_out	=> i2c_sda,
		oScl_out	=> i2c_scl);

----------------------------------------------------------------------------
	--! @brief 100MHz system clock generation
	CLK_STIM : sim_clk 	<= not sim_clk after C_CLK_PER/2 when not sim_stop;
----------------------------------------------------------------------------

	I2C_LISTEN_PROC: process(i2c_scl, i2c_sda, sim_clk, sim_ack, scl_line)
	begin
		i2c_start 	<=  '0';
		i2c_stop 	<=  '0';

		if phase /= INIT then

			if falling_edge(i2c_sda) and i2c_scl = '1' then
				i2c_start <=  '1';
				report "Start is detected";
			end if;

			if rising_edge(i2c_sda) and i2c_scl = '1' then
				i2c_stop	<=  '1';
				report "Stop is detected";
			end if;

			if rising_edge(sim_ack) then
				report "Data = 0x" & to_hstring(i2c_listen_data);
			end if;

			if i2c_start = '1' or falling_edge(sim_ack) then
				byte_receiving 	<= '1';
			elsif falling_edge(i2c_scl) and bit_cnt = 0 then
				byte_receiving 	<= '0';
			end if;

			if i2c_start = '1' then
				bit_cnt 		<= 7;
			elsif sim_ack = '1' then
				bit_cnt <= 7;
			elsif rising_edge(i2c_scl) and byte_receiving = '1' then
				i2c_listen_data(bit_cnt) 	<= i2c_sda;
			elsif falling_edge(scl_line) then
				if bit_cnt /= 0 then
					bit_cnt <= bit_cnt - 1;
				else
					byte_receiving 	<= '0';
				end if;
			end if;

		end if;
	end process I2C_LISTEN_PROC;

	ERROR_LISTEN_PROC: process(i2c_error, i2c_ack)
	begin
		if rising_edge(i2c_ack) then
			report "Ack detected, error code = 0x" & to_bstring(i2c_error);
		end if;
	end process ERROR_LISTEN_PROC;

----------------------------------------------------------------------------

	scl_line 	<= '0' when sim_scl = '0' else
				   i2c_scl;

	sda_line 	<= '0' when sim_sda = '0' else
				   i2c_sda;

	TB_PROC: process
		-- Initialization procedure
		procedure init is
		begin
			sim_rst <= '1';
			wait for 4*C_CLK_PER;
			sim_rst		<= '0';
			sim_sda	<= '1';
		end procedure init;

		procedure ack is
		begin
			sim_ack 	<= '1';
			sim_sda 	<= '0';
			wait for C_CLK_PER*C_CLK_DIV;
			wait for 20 ns;
			sim_ack 	<= '0';
			sim_sda 	<= '1';
		end procedure ack;

		procedure i2c_write(
			constant dev_addr 	: std_logic_vector(7 downto 0);
			constant reg_addr	: std_logic_vector(7 downto 0);
			constant data		: std_logic_vector(7 downto 0);
			constant err_type	: integer) is
		begin
			sim_dev_addr 	<= dev_addr(6 downto 0);
			sim_reg_addr 	<= reg_addr(7 downto 0);
			sim_data		<= data(7 downto 0);
			sim_req			<= '1';
			sim_r_wn		<= '0';
			sim_sda 		<= '1';
			sim_scl 		<= '1';

			wait until falling_edge(i2c_ack);

			sim_dev_addr 	<= (others=>'0');
			sim_reg_addr	<= (others=>'0');
			sim_data		<= (others=>'0');
			sim_req			<= '0';

			wait until bit_cnt = 0;
			wait until falling_edge(i2c_scl);
			wait until i2c_sda = '1';
			if err_type = 1 then
				wait for 2*C_CLK_DIV*C_CLK_PER;
				return;
			else
				ack;
			end if;
			--sim_scl 	<= '0';
			--wait for 3*C_CLK_DIV*C_CLK_PER;
			--sim_scl 	<= '1';

			wait until bit_cnt = 0;
			wait until falling_edge(i2c_scl);
			wait until i2c_sda = '1';
			if err_type = 2 then
				wait for 5*C_CLK_DIV*C_CLK_PER;
				return;
			else
--				sim_scl 	<= '0';
--				wait for 10*C_CLK_DIV*C_CLK_PER;
--				sim_scl 	<= '1';
				ack;
			end if;
			wait for 1*C_CLK_DIV*C_CLK_PER;

			wait until bit_cnt = 0;
			wait until falling_edge(i2c_scl);
			if i2c_sda /= '1' then
				wait until i2c_sda = '1';
			end if;
			wait for C_CLK_DIV*C_CLK_PER/4;
			if err_type = 3 then
				wait for 2*C_CLK_DIV*C_CLK_PER;
				return;
			else
				ack;
			end if;
		end procedure i2c_write;


		procedure i2c_read(
			constant dev_addr 	: std_logic_vector(7 downto 0);
			constant reg_addr	: std_logic_vector(7 downto 0);
			constant rd_data	: std_logic_vector(7 downto 0)) is
		begin
			sim_dev_addr 	<= dev_addr(6 downto 0);
			sim_reg_addr 	<= reg_addr(7 downto 0);
			sim_req			<= '1';
			sim_r_wn		<= '1';
			sim_sda 		<= '1';

			wait until rising_edge(i2c_ack);

			sim_dev_addr 	<= (others=>'0');
			sim_reg_addr	<= (others=>'0');
			sim_data		<= (others=>'0');
			sim_req			<= '0';

			wait until bit_cnt = 0;
			wait until falling_edge(i2c_scl);
			wait until i2c_sda = '1';
			ack;

			wait until bit_cnt = 0;
			wait until rising_edge(i2c_scl);
			wait until i2c_sda = '1';
			ack;

			wait until bit_cnt = 0;
			wait until rising_edge(i2c_scl);
			wait until i2c_sda = '1';
			wait for 1*C_CLK_DIV*C_CLK_PER;
			ack;

			for bitcnt in 7 downto 0 loop
				sim_sda 	<= rd_data(bitcnt);
				wait until falling_edge(i2c_scl);
			end loop;
			sim_sda	<= '1';

		end procedure i2c_read;

	begin -- process TB_PROC

		phase <= INIT;
		init;

		wait for C_CLK_DIV*C_CLK_PER/2;

		phase <= WRITE_SUCCESS;
		report "---------- Test phase: write success ----------";
		report "Dev addr = 0x1A, Reg addr = 0x14, Data = 0x23";
		i2c_write(x"1A", x"14", x"23", 0);

		wait for 8*C_CLK_DIV*C_CLK_PER;

		phase <= WRITE_ERROR_1;
		report "---------- Test phase: write error#1 ----------";
		report "Dev addr = 0x1A, Reg addr = 0x14, Data = 0x23";
		i2c_write(x"1A", x"14", x"23", 1);

		wait for 8*C_CLK_DIV*C_CLK_PER;

		phase <= WRITE_ERROR_2;
		report "---------- Test phase: write error#2 ----------";
		report "Dev addr = 0x1A, Reg addr = 0x14, Data = 0x23";
		i2c_write(x"1A", x"14", x"23", 2);

		wait for 8*C_CLK_DIV*C_CLK_PER;
		wait until falling_edge(sim_clk);

		phase <= READ_SUCCESS;
		report "---------- Test phase: read success --------------";
		report "Dev addr = 0x1A, Reg addr = 0x14, Data = 0x23";
		i2c_read(x"1A", x"14", x"BA");

		wait for 8*C_CLK_DIV*C_CLK_PER;

		sim_stop 	<= TRUE;

		wait;
	end process TB_PROC;
----------------------------------------------------------------------------
end bench;
----------------------------------------------------------------------------
