----------------------------------------------------------------------------------
-- Company:   INFN
-- Engineer: 
-- 
-- Create Date:    20:59:29 10/22/2011 
-- Design Name: 
-- Module Name:    Reader_FIFO - Behavioral 
-- Project Name: 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Reader_FIFO is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           req_read_fifo : in  STD_LOGIC;
           Data_from_Fifo : in  STD_LOGIC_VECTOR (15 downto 0);
			  empty_fifo: in  STD_LOGIC;
			   read_fifo : out  STD_LOGIC:= '0';
		-- to RS232		
           busy_Tx : in  STD_LOGIC;
           Data_to_Serial : out  STD_LOGIC_VECTOR (7 downto 0);
           Send_Data : out  STD_LOGIC);	--start_tx
			  
end Reader_FIFO;

architecture Behavioral of Reader_FIFO is


Type State_rd_fifo is (idle, rd_from_fifo, wait_for_send, send1word , wait1send, send2word , wait2send,
									send3word , wait3send, send4word , wait4send, send_CR, waitCRsend);
signal cs_rd_fifo, ns_rd_fifo : State_rd_fifo := idle;

signal eoe	: STD_LOGIC:= '0';	--start_read_fifo, reading_fifo, stop_read_fifo,
signal Data_format_ASCII : STD_LOGIC_VECTOR(7 downto 0);
signal Data_to_send : STD_LOGIC_VECTOR(3 downto 0):= "0000";

constant Terminatore : STD_LOGIC_VECTOR(7 downto 0) := X"0A";

begin


----- NEXT STATE ------- FINITE STATE MACHINE --------------------------
Status_Update: process (clk , rst)
begin
	if rst = '1' then 
		cs_rd_fifo <= idle;
	elsif (clk'event and clk = '1') then 
		cs_rd_fifo <= ns_rd_fifo;
	end if;
end process Status_Update;

--------------------------------------------------
flowchart: process (cs_rd_fifo, busy_tx, req_read_fifo, empty_fifo, Data_from_Fifo, Data_format_ASCII, eoe )
begin
 case cs_rd_fifo is
	-----------------------------------
	when idle =>									-- STATO DI RIPOSO
	read_fifo <= '0';
	Send_Data <= '0';
	Data_to_send <= x"0";  -- In convertitore ASII
	Data_to_Serial <= x"00";	
	
		if (req_read_fifo = '1') then 
			ns_rd_fifo <= rd_from_fifo;
		else
			ns_rd_fifo <= idle;
		end if;
	-----------------------------------
	when rd_from_fifo =>							-- LETTURA DALLA FIFO
	Send_Data <= '0';
	Data_to_send <= Data_from_Fifo(15 downto 12);
	Data_to_Serial <= Data_format_ASCII;
	
		if (empty_fifo ='1') then
			ns_rd_fifo <= idle;
			read_fifo <= '0';
		elsif (busy_Tx = '0') then
			read_fifo <= '1';
			ns_rd_fifo <= wait_for_send;
		else
			ns_rd_fifo <= cs_rd_fifo;
			read_fifo <= '0';
		end if;
	-----------------------------------
	when wait_for_send =>						-- ATTESA
			read_fifo <= '0';
			Data_to_send <= Data_from_Fifo(15 downto 12);
			Data_to_Serial <= Data_format_ASCII;
			Send_Data <= '0';

			ns_rd_fifo <= send1word;
	-----------------------------------
	when send1word =>								-- INVIO 1° DATO ASCII
			read_fifo <= '0';	
			Data_to_send <= Data_from_Fifo(15 downto 12);
			Data_to_Serial <= Data_format_ASCII;
			Send_Data <= '1';

			ns_rd_fifo <= wait1send;
	-----------------------------------
	when wait1send =>
			read_fifo <= '0';
			Send_Data <= '0';
			Data_to_Serial <= Data_format_ASCII;
		if (busy_Tx = '1') then
			ns_rd_fifo <= cs_rd_fifo;
			Data_to_send <= Data_from_Fifo(15 downto 12);
		else
			ns_rd_fifo <= send2word;
			Data_to_send <= Data_from_Fifo(11 downto 8);
		end if;
	-----------------------------------
	when send2word =>								-- INVIO 2° DATO ASCII
			Data_to_send <= Data_from_Fifo(11 downto 8);
			Data_to_Serial <= Data_format_ASCII;
			Send_Data <= '1';
			read_fifo <= '0';
		
			ns_rd_fifo <= wait2send;
	-----------------------------------
	when wait2send =>
			read_fifo <= '0';
			Send_Data <= '0';
			Data_to_Serial <= Data_format_ASCII;
		if (busy_Tx = '1') then
			ns_rd_fifo <= cs_rd_fifo;
			Data_to_send <= Data_from_Fifo(11 downto 8);
		else
			ns_rd_fifo <= send3word;
			Data_to_send <= Data_from_Fifo(7 downto 4);
		end if;
	-----------------------------------
	when send3word =>								-- INVIO 3° DATO ASCII
			Data_to_send <= Data_from_Fifo(7 downto 4);
			Data_to_Serial <= Data_format_ASCII;
			Send_Data <= '1';
			read_fifo <= '0';
		
			ns_rd_fifo <= wait3send;
	-----------------------------------
	when wait3send =>
			read_fifo <= '0';
			Send_Data <= '0';
			Data_to_Serial <= Data_format_ASCII;
		if (busy_Tx = '1') then
			ns_rd_fifo <= cs_rd_fifo;
			Data_to_send <= Data_from_Fifo(7 downto 4);
		else
			ns_rd_fifo <= send4word;
			Data_to_send <= Data_from_Fifo(3 downto 0);
		end if;
	-----------------------------------
	when send4word =>								-- INVIO 4° DATO ASCII
			Data_to_send <= Data_from_Fifo(3 downto 0);
			Data_to_Serial <= Data_format_ASCII;
			Send_Data <= '1';
			read_fifo <= '0';
		
			ns_rd_fifo <= wait4send; 
	-----------------------------------
	when wait4send =>
			read_fifo <= '0';
			Send_Data <= '0';
			Data_to_send <= Data_from_Fifo(3 downto 0);
		if (busy_Tx = '1') then
			ns_rd_fifo <= cs_rd_fifo;
			Data_to_Serial <= Data_format_ASCII;
		else
			ns_rd_fifo <= send_CR;
			Data_to_Serial <= Terminatore;
		end if;				  
	-----------------------------------
	when send_CR =>								-- INVIO CARRIAGE RETURN
			Data_to_Serial <= Terminatore;
			Send_Data <= '1';
			read_fifo <= '0';
			Data_to_send <= x"0";  --
			ns_rd_fifo <= waitCRsend;
	-----------------------------------
	when waitCRsend =>
			read_fifo <= '0';
			Data_to_send <= x"0";  --
			Send_Data <= '0';
			Data_to_Serial <= Terminatore;
		if (busy_Tx = '1') then
			ns_rd_fifo <= cs_rd_fifo;
		elsif(eoe = '1')then
			ns_rd_fifo <= idle;
		else
			ns_rd_fifo <= rd_from_fifo;
		end if;				  
	-----------------------------------	
	when others => ns_rd_fifo <= idle;	
			read_fifo <= '0';
			Data_to_send <= x"0";  --
			Send_Data <= '0';
			Data_to_Serial <= Terminatore;		
	end case;
end process flowchart;

---------------------------------------------------------------------
with Data_to_send select	
      Data_format_ASCII  <= 	"00110000" when (x"0"),
										"00110001" when (x"1"),
										"00110010" when (x"2"),
										"00110011" when (x"3"),
										"00110100" when (x"4"),
										"00110101" when (x"5"),
										"00110110" when (x"6"),
										"00110111" when (x"7"),
										"00111000" when (x"8"),
										"00111001" when (x"9"),
										"01000001" when (x"A"),
										"01000010" when (x"B"),
										"01000011" when (x"C"),
										"01000100" when (x"D"),
										"01000101" when (x"E"),
										"01000110" when (x"F"),
										"01111110" when others; -- tilde
----------------------------------------------------------------------

with Data_from_Fifo(15 downto 11)select
		eoe <= 
		       '1' when ("11001"), -- C8
				 '0' when others;

end Behavioral;

