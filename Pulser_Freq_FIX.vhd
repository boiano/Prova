----------------------------------------------------------------------------------
-- Company:    INFN
-- Engineer:    Alfonso Boiano
-- 
-- Create Date:    16:01:46 09/13/2012 
-- Design Name: 
-- Module Name:    Pulser_Freq_FIX - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description:   REF CLK 25MHz  Out pulse un clk durata  periodo di     2621uS * "Tmax"
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
library UNISIM;
use UNISIM.VComponents.all;


entity Pulser_Freq_FIX is
    Port ( REF_CLK 	: in  STD_LOGIC;  -- 25 MHz
           RESET 		: in  STD_LOGIC;
           EN 			: in  STD_LOGIC;
			  Tmax      : in STD_LOGIC_VECTOR (11 downto 0) ;  -- Tempo Monostabile (( step 2621 uS  )) 7FF = 5,4 Sec
           Puls_OUT 	: out  STD_LOGIC);
			  
end Pulser_Freq_FIX;

architecture Behavioral of Pulser_Freq_FIX is

signal CONTA 			: STD_LOGIC_VECTOR(27 downto 0) ;
signal int_Puls_OUT	: STD_LOGIC;
signal Val_MAX			: STD_LOGIC_VECTOR(27 downto 0) ;
signal r_EN				: STD_LOGIC;


begin
--------------

--   Assegnazioni

Val_MAX		<= Tmax & X"FFFF" ;
Puls_OUT		<= int_Puls_OUT;


-------  STATE MACHINE --------------------------
Status_Update: process (REF_CLK , RESET)
begin
	if RESET = '1' then 
		CONTA 			<= (others => '0');
		int_Puls_OUT	<= '0';
	   r_EN				<= '0';
		
	elsif rising_edge(REF_CLK) then  --  __|--
	
		r_EN <= EN ;

		if (CONTA >= Val_MAX) or r_EN = '0' then 
						CONTA <= X"0000000" ;
		else        CONTA <= CONTA + 1 ;
			end if;
			
		if CONTA >= Val_MAX-1  then
							int_Puls_OUT <= '1' ;
			else 			int_Puls_OUT <= '0' ;
			   end if;

   end if;
end process;


end Behavioral;

