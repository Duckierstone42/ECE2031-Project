---- ExternalMemory.VHD
---- 2024.10.22
----
---- This SCOMP peripheral provides one 16-bit word of external memory for SCOMP.
---- Any value written to this peripheral can be read back.
--
--LIBRARY IEEE;
--LIBRARY LPM;
--library ALTERA_MF;
--
--USE IEEE.STD_LOGIC_1164.ALL;
--USE IEEE.STD_LOGIC_ARITH.ALL;
--USE IEEE.STD_LOGIC_UNSIGNED.ALL;
--USE LPM.LPM_COMPONENTS.ALL;
--USE ALTERA_MF.ALTERA_MF_COMPONENTS.ALL;
--
--ENTITY ExternalMemory IS
--    PORT(
--        RESETN,
--        CS_ADDR, --1 if interacting with address
--		  CS_DATA, --1 if 
--        SCOMP_OUT, --1 if scomp is writing, so memory should be written to
--		  CLOCK    : IN    STD_LOGIC;
--        IO_DATA  : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0)
--    );
--END ExternalMemory;
--
--ARCHITECTURE a OF ExternalMemory IS
--    SIGNAL ADDRESS : STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '0'); --Now a 16 bit address register
--	 SIGNAL TEMP_DATA     : STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '0'); -- 16-bit data output from memory. TEMP_DATA not really updated it seems.
--    BEGIN
--
--    -- Use Intel LPM IP to create tristate drivers
--    IO_BUS: lpm_bustri
--        GENERIC MAP (
--        lpm_width => 16
--    )
--    PORT MAP (
--        enabledt => CS_DATA AND NOT(SCOMP_OUT), -- when SCOMP reads
--        data     => TEMP_DATA,  -- provide this value
--        tridata  => IO_DATA -- driving the IO_DATA bus
--    );
--	 --Get rid of this IO_BUS and manually implement it.
--	 
--	 -- Use Intel Altsyncram to create a memory component
--	 MEM_COMPONENT: altsyncram 
--		GENERIC MAP (
--		numwords_a => 65536,
--		widthad_a => 16,
--		width_a => 16,
--		power_up_uninitialized => "FALSE",
--		clock_enable_input_a => "BYPASS",
--		clock_enable_output_a => "BYPASS",
--		intended_device_family => "MAX 10",
--		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
--		lpm_type => "altsyncram",
--		operation_mode => "SINGLE_PORT",
--		outdata_aclr_a => "NONE",
--		outdata_reg_a => "UNREGISTERED",
--		read_during_write_mode_port_a => "NEW_DATA_NO_NBE_READ",
--		width_byteena_a => 1
--		
--	)
--	PORT MAP (
--		wren_a    => SCOMP_OUT AND CS_DATA, --SCOMP_IN means the IO_DEVICE writes. When scomp is writing the memory shold be enabled.
--		clock0    => clock,
--		address_a => ADDRESS,
--		data_a    => IO_DATA,
--		q_a       => TEMP_DATA
--	);
--	 
--	 
--
--    PROCESS(CS_ADDR,SCOMP_OUT,IO_DATA)
--    BEGIN
--			IF CS_ADDR = '1'  and SCOMP_OUT = '1' THEN
--				ADDRESS <= IO_DATA; --Save address in data register
--				TEMP_DATA <= (others =>'1');
--			END IF;
--				
--    END PROCESS;
--
--END a;


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

entity ExternalMemory is
    Port (
        RESETN       : in  std_logic;
        CS_ADDR      : in  std_logic;
        CS_DATA      : in  std_logic;
        SCOMP_OUT    : in  std_logic;
        clock          : in  std_logic;
        IO_DATA      : inout std_logic_vector(15 downto 0) -- 16-bit data
    );
end ExternalMemory;

architecture Behavioral of ExternalMemory is

    -- Address register for the target memory address
    signal address : std_logic_vector(15 downto 0) := (others => '0');
    signal mem_data_in      : std_logic_vector(15 downto 0) := (others => '0');
    signal mem_data_out     : std_logic_vector(15 downto 0) := (others => '0');
    signal mem_write_enable : std_logic := '0';

begin

    -- Clocked process for register updates
    process(CS_ADDR,CS_DATA, SCOMP_OUT, RESETN)
    begin
			if RESETN = '0' then
				 address <= (others => '0');
				 mem_write_enable <= '0';
				 mem_data_in      <= (others => '0');
			elsif CS_ADDR = '1' then
				 -- Update address register if  CS_ADDR and SCOMP_OUT is
				 if SCOMP_OUT = '1' then
					  address <= IO_DATA;
				 end if;
			elsif CS_DATA = '1' then
				if SCOMP_OUT = '1' then
					mem_data_in <= IO_DATA;
					mem_write_enable <= '1';
				else
					mem_write_enable <= '0';
				end if;
			else 
				mem_write_enable <= '0';
			end if;
    end process;

    -- Combinational process for IO_DATA tri-state control
    process(RESETN, CS_DATA, SCOMP_OUT, mem_data_out)
    begin
        if RESETN = '0' then
            IO_DATA <= (others => 'Z');
        elsif CS_DATA = '1' and SCOMP_OUT = '0' then --SCOMP_IN is when we write to IO_DATA
            IO_DATA <= mem_data_out;
        else
            IO_DATA <= (others => 'Z');
        end if;
    end process;

    -- Instantiation of altsyncram
    mem_instance : altsyncram
        generic map (
            numwords_a => 2048,
				widthad_a => 16,
				width_a => 16,
				power_up_uninitialized => "FALSE",
				clock_enable_input_a => "BYPASS",
				clock_enable_output_a => "BYPASS",
				intended_device_family => "MAX 10",
				lpm_hint => "ENABLE_RUNTIME_MOD=YES,INSTANCE_NAME=live",
				lpm_type => "altsyncram",
				operation_mode => "SINGLE_PORT",
				outdata_aclr_a => "NONE",
				outdata_reg_a => "UNREGISTERED",
				read_during_write_mode_port_a => "NEW_DATA_NO_NBE_READ",
				width_byteena_a => 1
        )
        port map (
            clock0    => clock,
            address_a => address,
            data_a    => mem_data_in,
            wren_a    => mem_write_enable,
            q_a       => mem_data_out
        );

end Behavioral;









