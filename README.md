I2C master	: Hardware design of I2C master controller  
Release		: 0.0 
Date		: 2020-11-21  

General Description
--------------------------------------------------------------------------

* The list of I2C commands to be executed is stored in 
    HDL/RTL/i2c_ctrl_pkg.vhd
  with the format of:
    DEV_ADDR(8-bit) & REG_ADDR(8-bit) & DATA(8-bit)
  It is adapted according to application.

* Setting the I2C speed:
  - INFO: Clock input on the board is 12 MHz.
  - In build.tcl script, change the CLK_DIV value:
    set_property generic {CLK_DIV=30} [current_fileset]
      - 12MHz clk in freq and CLK_DIV=30 set the clk freq. to 400kHz.
      - 12MHz clk in freq and CLK_DIV=120 set the clk freq. to 100kHz.
* Block diagram: 
  - DOC/top_bd.pdf

* State transition diagram of the FSM design: 
  - DOC/i2c_master_fsm.pdf
  ![I2C Master FSM](/DOC/i2c_master_fsm.png)

Hardware
--------------------------------------------------------------------------

* Design implementation: Cmod A7 - Artix-7 FPGA Module 

* Verification: Arduino Mega 2560

Simulation
--------------------------------------------------------------------------

RTL simulation:

* Design files i2c_ctrl, i2c_master and i2c_phy can be simulated individually,
  or together with top_tb.

* Open `MSIM/I2C_CTRL.mpf`.

  - For the unit test of i2c_phy, open I2C_PHY simulation configuration.
    run -all

  - For the unit test of i2c_master, open I2C_MASTER simulation configuration.
    run -all

      In this testbench, different scenarios is tested. The expected output:
 
       # ** Note: Start is detected
       #    Time: 5155 ns  Iteration: 4  Instance: /i2c_master_tb
       # ** Note: Data = 0x34
       #    Time: 28195 ns  Iteration: 4  Instance: /i2c_master_tb
       # ** Note: Data = 0x14
       #    Time: 76835 ns  Iteration: 1  Instance: /i2c_master_tb
       # ** Note: Data = 0x23
       #    Time: 100515 ns  Iteration: 1  Instance: /i2c_master_tb
       # ** Note: Stop is detected
       #    Time: 103085 ns  Iteration: 4  Instance: /i2c_master_tb
       # ** Note: Start is detected
       #    Time: 122915 ns  Iteration: 4  Instance: /i2c_master_tb
       # ** Note: ERROR = 0x001
       #    Time: 148515 ns  Iteration: 3  Instance: /i2c_master_tb
       # ** Note: Start is detected
       #    Time: 174115 ns  Iteration: 4  Instance: /i2c_master_tb
       # ** Note: Data = 0x34
       #    Time: 197155 ns  Iteration: 4  Instance: /i2c_master_tb
       # ** Note: ERROR = 0x010
       #    Time: 494115 ns  Iteration: 3  Instance: /i2c_master_tb

  - For the unit test of i2c_ctrl, open I2C_CTRL simulation configuration.
    run -all

  - For the unit test of top, open TOP simulation configuration.
    run -all

  - For the test of top with an EEPROM model, open TOP_EEPROM simulation configuration.
    run -all

* GHDL sim:
  - In GHDL dir:
    - make

Synthesis
--------------------------------------------------------------------------

* Vivado in TCL mode:

  - Go to VIVADO/WORK directory.
  - cmd
  - vivado -mode tcl
  - source ../TCL/build.tcl

* Resource utilization:

  +-------------------------+------+-------+-----------+-------+
  |        Site Type        | Used | Fixed | Available | Util% |
  +-------------------------+------+-------+-----------+-------+
  | Slice LUTs              |   55 |     0 |     20800 |  0.26 |
  |   LUT as Logic          |   55 |     0 |     20800 |  0.26 |
  |   LUT as Memory         |    0 |     0 |      9600 |  0.00 |
  | Slice Registers         |   70 |     0 |     41600 |  0.17 |
  |   Register as Flip Flop |   70 |     0 |     41600 |  0.17 |
  |   Register as Latch     |    0 |     0 |     41600 |  0.00 |
  | F7 Muxes                |    0 |     0 |     16300 |  0.00 |
  | F8 Muxes                |    0 |     0 |      8150 |  0.00 |
  +-------------------------+------+-------+-----------+-------+
  
* Timing:
  
  Clock        Waveform(ns)       Period(ns)      Frequency(MHz)
  -----        ------------       ----------      --------------
  sys_clk_pin  {0.000 41.660}     83.330          12.000          
  
  
  Slack (MET) :             79.075ns  (required time - arrival time)

Programming the FPGA
--------------------------------------------------------------------------

* Vivado in TCL mode:

  - Go to VIVADO/WORK directory.
  - cmd
  - vivado -mode tcl
  - source ../TCL/program.tcl

Verification
--------------------------------------------------------------------------

* FPGA - ARDUINO

  - FPGA is programmed as I2C master and connected to Arduino running a slave 
    receiver using wire library.
  
  - Connections: 
      Arduino	      CMOD_A7
      -------         -------
        20            48       SDA
        21            47       SCL 
        GND           GND
  
  - Run arduino slave receiver code in:
    ARDUINO/slave_receiver/slave_receiver.ino
  
  - Program the FPGA:
    In VIVADO/WORK, run ../TCL/program.tcl
  
  - See the data being showed in serial monitor in Arduino software.

  - Program the FPGA:
    In VIVADO/WORK, run ../TCL/program.tcl
