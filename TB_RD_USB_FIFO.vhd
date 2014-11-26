--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:39:32 05/11/2012
-- Design Name:   
-- Module Name:   D:/PROGETTI/XILINX/LAVORI/FAZIA/Test_Card/Prova_USB/Prova_USB_GTX/TB_RD_USB_FIFO.vhd
-- Project Name:  Pll_USB_1GTX
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: RD_USB_FIFO
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
 
ENTITY TB_RD_USB_FIFO IS
END TB_RD_USB_FIFO;
 
ARCHITECTURE behavior OF TB_RD_USB_FIFO IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT RD_USB_FIFO
    PORT(
         USBclk : IN  std_logic;
         Rst : IN  std_logic;
         Serial_USB : IN  std_logic;
         rd_fifo : OUT  std_logic;
         Data_from_Fifo : IN  std_logic_vector(15 downto 0);
         empty_fifo : IN  std_logic;
         Data_to_USB : OUT  std_logic_vector(7 downto 0);
         Invia : OUT  std_logic;
         Send_Pkend : OUT  std_logic;
         USB_FUll : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal USBclk : std_logic := '0';
   signal Rst : std_logic := '1';
   signal Serial_USB : std_logic := '0';
   signal Data_from_Fifo : std_logic_vector(15 downto 0) := (others => '0');
   signal empty_fifo : std_logic := '0';
   signal USB_FUll : std_logic := '0';

 	--Outputs
   signal rd_fifo : std_logic;
   signal Data_to_USB : std_logic_vector(7 downto 0);
   signal Invia : std_logic;
   signal Send_Pkend : std_logic;

   -- Clock period definitions
   constant USBclk_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: RD_USB_FIFO PORT MAP (
          USBclk => USBclk,
          Rst => Rst,
          Serial_USB => Serial_USB,
          rd_fifo => rd_fifo,
          Data_from_Fifo => Data_from_Fifo,
          empty_fifo => empty_fifo,
          Data_to_USB => Data_to_USB,
          Invia => Invia,
          Send_Pkend => Send_Pkend,
          USB_FUll => USB_FUll
        );

   -- Clock process definitions
   USBclk_process :process
   begin
		USBclk <= '0';
		wait for USBclk_period/2;
		USBclk <= '1';
		wait for USBclk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
     Rst <= '1' ;
      wait for 100 ns;	
		 Rst <= '0' ;

      wait for USBclk_period*10;
		 Serial_USB      <= '1' ;
		 Data_from_Fifo  <= X"1233" ;
       empty_fifo      <= '1';
       USB_FUll        <= '1';
		 
		       wait for USBclk_period*6;
		 Serial_USB      <= '1' ;
		 Data_from_Fifo  <= X"3344" ;
       empty_fifo      <= '1';
       USB_FUll        <= '0';
		 
		       wait for USBclk_period*6;
		 Serial_USB      <= '1' ;
		 Data_from_Fifo  <= X"1255" ;
       empty_fifo      <= '0';
       USB_FUll        <= '1';
		 
		 
		       wait for USBclk_period*6;
		 Serial_USB      <= '1' ;
		 Data_from_Fifo  <= X"1266" ;
       empty_fifo      <= '0';
       USB_FUll        <= '0';
		 
		 
		       wait for USBclk_period*6;
		 Serial_USB      <= '1' ;
		 Data_from_Fifo  <= X"1277" ;
       empty_fifo      <= '1';
       USB_FUll        <= '1';
		 
		 
		       wait for USBclk_period*6;
		 Serial_USB      <= '1' ;
		 Data_from_Fifo  <= X"6288" ;
       empty_fifo      <= '1';
       USB_FUll        <= '0';
		 
		 		       wait for USBclk_period*1;
		 Serial_USB      <= '1' ;
		 Data_from_Fifo  <= X"82ff" ;
       empty_fifo      <= '1';
       USB_FUll        <= '0';

      wait;
   end process;

END;
