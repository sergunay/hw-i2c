--! @file 			i2c_ctrl.vhd
--! @brief 			i2c ctrl module
--! @details
--! @author 		Selman Ergunay
--! @date 			2019-04-11
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.i2c_ctrl_pkg.all;
--------------------------------------------------------------------------------
entity i2c_ctrl is
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
end entity i2c_ctrl;
--------------------------------------------------------------------------------
architecture rtl of i2c_ctrl is

	constant C_TIMER_LIMIT	: integer := 10000;

	signal scl_out_en	: std_logic := '0';

	signal ack_out 		: std_logic := '0';
	signal err_code		: std_logic_vector(2 downto 0) := (others=>'0');

	signal data_rd_reg	: std_logic_vector(7 downto 0) := (others=>'0');
	signal data_rd_next	: std_logic_vector(7 downto 0) := (others=>'0');

	signal dev_addr		: std_logic_vector(6 downto 0) := (others=>'0');
	signal reg_addr		: std_logic_vector(7 downto 0) := (others=>'0');
	signal data_rd		: std_logic_vector(7 downto 0) := (others=>'0');
	signal data_wr		: std_logic_vector(7 downto 0) := (others=>'0');

	signal cmd			: std_logic_vector(23 downto 0) := (others=>'0');

	signal cmd_cnt 		: unsigned (3 downto 0) := (others=>'0');
	signal cmd_cnt_en	: std_logic := '0';

	signal timer_cnt 		: unsigned (31 downto 0) := (others=>'0');
	signal timer_en			: std_logic := '0';
	signal timer_rst		: std_logic := '0';
	signal timer_overflow 	: std_logic := '0';

	signal r_wn			: std_logic := '0';
	signal ack_in		: std_logic := '0';
	signal req			: std_logic := '0';

	signal err_detected	: std_logic := '0';

	type fsm_states is(
		ST_INIT,            -- Wait for device initialization
		ST_REQ,
		ST_READ,
		ST_READ_DONE,
		ST_WRITE,
		ST_DONE);

	signal state_next, state_reg 	: fsm_states := ST_INIT;
--------------------------------------------------------------------------------
begin

	ack_in		<= iAck;
	err_code 	<= iError;

	DATE_RD_REG_PROC:
	process(iClk)
	begin
		if rising_edge (iClk) then
			if iRst = '1' then
				data_rd_reg 	<= (others=>'0');
			else
				data_rd_reg 	<= data_rd_next;
			end if;
		end if;
	end process;

	TIMER_CNT_PROC:
	process(iClk)
	begin
		if rising_edge(iClk) then
			if iRst = '1' or timer_rst = '1' then
				timer_cnt	<= (others=>'0');
			elsif timer_en = '1' and timer_cnt < C_TIMER_LIMIT then
				timer_cnt <= timer_cnt + 1;
			end if;
		end if;
	end process;

	timer_overflow 	<= '1' when timer_cnt = C_TIMER_LIMIT-1 else
					   '0';

	CMD_CNT_PROC:
	process(iClk)
	begin
		if rising_edge(iClk) then
			if iRst = '1' then
				cmd_cnt	<= (others=>'0');
			elsif cmd_cnt_en = '1' and cmd_cnt < C_NB_CMD-1 then
				cmd_cnt <= cmd_cnt + 1;
			end if;
		end if;
	end process;

	err_detected 	<= '1' when err_code /= "000" else
					   '0';

--------------------------------------------------------------------------------

	FSM_STATE_REG : process(iClk)
	begin
		if rising_edge(iClk) then
			if iRst = '1' then
				state_reg 		<= ST_INIT;
			else
				state_reg 		<= state_next;
			end if;
		end if;
	end process FSM_STATE_REG;

	FSM_NSL: process(state_reg, cmd, r_wn, ack_in, iData, timer_overflow, cmd_cnt, data_rd_reg, err_detected)
	begin
		state_next 	<= state_reg;
		cmd 		<= I2C_CMD_LIST(to_integer(cmd_cnt));
		dev_addr 	<= cmd(23 downto 17);
		r_wn 		<= cmd(16);
		reg_addr	<= cmd(15 downto 8);
		data_wr		<= cmd(7 downto 0);
		req			<= '0';
		data_rd_next<= data_rd_reg;
		cmd_cnt_en	<= '0';
		timer_en	<= '0';
		timer_rst 	<= '0';

		case state_reg is

			when ST_INIT		=>

				-- wait for device initialization with counter.

				timer_en 	<= '1';

				if timer_overflow = '1' then
					state_next 	<= ST_REQ;
					timer_rst 	<= '1';
				end if;

			when ST_REQ		=>

				req	<= '1';

				if ack_in = '1' then	-- ack1 --> i2c_master started
					if r_wn = '1' then
						state_next 	<= ST_READ;
					else
						state_next 	<= ST_WRITE;
					end if;
				end if;

			when ST_READ		=>

				if ack_in = '1' then	-- ack2
					if err_detected = '0' then
						state_next 		<= ST_READ_DONE;
					else
						state_next 		<= ST_REQ;	-- request again the same
					end if;
				end if;

			when ST_READ_DONE	=>		-- ack3

				if ack_in = '1' then
					if err_detected = '0' then
						if cmd_cnt = C_NB_CMD-1 then
							state_next 	<= ST_DONE;
						else
							state_next 		<= ST_REQ;
							cmd_cnt_en 		<= '1';
							data_rd_next 	<= iData;
						end if;
					else
						state_next	<= ST_REQ;	-- request again the same
					end if;
				end if;

			when ST_WRITE	=>		-- ack2

				if ack_in = '1' then
					if err_detected = '0' then
						if cmd_cnt = C_NB_CMD-1 then
							state_next 	<= ST_DONE;
						else
							state_next	<= ST_REQ;
							cmd_cnt_en 	<= '1';
						end if;
					else
						state_next	<= ST_REQ;	-- request again the same
					end if;
				end if;

			when ST_DONE	=>

				state_next		<= state_reg;

		end case;

	end process FSM_NSL;

--------------------------------------------------------------------------------

	-- Output stage

	oDev_addr 	<= dev_addr;
	oReg_addr	<= reg_addr;
	oData		<= data_wr;
	oR_wn		<= r_wn;
	oReq		<= req;

--------------------------------------------------------------------------------
end architecture rtl;
--------------------------------------------------------------------------------

-- component i2c_ctrl
--   port(
-- 	iClk 		: in  std_logic;
-- 	iRst 		: in  std_logic;
-- 	oDev_addr	: out std_logic_vector(6 downto 0);
-- 	oReg_addr	: out std_logic_vector(7 downto 0);
-- 	oData		: out std_logic_vector(7 downto 0);
-- 	iData		: in  std_logic_vector(7 downto 0);
-- 	oReq 		: out std_logic;
-- 	oR_wn		: out std_logic;
-- 	iAck		: in  std_logic;
-- 	iError 		: out std_logic_vector(2 downto 0));
-- end component;
--
-- DUT: i2c_ctrl
--   port map(
-- 	iClk 		=> sim_clk,
-- 	iRst 		=> sim_rst,
-- 	oDev_addr	=> i2c_dev_addr,
-- 	oReg_addr	=> i2c_reg_addr,
-- 	oData		=> i2c_wr_data,
-- 	iData		=> sim_rd_data,
-- 	oReq 		=> i2c_req,
-- 	oR_wn		=> i2c_w_rn,
-- 	iAck		=> sim_ack,
-- 	iError 		=> sim_error);

