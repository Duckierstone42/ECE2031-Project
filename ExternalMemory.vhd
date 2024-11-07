-- ExternalMemory.VHD
-- 2024.10.22
--
-- This SCOMP peripheral provides one 16-bit word of external memory for SCOMP.
-- Any value written to this peripheral can be read back.

LIBRARY IEEE;
LIBRARY LPM;
library ALTERA_MF;

USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE LPM.LPM_COMPONENTS.ALL;
USE ALTERA_MF.ALTERA_MF_COMPONENTS.ALL;

ENTITY ExternalMemory IS
    PORT(
        RESETN,
        CS_ADDR, --1 if interacting with address
		  CS_DATA, --1 if 
        SCOMP_OUT,
		  CLOCK    : IN    STD_LOGIC;
        IO_DATA  : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END ExternalMemory;

ARCHITECTURE a OF ExternalMemory IS
    SIGNAL ADDRESS : STD_LOGIC_VECTOR(15 DOWNTO 0); --Now a 16 bit address register
	 SIGNAL TEMP_DATA     : STD_LOGIC_VECTOR(15 DOWNTO 0); -- 16-bit data output from memory
    BEGIN

    -- Use Intel LPM IP to create tristate drivers
    IO_BUS: lpm_bustri
        GENERIC MAP (
        lpm_width => 16
    )
    PORT MAP (
        enabledt => CS_DATA AND NOT(SCOMP_OUT), -- when SCOMP reads
        data     => TEMP_DATA,  -- provide this value
        tridata  => IO_DATA -- driving the IO_DATA bus
    );
	 
	 -- Use Intel Altsyncram to create a memory component
	 MEM_COMPONENT: altsyncram 
		GENERIC MAP (
		numwords_a => 65536,
		widthad_a => 16,
		width_a => 16,
		power_up_uninitialized => "FALSE",
		clock_enable_input_a => "BYPASS",
		clock_enable_output_a => "BYPASS",
		intended_device_family => "MAX 10",
		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
		lpm_type => "altsyncram",
		operation_mode => "SINGLE_PORT",
		outdata_aclr_a => "NONE",
		outdata_reg_a => "UNREGISTERED",
		read_during_write_mode_port_a => "NEW_DATA_NO_NBE_READ",
		width_byteena_a => 1
		
	)
	PORT MAP (
		wren_a    => NOT(SCOMP_OUT) AND CS_DATA, --SCOMP_IN means the IO_DEVICE writes
		clock0    => clock,
		address_a => ADDRESS,
		data_a    => IO_DATA,
		q_a       => TEMP_DATA
	);
	 
	 

    PROCESS(clock)
    BEGIN
        IF RISING_EDGE(clock) THEN
				IF CS_ADDR = '1'  and SCOMP_OUT = '1' THEN
					ADDRESS <= IO_DATA; --Save address in data register
				END IF;
				
		  END IF;
    END PROCESS;

END a;