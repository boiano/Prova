----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:49:26 08/15/2011 
-- Design Name: 
-- Module Name:    TOP_Serial_TX_RX - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity TOP_Serial_TX_RX is
    Port ( clk 					: in  STD_LOGIC; -- 150MHZ ( GTX receiver )
			  rst 					: in  STD_LOGIC;
			  -- SERIALE
           Serial_rx_async 	: in  STD_LOGIC; --
			  Serial_tx			 		: out  STD_LOGIC; -- TX
			  -- TX
           trasmitting_word	: in  STD_LOGIC_VECTOR(0 to 7); 			 
			  start_tx				: in  STD_LOGIC;
			  busy_tx					: out	 STD_LOGIC;
		     ---  RX 
			  accepted_word			: out	 STD_LOGIC; -- RX Dato valid
			  received_word			: out  STD_LOGIC_VECTOR(7 downto 0)			  
           );
			  
end TOP_Serial_TX_RX;

architecture Behavioral of TOP_Serial_TX_RX is

component Serial_Receiver is
     Port ( clk 				: in  STD_LOGIC;
           rst 				: in  STD_LOGIC;
			  Serial_rx			: in  STD_LOGIC;
			  Cadence_rx		: in	STD_LOGIC;
			  busy_rx			: in	STD_LOGIC;
			  accepted_word		: out	STD_LOGIC;
			  received_word		: out STD_LOGIC_VECTOR(0 to 7));
end component Serial_Receiver;


component Serial_Transmitter is
     Port ( clk 					: in  STD_LOGIC;
           rst 					: in  STD_LOGIC;
           start_tx 				: in  STD_LOGIC;
			  cadence_tx			: in  STD_LOGIC;
           trasmitting_word 	: in  STD_LOGIC_VECTOR(7 downto 0);
           Serial_Tx 				: out  STD_LOGIC);
end component Serial_Transmitter;


component Bit_rate_Rx is
    Port ( 		clk 				: in  STD_LOGIC;
					rst 				: in  STD_LOGIC;
					start_rx			: in  STD_LOGIC;
					measure_rate	: in  STD_LOGIC;
					load_v 			: in  STD_LOGIC_VECTOR(15 downto 0);
					busy_rx					: out  STD_LOGIC;
					cadence_rx 				: out  STD_LOGIC);
end component Bit_rate_Rx;


component Bit_rate_Tx is
           Port ( clk 				: in  STD_LOGIC;
						rst 				: in  STD_LOGIC;
						start_tx			: in  STD_LOGIC;
						load_v 			: in  STD_LOGIC_VECTOR(15 downto 0);
						busy_tx				: out  STD_LOGIC;
						cadence_tx			: out  STD_LOGIC);
end component Bit_rate_Tx;


component Measure_Serial_Bitrate is
    Port ( clk 				: in  STD_LOGIC;
           rst 				: in  STD_LOGIC;
			  Serial_Rx			: in  STD_LOGIC;
			  measure_rate			: out STD_LOGIC);
end component Measure_Serial_Bitrate;


----------------------------------------------------------------------

signal start_rx, cadence_rx, measure_rate		:STD_LOGIC;
signal cadence_tx										:STD_LOGIC;
signal Serial_Rx, xSerial_Rx						:STD_LOGIC;
signal busy_rx											:STD_LOGIC;
signal pstart_rx										:STD_LOGIC;
signal  xSerial_Tx									:STD_LOGIC;
signal load_v											:STD_LOGIC_VECTOR(15 downto 0);

--  For chipscope debugging
attribute keep : string;
attribute keep of cadence_rx 	: signal is "true";
attribute keep of cadence_tx 	: signal is "true";
attribute keep of Serial_Rx 	: signal is "true";
attribute keep of busy_rx 		: signal is "true";
attribute keep of load_v 		: signal is "true";
attribute keep of start_rx 	: signal is "true";
attribute keep of start_tx 	: signal is "true";


begin

load_v <= x"055D"; -- fixed baud rate


Ricevitore_seriale: Serial_Receiver
	Port map( 	clk 				=> clk 				,
					rst 			   => rst 			   ,
					Serial_rx		=> Serial_rx		,
					Cadence_rx	   => Cadence_rx	   ,
					busy_rx			=> busy_rx 			,
					accepted_word	=> accepted_word	,
					received_word(0) 	=> received_word(0)	,
					received_word(1) 	=> received_word(1)	,
					received_word(2) 	=> received_word(2)	,
					received_word(3) 	=> received_word(3)	,
					received_word(4) 	=> received_word(4)	,
					received_word(5) 	=> received_word(5)	,
					received_word(6) 	=> received_word(6)	,
					received_word(7) 	=> received_word(7)	);

Trasmettitore_seriale: Serial_Transmitter
	Port map( 	clk 					=> clk 					,
					rst 			  		=> rst 			   	,
					start_tx 			=> start_tx 			,
					cadence_tx		 	=> cadence_tx			,
					trasmitting_word	=> trasmitting_word	,
					Serial_Tx 			=> xSerial_Tx 		 	);
					
	Serial_TX <= not xSerial_Tx;						-- ATTENZIONE : L'inversione è dovuta alla presenza di un 3202
                                                --						che inverte i livelli logici

Bitrate_Rx: Bit_rate_Rx
	Port map( 	clk 				=> clk 			,
					rst 				=>	rst 			,
					start_rx			=>	start_rx		,
					measure_rate   => measure_rate,
					load_v 		   => load_v 		,
					busy_rx			=> busy_rx 		,
					cadence_rx 	   => cadence_rx	);
					
Bitrate_Tx: Bit_rate_Tx
	Port map( 	clk 			=> clk 		 	,
					rst 			=>	rst 		 	,
					start_tx		=>	start_tx	 	,
					busy_tx		=> busy_tx		,
					load_v 	   => load_v 	 	,
					cadence_tx  => cadence_tx	);

Measure_Serial_Rate: Measure_Serial_Bitrate
	Port map( 	clk 				=> clk 		 		,
					rst 				=>	rst 		 		,
					Serial_Rx		=>	Serial_Rx		,
               measure_rate	=> measure_rate	);


Start_Read :process(clk, rst)
	begin
		if(rst = '1')then
			pstart_rx <= '0';
		else if(clk'event and clk = '1')then
				pstart_rx <= Serial_Rx;
			end if;
		end if;
end process Start_Read;

start_rx <= (Serial_Rx and not pstart_rx and not busy_rx);



--------------------------------------------------------------------
Syncronize_RX :process(clk, rst)
	begin
		if(rst = '1')then
			Serial_Rx <= '0';
			xSerial_Rx <= '0';
		else if(clk'event and clk = '1')then
				 Serial_Rx <= xSerial_Rx;
				 xSerial_Rx <= not Serial_rx_async;			-- ATTENZIONE : L'inversione è dovuta alla presenza di un 3202
			end if;													--						che inverte i livelli logici
		end if;
end process Syncronize_RX;




end Behavioral;

