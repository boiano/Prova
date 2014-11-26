
--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:05:35 10/09/2011
-- Design Name:   TX_to_FEE_Blk
-- Module Name:   D:/Lavoro/Prog Ise/Serial_Com_TX_RX/TB_TX_to_FEE_Blk.vhd
-- Project Name:  Serial_tx_rx
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: TX_to_FEE_Blk
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

ENTITY TB_TX_to_FEE_Blk_vhd IS
END TB_TX_to_FEE_Blk_vhd;

ARCHITECTURE behavior OF TB_TX_to_FEE_Blk_vhd IS 

	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT TX_to_FEE_Blk
	PORT(
		clk : IN std_logic;
	   CLK25MHz  : in  STD_LOGIC;
		rst : IN std_logic;
		Glb_Trg : IN std_logic;
		Tx_is_ready : IN std_logic;
		SCCT_from_S2Rx : IN std_logic;
		rst_ec_fS : IN std_logic;
		Reset_bc_fS : IN std_logic;
		Trg_Pattern : IN std_logic_vector(11 downto 0);          
		K_Tx : OUT std_logic_vector(1 downto 0);
		Stream_Tx : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	--Inputs
	SIGNAL clk :  std_logic := '1';
	SIGNAL CLK25MHz :  STD_LOGIC := '0';
	SIGNAL rst :  std_logic := '1';
	SIGNAL Glb_Trg :  std_logic := '0';
	SIGNAL Tx_is_ready :  std_logic := '0';
	SIGNAL SCCT_from_S2Rx :  std_logic := '0';
	SIGNAL rst_ec_fS :  std_logic := '0';
	SIGNAL Reset_bc_fS :  std_logic := '0';
	SIGNAL Trg_Pattern :  std_logic_vector(11 downto 0) := (others=>'0');

	--Outputs
	SIGNAL K_Tx :  std_logic_vector(1 downto 0);
	SIGNAL Stream_Tx :  std_logic_vector(15 downto 0);

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: TX_to_FEE_Blk PORT MAP(
		clk => clk,
		CLK25MHz => CLK25MHz,
		rst => rst,
		Glb_Trg => Glb_Trg,
		Tx_is_ready => Tx_is_ready,
		SCCT_from_S2Rx => SCCT_from_S2Rx,
		rst_ec_fS => rst_ec_fS,
		Reset_bc_fS => Reset_bc_fS,
		Trg_Pattern => Trg_Pattern,
		K_Tx => K_Tx,
		Stream_Tx => Stream_Tx
	);
	
	clk   <= not clk after 40 ns / 6;
   CLK25MHz <= not CLK25MHz after 40 ns;

	tb : PROCESS
	BEGIN

wait for 100 ns;
			rst <= '0';
		wait for 100 ns;
			Tx_is_ready <= '1';
			
		wait for 30 ns;
			Trg_Pattern <= x"a5a";
			
			
		wait for 200 ns;
			Glb_Trg <= '1';
		wait for 10 ns;
			Glb_Trg <= '0';
		wait for 40 ns;
			SCCT_from_S2Rx <= '1';
		
		wait for 60 ns;
			Glb_Trg <= '1';
		wait for 10 ns;
			Glb_Trg <= '0';			


		wait; -- will wait forever

	END PROCESS;

END;
