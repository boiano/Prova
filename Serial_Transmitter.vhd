----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    02:57:30 08/29/2011 
-- Design Name: 
-- Module Name:    Serial_Transmitter - Behavioral 
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

entity Serial_Transmitter is
    Port ( clk 					: in  STD_LOGIC;
           rst 					: in  STD_LOGIC;
           start_tx 				: in  STD_LOGIC;
			  cadence_tx			: in  STD_LOGIC;
           trasmitting_word 	: in  STD_LOGIC_VECTOR (7 downto 0);
           Serial_Tx 				: out  STD_LOGIC);
end Serial_Transmitter;

architecture Behavioral of Serial_Transmitter is

signal Shift_reg_Tx	:STD_LOGIC_VECTOR (10 downto 0);
signal swapped_datain	:STD_LOGIC_VECTOR (7 downto 0);

begin

swapgen:  for i in 0 to 7 generate
begin
         swapped_datain(i) <=  trasmitting_word(7-i);  -- Inverte
end generate;


load_and_sh4Tx :process(clk, rst)
	begin
		if(rst = '1')then
			Shift_reg_Tx <=(others=>'0');
		else if(clk'event and clk='1')then
					if(start_tx='1')then
						Shift_reg_Tx(10) 	<= '1';
						
						Shift_reg_Tx(9 downto 2) <=  not swapped_datain;
						Shift_reg_Tx(1)	<= '0';
						Shift_reg_Tx(0)	<= '0';
					else if(cadence_tx='1')then
								for i in 1 to 10 loop
									Shift_reg_Tx(i) <= Shift_reg_Tx(i-1);
								end loop;		
						   end if;
					end if;
				end if;
		end if;
end process load_and_sh4Tx;

Serial_Tx <= Shift_reg_Tx(10);				
					
end Behavioral;

