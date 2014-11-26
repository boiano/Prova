--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:30:03 10/28/2013
-- Design Name:   
-- Module Name:   C:/Xilinx/LAVORI/FAZIA/Test_Card_USB_16bit_V6/serial_tb.vhd
-- Project Name:  USB_16Bit_V5
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: TOP_Serial_TX_RX
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
 
ENTITY serial_tb IS
END serial_tb;
 
ARCHITECTURE behavior OF serial_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT TOP_Serial_TX_RX
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         Serial_rx_async : IN  std_logic;
         Serial_tx : OUT  std_logic;
         trasmitting_word : IN  std_logic_vector(0 to 7);
         start_tx : IN  std_logic;
         busy_tx : OUT  std_logic;
         accepted_word : OUT  std_logic;
         received_word : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal Serial_rx_async : std_logic := '0';
   signal trasmitting_word : std_logic_vector(0 to 7) := (others => '0');
   signal start_tx : std_logic := '0';

 	--Outputs
   signal Serial_tx : std_logic;
   signal busy_tx : std_logic;
   signal accepted_word : std_logic;
   signal received_word : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: TOP_Serial_TX_RX PORT MAP (
          clk => clk,
          rst => rst,
          Serial_rx_async => Serial_rx_async,
          Serial_tx => Serial_tx,
          trasmitting_word => trasmitting_word,
          start_tx => start_tx,
          busy_tx => busy_tx,
          accepted_word => accepted_word,
          received_word => received_word
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
      -- hold reset state for 100 ns.
      wait for 100 ns;	

		serial_rx_async <= '1';
		wait for 20 ns;
		serial_rx_async <= '0';
		
      wait;
   end process;

END;
