----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:16:51 08/12/2011 
-- Design Name: 
-- Module Name:    Bit_rate_Rx - Behavioral 
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

entity Bit_rate_Rx is
       Port ( 	clk 				: in  STD_LOGIC;
					rst 				: in  STD_LOGIC;
					start_rx			: in  STD_LOGIC;								
					measure_rate	: in  STD_LOGIC;
					load_v 			: in  STD_LOGIC_VECTOR(15 downto 0);
					busy_rx					: out  STD_LOGIC;
					cadence_rx 				: out  STD_LOGIC);
end Bit_rate_Rx;

architecture Behavioral of Bit_rate_Rx is

signal reload_cnt_rx, clr_count_rx			: STD_LOGIC;
signal pclr_num_time_rx, clr_num_time_rx	: STD_LOGIC;
signal xenable_cnt_rx, xxenable_cnt_rx		: STD_LOGIC;
signal enable_cnt_rx, stop_cnt_rx			: STD_LOGIC;
signal xreload_cnt_rx							: STD_LOGIC;
signal end_count									: STD_LOGIC_VECTOR(15 downto 0);
signal alf_time									: STD_LOGIC_VECTOR(14 downto 0);
signal num_time									: STD_LOGIC_VECTOR(3 downto 0);
signal count_rx									: STD_LOGIC_VECTOR(15 downto 0);

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

begin

clr_count_rx <= rst or not enable_cnt_rx;

time_counter: process (clk, clr_count_rx, enable_cnt_rx) 
begin
   if clr_count_rx='1' then 
      count_rx <= (others => '0');
   elsif (enable_cnt_rx ='1')then
		if (clk ='1' and clk'event) then
			if reload_cnt_rx ='1' then
				count_rx <= x"0000";
			else 
				count_rx <= count_rx + 1;
			end if;
		end if;
   end if;
end process time_counter;


----------------------------------------------- Ricarico Conteggio
reload: process (count_rx, end_count) 
begin
   if (count_rx = end_count - x"0001") then
		xreload_cnt_rx	<= '1'; 
	else
		xreload_cnt_rx	<= '0';
	end if;
end process reload;

reload_cnt_rx <= xreload_cnt_rx or measure_rate;

with num_time select	
      end_count  <= 	'0' & alf_time when ("0000"),
							load_v 			when others;
		
alf_time <= load_v(15 downto 1);
						
------------------------------------------------ Output

cadence_rx_count: process (clk, rst)
begin
	if(rst='1')then
		cadence_rx <= '0';
	else if (clk'event and clk ='1') then
		cadence_rx <= reload_cnt_rx;
		end if;
	end if;
end process cadence_rx_count;


------------------------------------------------ Conteggio Numero Occorrenze

occurences_count: process (clk, clr_num_time_rx)
begin
	if (clk'event and clk ='1') then
		if(clr_num_time_rx='1')then
			num_time <= x"0";
		else if (reload_cnt_rx ='1')then
					num_time <= num_time + 1;
			  end if;
		end if;
	end if;
end process occurences_count;


------------------------------------
num_time_proc: process (num_time) 
begin
   if (num_time = x"B") then
		pclr_num_time_rx <= '1';					----------- Occorrenze raggiunte
	else
		pclr_num_time_rx <= '0';
	end if;
end process num_time_proc;

clr_num_time_rx <= rst or pclr_num_time_rx;
stop_cnt_rx <= pclr_num_time_rx;

-------------------------------------
autotenuta: process (clk, rst)				----------- Start & Stop count
begin
	if (rst ='1')then
				xxenable_cnt_rx <= '0';
	elsif(clk'event and clk ='1')then
				xxenable_cnt_rx <= xenable_cnt_rx;
	end if;
end process autotenuta;

xenable_cnt_rx <= start_rx or (xxenable_cnt_rx and not stop_cnt_rx);
enable_cnt_rx  <= start_rx or xxenable_cnt_rx;
busy_rx <= xxenable_cnt_rx;


end Behavioral;