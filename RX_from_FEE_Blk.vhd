----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:42:08 09/20/2011 
-- Design Name: 
-- Module Name:    RX_from_FEE_Blk - Behavioral 
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
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
library IEEE;




-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity RX_from_FEE_Blk is
    Port ( clk 				: in  STD_LOGIC; -- 150MHz recovered
           rst 				: in  STD_LOGIC;
           K 					: in  STD_LOGIC_VECTOR (1 downto 0);
			  ENABLE				: in  STD_LOGIC;
           Stream_Data 		: in  STD_LOGIC_VECTOR (15 downto 0);
			  SCCR_to_S2Tx			: out STD_LOGIC;
			  valid					: out STD_LOGIC;
			  GTT						: out STD_LOGIC; 
			  BMult					: out STD_LOGIC_VECTOR (4 downto 0)		-- Dura 3 CLK (1/2 25MHz)  
			  );
end RX_from_FEE_Blk;

architecture Behavioral of RX_from_FEE_Blk is

signal counter_data				:  STD_LOGIC_VECTOR(2 downto 0);
 
begin


----------------  Trattamento Dati nell'Heather  ------------------------
Heather: process(clk, rst)
 begin
	if(rst='1')then
		GTT				<= '0';
		SCCR_to_S2Tx	<= '0';
		BMult				<= "00000";
		counter_data <= "000";
		valid				<= '0';
	elsif(clk'event and clk='1')then
		if(k="10") and ENABLE = '1' then -- Se abilitato
			GTT				<= Stream_Data(7);
			SCCR_to_S2Tx	<= Stream_Data(6);
			BMult				<= Stream_Data(5 downto 1);
			valid				<= '1';
		elsif(k="10") and ENABLE = '0' then -- se non abilitato
			GTT				<= '0';
			SCCR_to_S2Tx	<= '1';
			BMult				<= "00000";
			
		elsif counter_data  = "010" THEN
			    valid			<= '0';
		end if;
		
		if (k="10") or counter_data = "101" then  counter_data <= "000";
		      else  counter_data <= counter_data + 1;
				end if;
		
	
	end if;
end process Heather;


end Behavioral;

