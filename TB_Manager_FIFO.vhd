
--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   00:34:13 11/07/2011
-- Design Name:   Manager_FIFO
-- Module Name:   D:/Lavoro/Prog Ise/boiano/TB_Manager_FIFO.vhd
-- Project Name:  boiano
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Manager_FIFO
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

ENTITY TB_Manager_FIFO_vhd IS
END TB_Manager_FIFO_vhd;

ARCHITECTURE behavior OF TB_Manager_FIFO_vhd IS 

	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT Manager_FIFO	
 Port ( 	  rd_clk 	: IN std_logic;
			  wr_clk 	: IN std_logic;
           rst 		: in  STD_LOGIC;
	--  Connessione della Seriale		  
           req_read_fifo 	: in  STD_LOGIC;
           busy_Tx 			: in  STD_LOGIC;
           Data_to_Serial 	: out  STD_LOGIC_VECTOR (7 downto 0);
           Send_Data 		: out  STD_LOGIC;
	--  WR FIFO 
			  en_wrt_fifo	: in  STD_LOGIC;
			  dis_wrt_fifo	: in  STD_LOGIC;
			  almost_full 	:  out  STD_LOGIC;
           Data_to_FIFO : in  STD_LOGIC_VECTOR (15 downto 0);
           Kin : in  STD_LOGIC);
	                                                                          			
	END COMPONENT;                                                                   
	                                                                                 
	COMPONENT TOP_Serial_TX_RX is                                                    
    Port ( clk 					: in  STD_LOGIC; -- 150MHZ ( GTX receiver )
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
	SIGNAL rd_clk :  std_logic := '0';
	SIGNAL wr_clk :  std_logic := '1';
	SIGNAL rst :  std_logic := '1';
	SIGNAL req_read_fifo :  std_logic := '0';
	SIGNAL busy_Tx :  std_logic := '0';
	--SIGNAL wrt_FIFO :  std_logic := '0';
	SIGNAL Data_to_FIFO :  std_logic_vector(15 downto 0) := (others=>'0');
	
	SIGNAL Serial_rx_async : std_logic := '1';
	SIGNAL Serial_tx		  : std_logic ;
	
	SIGNAL en_wrt_fifo		  : std_logic := '0' ;
	SIGNAL dis_wrt_fifo		  : std_logic  := '0';
	SIGNAL Kin		  				: std_logic  := '0';
	signal send_data          : std_logic ;

	--Outputs
	SIGNAL Data_to_Serial :  std_logic_vector(7 downto 0);
	SIGNAL almost_full :  std_logic;
	
	constant periodo : time  := 10 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: Manager_FIFO PORT MAP(											
		rd_clk 			=> rd_clk,                                        
		wr_clk 			=> wr_clk,                                        
		rst 				=> rst,                                                
		req_read_fifo 	=> req_read_fifo,                          
		busy_Tx 			=> busy_Tx,                                      
		Data_to_Serial => Data_to_Serial,                        
		Send_Data 		=> Send_Data, 
		en_wrt_fifo		=> en_wrt_fifo,
		dis_wrt_fifo	=> dis_wrt_fifo,
		almost_full 	=> almost_full,
		Data_to_FIFO 	=> Data_to_FIFO,                            
		Kin 				=>  Kin                                      
	);                                                   
	                                                     
	--  Inst SERIALE                                     
Seriale: TOP_Serial_TX_RX   PORT MAP (                  
	clk 						=>	 rd_clk,		
	rst 						=>  rst,
	-- SERIALE
	Serial_rx_async 		=> Serial_rx_async,
	Serial_tx				=> Serial_tx,
	-- TX
	trasmitting_word		=> Data_to_Serial,
	start_tx					=> Send_Data,
	busy_tx					=> busy_Tx,
	---  RX 
   accepted_word			=>  open,
	received_word			=>  open );
	
	
	
	rd_clk <= not rd_clk after periodo/2;
	wr_clk <= not wr_clk after periodo/2;
	
	--------------
	tb : PROCESS
	BEGIN
		wait for periodo*5;
			rst <= '0';
		wait for periodo*5;		Data_to_FIFO <= x"ab00";  Kin <= '1'; en_wrt_fifo<='0';  dis_wrt_fifo <= '0';
		wait for periodo;       Data_to_FIFO <= x"ab01";  Kin <= '0'; en_wrt_fifo<='1';  dis_wrt_fifo <= '0';
		wait for periodo;       Data_to_FIFO <= x"ab02";  Kin <= '0'; en_wrt_fifo<='0';  dis_wrt_fifo <= '0';
		wait for periodo;       Data_to_FIFO <= x"ab03";  Kin <= '0'; en_wrt_fifo<='0';  dis_wrt_fifo <= '0';
		wait for periodo;       Data_to_FIFO <= x"ab04";  Kin <= '0'; en_wrt_fifo<='0';  dis_wrt_fifo <= '0';
		wait for periodo;       Data_to_FIFO <= x"fb05";  Kin <= '0'; en_wrt_fifo<='0';  dis_wrt_fifo <= '0';
		wait for periodo;       Data_to_FIFO <= x"ab06";  Kin <= '1'; en_wrt_fifo<='0';  dis_wrt_fifo <= '0';
		wait for periodo;       Data_to_FIFO <= x"ab07";  Kin <= '0'; en_wrt_fifo<='0';  dis_wrt_fifo <= '0';
		wait for periodo;       Data_to_FIFO <= x"ab08";  Kin <= '0'; en_wrt_fifo<='0';  dis_wrt_fifo <= '0';
		wait for periodo;       Data_to_FIFO <= x"ab09";  Kin <= '1'; en_wrt_fifo<='0';  dis_wrt_fifo <= '0';
		wait for periodo;       Data_to_FIFO <= x"ab0a";  Kin <= '0'; en_wrt_fifo<='0';  dis_wrt_fifo <= '0';
		wait for periodo;       Data_to_FIFO <= x"fb0b";  Kin <= '0'; en_wrt_fifo<='0';  dis_wrt_fifo <= '0';
		wait for periodo;       Data_to_FIFO <= x"ab0c";  Kin <= '1'; en_wrt_fifo<='0';  dis_wrt_fifo <= '0';
		wait for periodo;       Data_to_FIFO <= x"ab0d";  Kin <= '0'; en_wrt_fifo<='0';  dis_wrt_fifo <= '0';
		wait for periodo;       Data_to_FIFO <= x"ab0e";  Kin <= '1'; en_wrt_fifo<='0';  dis_wrt_fifo <= '0';
		wait for periodo;       Data_to_FIFO <= x"ab0f";  Kin <= '0'; en_wrt_fifo<='0';  dis_wrt_fifo <= '1';
		wait for periodo;       Data_to_FIFO <= x"ab10";  Kin <= '0'; en_wrt_fifo<='0';  dis_wrt_fifo <= '0';
		wait for periodo;       Data_to_FIFO <= x"ab11";  Kin <= '1'; en_wrt_fifo<='0';  dis_wrt_fifo <= '0';
		wait for periodo;       Data_to_FIFO <= x"ab12";  Kin <= '0'; en_wrt_fifo<='0';  dis_wrt_fifo <= '0';
		wait for periodo;       Data_to_FIFO <= x"fb13";  Kin <= '1'; en_wrt_fifo<='1';  dis_wrt_fifo <= '0';
		wait for periodo;       Data_to_FIFO <= x"ab14";  Kin <= '0'; en_wrt_fifo<='0';  dis_wrt_fifo <= '0';
		wait for periodo;       Data_to_FIFO <= x"ab15";  Kin <= '1'; en_wrt_fifo<='1';  dis_wrt_fifo <= '0';
		wait for periodo;       Data_to_FIFO <= x"ab16";  Kin <= '0'; en_wrt_fifo<='0';  dis_wrt_fifo <= '0';
		wait for periodo;       Data_to_FIFO <= x"ab17";  Kin <= '1'; en_wrt_fifo<='0';  dis_wrt_fifo <= '0';
		wait for periodo;       Data_to_FIFO <= x"0b18";  Kin <= '0'; en_wrt_fifo<='0';  dis_wrt_fifo <= '1';
		wait for periodo;       Data_to_FIFO <= x"0b19";  Kin <= '0'; en_wrt_fifo<='0';  dis_wrt_fifo <= '0';												
		
 
 
     wait for periodo; 		Serial_rx_async <= '0' ;
     wait for periodo*6; 	Serial_rx_async <= '1' ;
 
 
 
 

----------------------------------------------------------		
		wait for 100 ns;
			req_read_fifo <= '1';	-- RICHIESTA LETTURA FIFO
		wait for 10 ns;
			req_read_fifo <= '0';


		wait for 800 ns;
			req_read_fifo <= '1';	-- RICHIESTA LETTURA FIFO
		wait for 10 ns;
			req_read_fifo <= '0';



		wait for 35000 ns;
		
		
		----------------------------------------------------------		
		wait for 100 ns;
			req_read_fifo <= '1';	-- RICHIESTA LETTURA FIFO
		wait for 10 ns;
			req_read_fifo <= '0';
	

		wait for 35000 ns;
		
		
		----------------------------------------------------------		
		wait for 100 ns;
			req_read_fifo <= '1';	-- RICHIESTA LETTURA FIFO
		wait for 10 ns;
			req_read_fifo <= '0';

	

 	wait for 800 ns;
	
	  			Data_to_FIFO <= x"79ab";
		wait for 10 ns;
		
			
				wait for 100 ns;
			req_read_fifo <= '1';	-- RICHIESTA LETTURA FIFO
		wait for 10 ns;
			req_read_fifo <= '0';
			
			
		wait for 11000 ns;
		
						wait for 100 ns;
			req_read_fifo <= '1';	-- RICHIESTA LETTURA FIFO
		wait for 10 ns;
			req_read_fifo <= '0';
		
			wait for 11000 ns;

			Data_to_FIFO <= x"1111";
		wait for 10 ns;
		
		
		
			wait for 400 ns;
		
			wait for 100 ns;
			req_read_fifo <= '1';	-- RICHIESTA LETTURA FIFO
		wait for 10 ns;
			req_read_fifo <= '0';
			wait for 11000 ns;
			
			
			wait for 100 ns;
			req_read_fifo <= '1';	-- RICHIESTA LETTURA FIFO
		wait for 10 ns;
			req_read_fifo <= '0';
			wait for 11000 ns;
			

			wait for 100 ns;
			req_read_fifo <= '1';	-- RICHIESTA LETTURA FIFO
		wait for 10 ns;
			req_read_fifo <= '0';
			wait for 11000 ns;
						
			
			
		wait for 10 ns;
		
	
	
	 						wait for 100 ns;
			req_read_fifo <= '1';	-- RICHIESTA LETTURA FIFO
		wait for 10 ns;
			req_read_fifo <= '0';







		wait;					-- will wait forever
	END PROCESS;

END;
