--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:25:21 09/13/2012
-- Design Name:   
-- Module Name:   D:/PROGETTI/XILINX/LAVORI/FAZIA/Test_Card/Test_Card_V0/CON_USB/USB_16bit_V1/TB_Pulser.vhd
-- Project Name:  USB_16Bit_V1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Pulser_Freq_FIX
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY TB_Pulser IS
END TB_Pulser;
 
ARCHITECTURE behavior OF TB_Pulser IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Pulser_Freq_FIX
    PORT(
         REF_CLK 		: IN  std_logic;
         RESET 		: IN  std_logic;
         EN 			: IN  std_logic;
			Tmax        : IN  STD_LOGIC_VECTOR (11 downto 0); -- Tempo Monostabile (( step 2621 uS  )) 7FF = 5,4 Sec
         Puls_OUT 	: OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal REF_CLK : std_logic := '0';
   signal RESET : std_logic := '1';
   signal EN : std_logic := '0';

 	--Outputs
   signal Puls_OUT : std_logic;

   -- Clock period definitions
   constant REF_CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Pulser_Freq_FIX 
	PORT MAP (
          REF_CLK => REF_CLK,
          RESET 	=> RESET,
          EN 		=> EN,
			 Tmax => X"000",
          Puls_OUT => Puls_OUT
        );

   -- Clock process definitions
   REF_CLK_process :process
   begin
		REF_CLK <= '0';
		wait for REF_CLK_period/2;
		REF_CLK <= '1';
		wait for REF_CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
   RESET <= '1' ;
      wait for 100 ns;	
   RESET <= '0' ;
      wait for REF_CLK_period*10;
		
		EN <= '1';
      wait for REF_CLK_period*3400000;
		
		EN <= '0';
		
      wait for REF_CLK_period*10;
		
		EN <= '1'; 

      wait;
   end process;

END;
