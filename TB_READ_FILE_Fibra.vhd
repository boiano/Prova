--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:48:50 05/02/2011
-- Design Name:   
-- Module Name:   D:/PROGETTI/XILINX/LAVORI/FAZIA/BlockCard/Prova_da_Buttare/FIFO_MS/TB_READ_FILE.vhd
-- Project Name:  BlockCard1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: READ_FILE
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
 
ENTITY TB_READ_FILE_Fibra IS
END TB_READ_FILE_Fibra;
 
ARCHITECTURE behavior OF TB_READ_FILE_Fibra IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT READ_FILE_Fibra_Format
    PORT(
         clk : IN  std_logic;
			rst : IN std_logic;
         RD_EN : IN  std_logic;
         data : OUT  std_logic_vector(15 downto 0);
			Kout : out std_logic_vector (1 downto 0 )
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
	signal rst : std_logic := '1';
   signal RD_EN : std_logic := '0';

 	--Outputs
   signal data : std_logic_vector(15 downto 0);
	signal Kout : std_logic_vector(1 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: READ_FILE_Fibra_Format PORT MAP (
          clk => clk,
			 rst => rst,
          RD_EN => RD_EN,
          data => data,
			 Kout => Kout
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      rst <= '1';
      wait for 100 ns;	
		rst <= '0';
		wait for clk_period*7;
      RD_EN <= '1' ;
      wait for clk_period*7;
      RD_EN <= '0' ;
      wait for clk_period*10;
      RD_EN <= '1' ;
		wait for clk_period*7;
      RD_EN <= '0' ;
		wait for clk_period*7;
      RD_EN <= '1' ;
      wait for clk_period*7;
      RD_EN <= '0' ;
      wait for clk_period*10;
      RD_EN <= '1' ;
		wait for clk_period*7;
      RD_EN <= '0' ;
		wait for clk_period*7;
      RD_EN <= '1' ;
      wait for clk_period*7;
      RD_EN <= '0' ;
      wait for clk_period*10;
      RD_EN <= '1' ;
		wait for clk_period*7;
      RD_EN <= '0' ;

      wait;
   end process;

END;
