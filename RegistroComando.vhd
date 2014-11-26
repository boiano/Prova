----------------------------------------------------------------------------------
-- Company:     INFN
-- Engineer:   Alfonso Boiano
-- 
-- Create Date:    17:14:55 09/06/2012 
-- Design Name: 
-- Module Name:    RegistroComando - Behavioral 

----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;


entity RegistroComando is
    Port ( CLK48M 		: in  STD_LOGIC;
           nRESET 		: in  STD_LOGIC;
           --USB_FE 		: in  STD_LOGIC;
           EN_CMD 		: in  STD_LOGIC;
			  ERR				: in  STD_LOGIC;
			  BD_IN 			: in  STD_LOGIC_VECTOR (15 downto 0);
           I_OPC 			: out  STD_LOGIC_VECTOR (15 downto 0);
           II_ADDR 		: out  STD_LOGIC_VECTOR (15 downto 0);
           III_DATA 		: out  STD_LOGIC_VECTOR (15 downto 0));
end RegistroComando;

architecture Behavioral of RegistroComando is


------------- SEGNALI GENERALI -------------------------------

signal CONTA	 :	std_logic_vector(3 downto 0);	--

signal OPC 	 :	std_logic_vector(15 downto 0);	--
signal ADDR  :	std_logic_vector(15 downto 0);	--
signal DATA :	std_logic_vector(15 downto 0);	--




-------------------------------------------------------------

begin

-- MAIN PROCESSO   -------------------
process (CLK48M,nRESET)										
begin
  if nRESET ='0' THEN
		OPC  	<= X"0000";
		ADDR 	<= X"0000";
		DATA    <= X"0000";
		CONTA		<= X"0";
	
	
   elsif (CLK48M'EVENT and CLK48M = '1') then -- __ |---
   
	
	   ---    CONTATORE delle parole 
			if  EN_CMD = '1' and CONTA < X"4" then --  CONTA le Parole
				  CONTA		<= CONTA	+ 1;
			  elsif EN_CMD = '0'    then
               CONTA		<= X"0";
			  else
				CONTA		<= CONTA	;
				end if;
		-----
 ---  REGISTRI COMANDO
 --  I_OPC
			if EN_CMD = '1'    and CONTA = X"0" then  -- Memorizza
			   OPC <= BD_IN;	
			elsif ERR = '1'  then
			   OPC <=  X"F" &  OPC(11 downto 0); -- Error CODE
			--elsif EN_CMD = '0'  then
			 --  OPC <=   X"0000"; 							-- AZZERA	
			else 
		 		OPC <= OPC ;                      -- RIMANE
			end if ;
--			
 --  II_ADDR
			if EN_CMD = '1'    and CONTA = X"1" then  -- Memorizza
			  ADDR <= BD_IN;	
			--elsif EN_CMD = '0'  then
			--   ADDR <=   X"0000"; 							-- AZZERA	
			else 
		 		ADDR <= ADDR ;                      -- RIMANE
			end if ;
--	
 --  III_DATA
			if EN_CMD = '1'    and CONTA = X"2" then  -- Memorizza
			  DATA <= BD_IN;	
		--	elsif EN_CMD = '0'  then
		--	   DATA <=   X"0000"; 							-- AZZERA	
			else 
		 		DATA <= DATA ;                      -- RIMANE
			end if ;
--				
end if;
 end process;

----------   Assegna le uscite

I_OPC  		<=  OPC ;  
II_ADDR 	<=  ADDR ;
III_DATA 	<=  DATA ;

-----------------------------------------

end Behavioral;

