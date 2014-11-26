----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:48:34 08/15/2011 
-- Design Name: 
-- Module Name:    Measure_Serial_Bitrate - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
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

entity Measure_Serial_Bitrate is
    Port ( clk 				: in  STD_LOGIC;
           rst 				: in  STD_LOGIC;
			  Serial_Rx			: in  STD_LOGIC;
			  measure_rate		: out	 STD_LOGIC);
end Measure_Serial_Bitrate;

architecture Behavioral of Measure_Serial_Bitrate is

signal measured_rate, clr_measured_rate	:STD_LOGIC;
signal measure_end, pmeasure_end			 	:STD_LOGIC;

begin

measuring_rate:process (clk, clr_measured_rate)
	begin
		if(clr_measured_rate = '1')then
			measured_rate <= '0';
		else if(clk'event and clk = '1')then
					if (measure_end = '1')then
						measured_rate <= '1';
					end if;
				end if;
		end if;
end process measuring_rate;

clr_measured_rate <= rst ;

end_measuring_rate:process (clk, rst)
	begin
		if(rst = '1')then
			pmeasure_end <= '0';
		else if(clk'event and clk = '1')then
					if (measured_rate = '0')then
						pmeasure_end <= Serial_Rx;
					end if;
				end if;
		end if;
end process end_measuring_rate;

measure_end <= pmeasure_end and not Serial_Rx;
measure_rate <= measure_end;



end Behavioral;