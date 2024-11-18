-- Copyright (C) 2020  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and any partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details, at
-- https://fpgasoftware.intel.com/eula.

-- *****************************************************************************
-- This file contains a Vhdl test bench with test vectors .The test vectors     
-- are exported from a vector file in the Quartus Waveform Editor and apply to  
-- the top level entity of the current Quartus project .The user can use this   
-- testbench to simulate his design using a third-party simulation tool .       
-- *****************************************************************************
-- Generated on "11/07/2024 18:42:29"
                                                             
-- Vhdl Test Bench(with test vectors) for design  :          SCOMP_System
-- 
-- Simulation tool : 3rd Party
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY SCOMP_System_vhd_vec_tst IS
END SCOMP_System_vhd_vec_tst;
ARCHITECTURE SCOMP_System_arch OF SCOMP_System_vhd_vec_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL clock_50 : STD_LOGIC;
SIGNAL dbg_AC : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL dbg_PC : STD_LOGIC_VECTOR(10 DOWNTO 0);
SIGNAL KEY0 : STD_LOGIC;
SIGNAL TPs : STD_LOGIC_VECTOR(3 DOWNTO 0);
COMPONENT SCOMP_System
	PORT (
	clock_50 : IN STD_LOGIC;
	dbg_AC : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
	dbg_PC : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
	KEY0 : IN STD_LOGIC;
	TPs : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END COMPONENT;
BEGIN
	i1 : SCOMP_System
	PORT MAP (
-- list connections between master ports and signals
	clock_50 => clock_50,
	dbg_AC => dbg_AC,
	dbg_PC => dbg_PC,
	KEY0 => KEY0,
	TPs => TPs
	);

-- KEY0
t_prcs_KEY0: PROCESS
BEGIN
	KEY0 <= '0';
	WAIT FOR 20000 ps;
	KEY0 <= '1';
	WAIT FOR 979000 ps;
	KEY0 <= '0';
WAIT;
END PROCESS t_prcs_KEY0;
END SCOMP_System_arch;
