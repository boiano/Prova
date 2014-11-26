----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:25:01 08/12/2011 
-- Design Name: 
-- Module Name:    Bit_rate_Tx - Behavioral 
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
--library UNISIM;
--use UNISIM.VComponents.all;

entity Bit_rate_Tx is
           Port ( clk 				: in  STD_LOGIC;
						rst 				: in  STD_LOGIC;
						start_tx			: in  STD_LOGIC;
						load_v 			: in  STD_LOGIC_VECTOR(15 downto 0);
						busy_tx				: out	 STD_LOGIC;
						cadence_tx			: out  STD_LOGIC);
end Bit_rate_Tx;

architecture Behavioral of Bit_rate_Tx is

signal reload_cnt_tx, clr_count_tx			: STD_LOGIC;
signal pclr_num_time_tx, clr_num_time_tx	: STD_LOGIC;
signal xenable_cnt_tx, xxenable_cnt_tx		: STD_LOGIC;
signal enable_cnt_tx, stop_cnt_tx			: STD_LOGIC;
signal num_time									: STD_LOGIC_VECTOR(3 downto 0);
signal count_tx									: STD_LOGIC_VECTOR(15 downto 0);

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

begin

clr_count_tx <= rst or not enable_cnt_tx;

time_counter: process (clk, clr_count_tx, enable_cnt_tx) 
begin
   if clr_count_tx='1' then 
      count_tx <= (others => '0');
   elsif (enable_cnt_tx ='1')then
		if (clk ='1' and clk'event) then
			if reload_cnt_tx ='1' then
				count_tx <= x"0000";
			else 
				count_tx <= count_tx + 1;
			end if;
		end if;
   end if;
end process time_counter;


----------------------------------------------- Ricarico Conteggio
reload: process (count_tx, load_v) 
begin
   if (count_tx = load_v - x"0001") then
		reload_cnt_tx	<= '1'; 
	else
		reload_cnt_tx	<= '0';
	end if;
end process reload;

--with num_time select	
--      end_count  <= 	'0' & half_time when ("0000"),
--							load_v 			when others;
--		
--half_time <= load_v(15 downto 1);
						
------------------------------------------------ Output

cadence_tx_count: process (clk, rst)
begin
	if(rst='1')then
		cadence_tx <= '0';
	else if (clk'event and clk ='1') then
		cadence_tx <= reload_cnt_tx;
		end if;
	end if;
end process cadence_tx_count;


------------------------------------------------ Conteggio Numero Occorrenze

occurences_count: process (clk, clr_num_time_tx)
begin
	if (clk'event and clk ='1') then
		if(clr_num_time_tx='1')then
			num_time <= x"0";
		else if (reload_cnt_tx ='1')then
					num_time <= num_time + 1;
			  end if;
		end if;
	end if;
end process occurences_count;


------------------------------------
num_time_proc: process (num_time) 
begin
   if (num_time = x"B") then
		pclr_num_time_tx <= '1';					----------- Occorrenze raggiunte
	else
		pclr_num_time_tx <= '0';
	end if;
end process num_time_proc;

clr_num_time_tx <= rst or pclr_num_time_tx;
stop_cnt_tx <= pclr_num_time_tx;

-------------------------------------
autotenuta: process (clk, rst)				----------- Start & Stop count
begin
	if (rst ='1')then
				xxenable_cnt_tx <= '0';
	else if(clk'event and clk ='1')then
				xxenable_cnt_tx <= xenable_cnt_tx;
		  end if;
	end if;
end process autotenuta;

xenable_cnt_tx <= start_tx or (xxenable_cnt_tx and not stop_cnt_tx);
enable_cnt_tx  <= start_tx or xxenable_cnt_tx;


busy_tx <= xxenable_cnt_tx;

end Behavioral;