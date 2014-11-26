--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:15:30 10/13/2011
-- Design Name:   
-- Module Name:   D:/Prog_ise/seriale/TB_RX_from_FEE_Blk.vhd
-- Project Name:  Seriale_Tx_Rx
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: RX_from_FEE_Blk
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
 
ENTITY TB_RX_from_FEE_Blk IS
END TB_RX_from_FEE_Blk;
 
ARCHITECTURE behavior OF TB_RX_from_FEE_Blk IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT RX_from_FEE_Blk
    PORT(
         clk 				: IN  std_logic;
         rst 				: IN  std_logic;
         K 					: IN  std_logic_vector(1 downto 0);
         Stream_Data 	: IN  std_logic_vector(15 downto 0);
         SCCR_to_S2Tx 	: OUT  std_logic;
         GTT 	: OUT  std_logic;
         BMult : OUT  std_logic_vector(4 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '1';
   signal K : std_logic_vector(1 downto 0) := (others => '0');
   signal Stream_Data : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal SCCR_to_S2Tx 	: std_logic;
   signal GTT 				: std_logic;
   signal BMult 			: std_logic_vector(4 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: RX_from_FEE_Blk PORT MAP (
          clk 	=> clk,
          rst 	=> rst,
          K 	=> K,
          Stream_Data 	=> Stream_Data,
          SCCR_to_S2Tx 	=> SCCR_to_S2Tx,
          GTT 		=> GTT,
          BMult	=> BMult
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      wait for 100 ns;
			rst <= '0';
			
		wait for 100 ns;
		
			K <= "10";
			Stream_Data(15 downto 8) <= x"81";	--Sync_Word
			Stream_Data(7) <= '0';					--GTT
			Stream_Data(6) <= '1';					--SCCR
			Stream_Data(5 downto 1) <= "01010";	--Bmult
			Stream_Data(0) <= '0';
		wait for clk_period;
			K <= "00";
			Stream_Data	<= x"0001";
		wait for clk_period;
			Stream_Data	<= x"0002";
		wait for clk_period;
			Stream_Data	<= x"0003";
		wait for clk_period;
			Stream_Data	<= x"0004";
		wait for clk_period;
			Stream_Data	<= x"0005";
		wait for clk_period;


			K <= "10";
			Stream_Data(15 downto 8) <= x"81";	--Sync_Word
			Stream_Data(7) <= '0';					--GTT
			Stream_Data(6) <= '1';					--SCCR
			Stream_Data(5 downto 1) <= "01010";	--Bmult
			Stream_Data(0) <= '0';
		wait for clk_period;
			K <= "00";
			Stream_Data	<= x"0006";
		wait for clk_period;
			Stream_Data	<= x"0007";
		wait for clk_period;
			Stream_Data	<= x"0008";
		wait for clk_period;
			Stream_Data	<= x"0009";
		wait for clk_period;
			Stream_Data	<= x"000a";
		wait for clk_period;


			K <= "10";
			Stream_Data(15 downto 8) <= x"81";	--Sync_Word
			Stream_Data(7) <= '1';					--GTT
			Stream_Data(6) <= '0';					--SCCR
			Stream_Data(5 downto 1) <= "01010";	--Bmult
			Stream_Data(0) <= '0';
		wait for clk_period;
			K <= "00";
			Stream_Data	<= x"1111";
		wait for clk_period;
			Stream_Data	<= x"8080";
		wait for clk_period;
			Stream_Data	<= x"3333";
		wait for clk_period;
			Stream_Data	<= x"8080";
		wait for clk_period;
			Stream_Data	<= x"aaaa";
		wait for clk_period;

   		wait for clk_period;   ----------  Anomalia nei Dati
			Stream_Data	<= x"3333";
		wait for clk_period;
			Stream_Data	<= x"8080";
		wait for clk_period;
			Stream_Data	<= x"aaaa";
		wait for clk_period;




			K <= "10";
			Stream_Data(15 downto 8) <= x"81";	--Sync_Word
			Stream_Data(7) <= '0';					--GTT
			Stream_Data(6) <= '0';					--SCCR
			Stream_Data(5 downto 1) <= "10101";	--Bmult
			Stream_Data(0) <= '0';
		wait for clk_period;
			K <= "00";
			Stream_Data	<= x"bbbb";
		wait for clk_period;
			Stream_Data	<= x"eeee";
		wait for clk_period;
			Stream_Data	<= x"ffff";
		wait for clk_period;
			Stream_Data	<= x"9119";
		wait for clk_period;
			Stream_Data	<= x"aaaa";
		wait for clk_period;

			
      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
