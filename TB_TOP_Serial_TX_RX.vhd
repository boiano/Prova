
--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   01:55:02 08/24/2011
-- Design Name:   TOP_Serial_TX_RX
-- Module Name:   D:/Lavoro/Prog Ise/Serial_Com_TX_RX/TB_TOP_Serial_TX_RX.vhd
-- Project Name:  Serial_Com_TX_RX
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
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

ENTITY TB_TOP_Serial_TX_RX_vhd IS
END TB_TOP_Serial_TX_RX_vhd;

ARCHITECTURE behavior OF TB_TOP_Serial_TX_RX_vhd IS 

	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT TOP_Serial_TX_RX
	PORT(
	
	clk 					: in  STD_LOGIC; -- 150MHZ ( GTX receiver )
	rst 					: in  STD_LOGIC;
	-- SERIALE
	Serial_rx_async 	: in  STD_LOGIC; --
	Serial_tx			 	: out  STD_LOGIC; -- TX
	-- TX
	trasmitting_word	: in  STD_LOGIC_VECTOR(0 to 7); 			 
	start_tx				: in  STD_LOGIC;
	busy_tx				: out	 STD_LOGIC;
	---  RX 
	accepted_word			: out	 STD_LOGIC; -- RX Dato valid
	received_word			: out  STD_LOGIC_VECTOR(7 downto 0)			

		);
		
	END COMPONENT;

	--Inputs
	SIGNAL clk :  std_logic := '0';
	SIGNAL rst :  std_logic := '1';
	SIGNAL sw_s :  std_logic := '1';
	SIGNAL sw_c :  std_logic := '0';
	SIGNAL sw_n :  std_logic := '0';	
	SIGNAL Serial_rx_async :  std_logic := '1';
	--SIGNAL req_sync_rate :  std_logic := '0';	
	SIGNAL start_tx :  std_logic := '0';
	SIGNAL trasmitting_word :  std_logic_vector(7 downto 0) := (others=>'0');
	
	--Outputs
	SIGNAL Serial_tx :  std_logic;
	SIGNAL busy_tx :  std_logic;
	SIGNAL accepted_word :  std_logic;
	SIGNAL received_word :  std_logic_vector(7 downto 0) := (others=>'0');
	
BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: TOP_Serial_TX_RX PORT MAP( 
		clk => clk,                                       					
		rst => rst,                                       				
		Serial_rx_async => Serial_rx_async, 
	   Serial_tx => Serial_tx, 		
                   
	start_tx	=> start_tx,                            					
	trasmitting_word => trasmitting_word,             			
	  busy_tx => busy_tx,  
		---  RX 
                            		
		accepted_word => accepted_word,                   	
		received_word => received_word
	);
	
	clk <= not clk after 5 ns;

	tb : PROCESS
	BEGIN

		wait for 500 ns;
			rst <= '1';
		wait for 100 ns;
		   rst <= '0';
			wait for 100 ns;
			
			Serial_rx_async <= '0';		--Bit di Start
		wait for 120 ns;---------------------------------------
			Serial_rx_async <= '1';		--1°Bit Dati			
		wait for 120 ns;
			Serial_rx_async <= '0';		--2°,3° e 4° Bit di Dati
		wait for 360 ns;
			Serial_rx_async <= '1';		--5°,6°
		wait for 240 ns;
			Serial_rx_async <= '0';		--7°,8°			Parola di sincronizzazione non memorizzata
		wait for 240 ns;----------------------------------------
			Serial_rx_async <= '1';		--2 Bit di Stop, attesa prossimo invio
		wait for 1800 ns;

			Serial_rx_async <= '0';		--Bit di Start
		wait for 120 ns;----------------------------------------
			Serial_rx_async <= '0';		--1°Bit Dati			
		wait for 120 ns;
			Serial_rx_async <= '1';		--2°,3° e 4° Bit di Dati
		wait for 360 ns;
			Serial_rx_async <= '0';		--5°,6°
		wait for 240 ns;
			Serial_rx_async <= '1';		--7°,8°			TRASMESSO 73
		wait for 240 ns;----------------------------------------		
			Serial_rx_async <= '1';		--2 Bit di Stop, attesa prossimo invio	

		wait for 240 ns;---------Invio immediato nuova parola
			Serial_rx_async <= '0';		--Bit di Start
		wait for 120 ns;----------------------------------------
			Serial_rx_async <= '1';		--1°Bit Dati			
		wait for 120 ns;
			Serial_rx_async <= '0';		--2°,3°  Bit di Dati
		wait for 240 ns;
			Serial_rx_async <= '1';		--4°,5°		
		wait for 240 ns;
			Serial_rx_async <= '0';		--6°			
		wait for 120 ns;
			Serial_rx_async <= '1';		--7°,8°			TRSMESSO 9B
		wait for 240 ns;----------------------------------------		
			Serial_rx_async <= '1';		--2 Bit di Stop, attesa prossimo invio

		wait for 1240 ns;
		
		wait for 10 ns;
		
			
		wait for 100 ns;----------Cambio velocità di trasmissione
			Serial_rx_async <= '0';		--Bit di Start
		wait for 200 ns;----------------------------------------
			Serial_rx_async <= '1';		--1°Bit Dati			
		wait for 200 ns;
			Serial_rx_async <= '0';		--2°,3°  Bit di Dati
		wait for 400 ns;
			Serial_rx_async <= '1';		--4°,5°,6°			
		wait for 600 ns;
			Serial_rx_async <= '0';		--7°,8°			Parola di sincronizzazione non memorizzata
		wait for 400 ns;----------------------------------------		
			Serial_rx_async <= '1';		--2 Bit di Stop, attesa prossimo invio
		wait for 400 ns;
		
		wait for 500 ns;
			trasmitting_word <= x"7a";
		wait for 100 ns;
			 start_tx <= '1';
		wait for 10 ns;
			  start_tx <= '0';	
		wait for 2000 ns;

		wait for 200 ns;
			
		wait for 40 ns;
			
			
		wait for 50 ns;

			Serial_rx_async <= '0';		--Bit di Start
		wait for 50 ns;----------------------------------------
			Serial_rx_async <= '1';		--1°,2° Bit Dati			
		wait for 100 ns;
			Serial_rx_async <= '0';		--3°,4°  Bit di Dati
		wait for 100 ns;
			Serial_rx_async <= '1';		--5°,6°			
		wait for 100 ns;
			Serial_rx_async <= '0';		--7°,8°			Parola di sincronizzazione non memorizzata
		wait for 100 ns;----------------------------------------		
			Serial_rx_async <= '1';		--2 Bit di Stop, attesa prossimo invio
		wait for 200 ns;
		
		wait for 400 ns;
			trasmitting_word <= x"b7";
		wait for 20 ns;
		
		wait for 10 ns;
				
		wait for 520 ns;

		wait for 400 ns;
			trasmitting_word <= x"95";
		
		wait for 10 ns;
	
		wait for 540 ns;		
		
		wait; -- will wait forever
	END PROCESS;

END;
