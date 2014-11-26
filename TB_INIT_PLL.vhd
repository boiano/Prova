--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:06:27 10/31/2011
-- Design Name:   
-- Module Name:   D:/PROGETTI/XILINX/LAVORI/FAZIA/Test_Card/Test_Card_V0/Prova0_0/Prova0/TB_INIT_PLL.vhd
-- Project Name:  Prova0
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: INIT_PLL
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
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
ENTITY TB_INIT_PLL IS
END TB_INIT_PLL;
 
ARCHITECTURE behavior OF TB_INIT_PLL IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT INIT_PLL
    PORT(
         CLK : IN  std_logic;
         RESET : IN  std_logic;
         FATTO : OUT  std_logic;
         SDO : OUT  std_logic;
         SCK : OUT  std_logic;
         LE_1PLL : OUT  std_logic;
         LE_2PLL : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal RESET : std_logic := '1';

 	--Outputs
   signal FATTO : std_logic;
   signal SDO : std_logic;
   signal SCK : std_logic;
   signal LE_1PLL : std_logic;
   signal LE_2PLL : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: INIT_PLL PORT MAP (
          CLK => CLK,
          RESET => RESET,
          FATTO => FATTO,
          SDO => SDO,
          SCK => SCK,
          LE_1PLL => LE_1PLL,
          LE_2PLL => LE_2PLL
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
     RESET <= '1';
      wait for 100 ns;	

      RESET <= '0';

      -- insert stimulus here 

      wait;
   end process;

END;
