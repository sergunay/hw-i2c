--! @file 			i2c_master.vhd
--! @brief 			i2c master module
--! @details
--! @author 		Selman Ergunay
--! @date 			2019-04-11
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--------------------------------------------------------------------------------
entity i2c_master is
	generic(
		CLK_DIV		: natural := 256);
	port(
		iClk 		: in std_logic;
		iRst 		: in std_logic;

		iReq 		: in std_logic;
		iR_wn		: in std_logic;

		iDev_addr	: in std_logic_vector(6 downto 0);
		iReg_addr	: in std_logic_vector(7 downto 0);
		iData		: in std_logic_vector(7 downto 0);
		oData		: out std_logic_vector(7 downto 0);

		oAck		: out std_logic;
		oError 		: out std_logic_vector(2 downto 0);

		iSda_in		: in std_logic;
		iScl_in		: in std_logic;
		oSda_out	: out std_logic;
		oScl_out	: out std_logic);
end entity i2c_master;
--------------------------------------------------------------------------------
architecture rtl of i2c_master is

	constant C_MAX		: natural := CLK_DIV;
	constant C_MID		: natural := CLK_DIV/2;
	constant C_RISE		: natural := CLK_DIV/4;
	constant C_FALL		: natural := 3*CLK_DIV/4;

	signal clk_cnt 		: unsigned(9 downto 0)	:= (others=>'0');
	signal clk_rst		: std_logic := '1';

	signal sda_tick 	: std_logic := '0';

	signal scl_clk		: std_logic := '1';
	signal scl_mid   	: std_logic := '1';
	signal scl_out_en	: std_logic := '0';

	signal ack_out 		: std_logic := '0';
	signal err_code		: std_logic_vector(2 downto 0) := (others=>'0');
	signal data_out		: std_logic_vector(7 downto 0) := (others=>'0');

	signal reg_addr_reg	: std_logic_vector(7 downto 0) := (others=>'0');
	signal data_rd_next	: std_logic_vector(7 downto 0) := (others=>'0');
	signal data_rd_reg	: std_logic_vector(7 downto 0) := (others=>'0');
	signal data_wr_reg	: std_logic_vector(7 downto 0) := (others=>'0');

	signal dev_addr_reg	: std_logic_vector(6 downto 0) := (others=>'0');
	signal dev_addr_wr	: std_logic_vector(7 downto 0) := (others=>'0');
	signal dev_addr_rd	: std_logic_vector(7 downto 0) := (others=>'0');

	signal ack_received_set		: std_logic := '0';
	signal ack_received_clear	: std_logic := '0';
	signal ack_received_flag	: std_logic := '0';

	signal op			: std_logic := '0';
	signal req_in		: std_logic := '0';

	signal bit_cnt_next	: integer range 0 to 7 := 7;
	signal bit_cnt_reg	: integer range 0 to 7 := 7;

	signal sda_in 		: std_logic := '1';
	signal sda_out 		: std_logic := '1';

	signal scl_in 		: std_logic := '1';
	signal scl_out 		: std_logic := '1';
	signal scl_out_d 	: std_logic := '1';

	type fsm_states is(
		ST_READY,
		ST_START,
		ST_RSTART_1,
		ST_RSTART_2,
		ST_DEV_ADDR,
		ST_RDEV_ADDR,
	   	ST_REG_ADDR,
		ST_WR_DATA,
		ST_RD_DATA,
		ST_ACK,
		ST_NACK,
		ST_WAIT_1,
		ST_WAIT_2,
		ST_WAIT_3,
		ST_WAIT_4,
		ST_ERROR_1,
		ST_ERROR_2,
		ST_ERROR_3,
		ST_ERROR_4,
		ST_STOP_1,
		ST_STOP_2);

	signal state_next, state_reg 	: fsm_states := ST_READY;

--------------------------------------------------------------------------------
begin
--------------------------------------------------------------------------------

	-- addr and data in regs

	req_in 	<= iReq;

	IN_REG_PROC: process (iClk)
	begin
		if rising_edge (iClk) then
			if iRst = '1' then
				dev_addr_reg 	<= (others=>'0');
				reg_addr_reg 	<= (others=>'0');
				data_wr_reg		<= (others=>'0');
				op				<= '0';
			elsif req_in = '1' and state_reg = ST_READY then
				dev_addr_reg 	<= iDev_addr;
				reg_addr_reg 	<= iReg_addr;
				data_wr_reg		<= iData;
				op				<= iR_wn;	-- 1: Read, 0: Write
			end if;
		end if;
	end process IN_REG_PROC;

	dev_addr_wr <= dev_addr_reg & '0';
	dev_addr_rd <= dev_addr_reg & '1';

	sda_in 	<= iSda_in;
	scl_in 	<= iScl_in;


--------------------------------------------------------------------------------

	-- internal signals related sda and scl, determined by clock counter

	CLK_CNT_PROC: process(iClk)
	begin
		if rising_edge(iClk) then
			if iRst = '1' or clk_cnt = C_MAX-1 or clk_rst = '1' then
				clk_cnt	<= (others=>'0');
			else
				clk_cnt <= clk_cnt + 1;
			end if;
		end if;
	end process CLK_CNT_PROC;

	sda_tick 	<=  '1' when clk_cnt = C_MAX-1 else
					'0';

	scl_clk		<=  '1'	when clk_cnt >= C_RISE and clk_cnt < C_FALL  else
					'0';

	scl_mid     <=  '1' when clk_cnt = C_MID else
					'0';

--------------------------------------------------------------------------------

	BIT_CNT_REG_PROC: process(iClk)
	begin
		if rising_edge (iClk) then
			if iRst = '1' then
				bit_cnt_reg <=  7;
			else
				bit_cnt_reg <=  bit_cnt_next;
			end if;
		end if;
	end process BIT_CNT_REG_PROC;

--------------------------------------------------------------------------------

	DATA_RD_REG_PROC: process(iClk)
	begin
		if rising_edge (iClk) then
			if iRst = '1' then
				data_rd_reg 	<=  (others=>'0');
			else
				data_rd_reg		<=  data_rd_next;
			end if;
		end if;
	end process;

--------------------------------------------------------------------------------

	ACK_FLAG_PROC: process(iClk)
	begin
		if rising_edge (iClk) then
			if iRst = '1' or ack_received_clear = '1' then
				ack_received_flag <= '0';
			elsif ack_received_set = '1' then
				ack_received_flag <= '1';
			end if;
		end if;
	end process ACK_FLAG_PROC;

--------------------------------------------------------------------------------

	FSM_STATE_REG : process(iClk)
	begin
		if rising_edge(iClk) then
			if iRst = '1' then
				state_reg 		<= ST_READY;
			else
				state_reg 		<= state_next;
			end if;
		end if;
	end process FSM_STATE_REG;

	FSM_NSL: process(state_reg, clk_cnt, sda_tick, data_wr_reg, bit_cnt_reg, ack_received_flag, sda_in, scl_in,
		scl_mid, req_in, dev_addr_wr, reg_addr_reg, op, dev_addr_rd, data_rd_reg)
	begin
		state_next 			<= state_reg;
		scl_out_en			<= '1';
		sda_out				<= '1';
		bit_cnt_next		<=  bit_cnt_reg;
		ack_out				<= '0';
		data_out			<= (others=>'0');
		err_code			<= "000";
		ack_received_set	<= '0';
		ack_received_clear	<= '0';
		clk_rst				<= '0';
		data_rd_next 		<= data_rd_reg;

		case state_reg is

			when ST_READY		=>

				scl_out_en	<= '0';
				clk_rst		<= '1';
				if req_in = '1' then
					state_next 	<= ST_START;
				end if;

			when ST_START		=>

				scl_out_en	<= '0';
				sda_out		<= '0';

				if sda_tick = '1' then
					ack_out		<= '1';		-- ack1 : started
					state_next 	<= ST_DEV_ADDR;
				end if;

			---------------------------------------------------

			when ST_DEV_ADDR	=>

				sda_out			<= dev_addr_wr(bit_cnt_reg);

				if sda_tick = '1' then
					if bit_cnt_reg = 0 then
						state_next		<= ST_WAIT_1;
					else
						bit_cnt_next	<= bit_cnt_reg - 1;
					end if;
				end if;

			when ST_WAIT_1		=>

				bit_cnt_next	<=  7;

				if scl_mid = '1' and  sda_in = '0' then
					ack_received_set	<= '1';
				end if;

				if sda_tick = '1' then
					if ack_received_flag = '1' then
						ack_received_clear 	<= '1';
						state_next 			<= ST_REG_ADDR;
					else
						state_next 	<= ST_ERROR_1;
					end if;
				end if;

			when ST_ERROR_1		=>

				if sda_tick = '1' then
					ack_out 	<= '1';		-- ack2
					err_code	<= "001";
					state_next 	<= ST_STOP_1;
				end if;

			---------------------------------------------------

			when ST_REG_ADDR	=>

				sda_out		<= reg_addr_reg(bit_cnt_reg);

				if sda_tick = '1' then
					if bit_cnt_reg = 0 then
						state_next		<= ST_WAIT_2;
					else
						bit_cnt_next	<= bit_cnt_reg - 1;
					end if;
				end if;

			when ST_WAIT_2		=>		-- Worst case delay = 400 us. 400 k = 2.5 us => 160

				bit_cnt_next	<=  7;

				if sda_in = '0' and  scl_mid = '1' then
					ack_received_set	<= '1';
				end if;

				-- if scl_in = 0, keep waiting
				if sda_tick = '1' then
					if ack_received_flag = '1' then
						ack_received_clear 	<= '1';
						if op = '0' then
							state_next 	<= ST_WR_DATA;
						else
							state_next 	<= ST_RSTART_1;
						end if;
					else
						state_next 	<= ST_ERROR_2;
					end if;
				end if;

			when ST_ERROR_2		=>

				if sda_tick = '1' then
					ack_out 	<= '1';
					err_code	<= "010";
					state_next 	<= ST_STOP_1;
				end if;

			---------------------------------------------------

			when ST_WR_DATA		=>

				sda_out			<= data_wr_reg(bit_cnt_reg);

				if sda_tick = '1' then
					if bit_cnt_reg = 0 then
						state_next		<= ST_WAIT_3;
					else
						bit_cnt_next	<= bit_cnt_reg - 1;
					end if;
				end if;

			when ST_WAIT_3		=>

				bit_cnt_next	<=  7;

				if scl_mid = '1' and sda_in = '0' then
					ack_received_set	<= '1';
				end if;

				if sda_tick = '1' then
					if ack_received_flag = '1' then
						ack_received_clear 	<= '1';
						ack_out <= '1';

						if req_in = '1' then
							state_next 	<= ST_WR_DATA;
						else
							state_next 	<= ST_STOP_1;
						end if;
					else
						state_next 	<= ST_ERROR_3;
					end if;
				end if;

			when ST_ERROR_3		=>


				if sda_tick = '1' then
					ack_out 	<= '1';
					err_code	<= "011";
					state_next 	<= ST_STOP_1;
				end if;

			---------------------------------------------------

			when ST_RSTART_1	=>

				scl_out_en	<= '0';
				sda_out		<= '1';

				if sda_tick = '1' then
					state_next 	<= ST_RSTART_2;
				end if;

			when ST_RSTART_2	=>

				scl_out_en	<= '0';
				sda_out		<= '0';

				if sda_tick = '1' and scl_in = '1' then
					state_next <= ST_RDEV_ADDR;
				end if;

			when ST_RDEV_ADDR	=>

				sda_out		<= dev_addr_rd(bit_cnt_reg);

				if sda_tick = '1' then
					if bit_cnt_reg = 0 then
						state_next		<= ST_WAIT_4;
					else
						bit_cnt_next	<= bit_cnt_reg - 1;
					end if;
				end if;

			when ST_WAIT_4		=>

				bit_cnt_next	<=  7;

				if scl_mid = '1' and sda_in = '0' then
					ack_received_set	<= '1';
				end if;

				if sda_tick = '1' then
					if ack_received_flag = '1' then
						ack_received_clear 	<= '1';
						state_next 	<= ST_RD_DATA;
					else
						state_next 	<= ST_ERROR_4;
					end if;
				end if;

			when ST_ERROR_4		=>

				if sda_tick = '1' then
					ack_out 	<= '1';
					err_code	<= "100";
					state_next 	<= ST_STOP_1;
				end if;

			---------------------------------------------------

			when ST_RD_DATA		=>

				if scl_mid = '1' then
					data_rd_next(bit_cnt_reg)	<= sda_in;
				end if;

				if sda_tick = '1' then
					if bit_cnt_reg = 0 then

						bit_cnt_next	<=  7;

						data_out	<= data_rd_reg;
						ack_out 	<=  '1';	-- data valid

						if req_in = '1' then
							state_next 	<= ST_ACK;
						else
							state_next 	<= ST_NACK;
						end if;
					else
						bit_cnt_next	<= bit_cnt_reg - 1;
					end if;
				end if;

			when ST_ACK			=>

				sda_out		<= '0';
				if sda_tick = '1' then
					state_next 	<= ST_RD_DATA;
				end if;

			when ST_NACK		=>	-- Read done

				if sda_tick = '1' then
					state_next <= ST_STOP_1;
				end if;

			---------------------------------------------------

			when ST_STOP_1		=>

				sda_out 		<= '0';

				if sda_tick = '1' then
					state_next 	<= ST_STOP_2;
				end if;

			when ST_STOP_2		=>

				scl_out_en 		<= '0';

				if sda_tick = '1' then
					state_next 	<= ST_READY;
				end if;

		end case;

	end process FSM_NSL;

--------------------------------------------------------------------------------

	-- Output stage

	scl_out 	<= '0' when scl_out_en = '1' and scl_clk = '0' else
				   '1';

	oAck 		<= ack_out;
	oError		<= err_code;
	oData 		<= data_out;

	SDA_OUT_PROC:
	process(iClk)
	begin
		if rising_edge (iClk) then
			if iRst = '1' then
				oSda_out	<= '1';
			else
				oSda_out	<= sda_out;
			end if;
		end if;
	end process;

	oScl_out	<= scl_out;


	process (iClk)
	begin
		if rising_edge (iClk) then
			if iRst = '1' then
				scl_out_d <= '0';
			else
				scl_out_d <= scl_out;
			end if;
		end if;
	end process;

--------------------------------------------------------------------------------
end architecture rtl;
--------------------------------------------------------------------------------
