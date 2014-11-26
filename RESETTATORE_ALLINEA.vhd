----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:04:39 02/11/2011 
-- Design Name: 
-- Module Name:    PROVA_RESETTATORE_ALLINEA - Behavioral 
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


use ieee.numeric_std.all;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity RESETTATORE_ALLINEA is
    Port ( CLK_TX 		: in  STD_LOGIC;
	        CLK_RX       : in  STD_LOGIC;
           RST 			: in  STD_LOGIC;
           FAIL			: in  STD_LOGIC; -- Start auto reset
		TX_SYNC_DONE_in   : in  STD_LOGIC;
			  Align_OFF 	: out  STD_LOGIC;
           OUT_RES   	: out  STD_LOGIC);
end RESETTATORE_ALLINEA;

architecture RTL of RESETTATORE_ALLINEA is
 -------------------------------------------------------------------------------------

signal FORM_Fail_vet       :std_logic_vector(3 downto 0);
signal FORM_Fail_OUT       :STD_LOGIC;


signal Align_Fail_1r       :STD_LOGIC;
signal Align_Fail_2r       :STD_LOGIC;
signal Wire_RX_LockFailed  :STD_LOGIC;
signal Align_Monostabile   : std_logic_vector(15 downto 0);

constant Max_OVF :  std_logic_vector (15 downto 0) := X"00ff" ;  -- 

----------------------------------------------------------------------------------------

begin
--------------------------------------------------------------------------------------
    OUT_RES <= Wire_RX_LockFailed;


-------------------    ALFO    ---------------  RESET Allineatore Monostabile  ---------

  process( CLK_RX , RST )                               -- CLK DOMANI RX
     begin
         if (RST = '1') then
           FORM_Fail_vet    <= "0000";
		     FORM_Fail_OUT    <= '0';

		   elsif rising_edge(CLK_RX) then  -- _|^
			
			   if  FAIL = '1'    then
			       FORM_Fail_vet    <= "1111" ;
					 FORM_Fail_OUT    <= '1';
					 
				elsif  FORM_Fail_vet = "0000" then
				     FORM_Fail_vet <= FORM_Fail_vet;
					  FORM_Fail_OUT    <= '0';
			  
			   else 
				      FORM_Fail_vet <= FORM_Fail_vet - 1 ;
				      FORM_Fail_OUT    <= '1';
				end if;
		end if;
end process;
	---------------------------------------------------------------------------------------
	
	
	process( CLK_TX , RST )                             -- CLK DOMANI TX
    begin
        if (RST = '1') then
 
				Wire_RX_LockFailed <= '0';  -- Segnale dopo il monostabile Quello da usare 
				Align_OFF          <= '0' ; -- Blocca l'allineatore
				Align_Fail_1r      <= '0';  -- FF 1 di sincronizzaz x cambio dominio
				Align_Fail_2r      <= '0';  -- FF 2 di sincronizzaz x cambio dominio
				Align_Monostabile  <= Max_OVF ;  --  MONOSTABILE
				
       elsif rising_edge(CLK_TX) then  -- _|^
		  
            Align_Fail_1r      <=     FORM_Fail_OUT;  -- Filtro x sync
            Align_Fail_2r      <=     Align_Fail_1r;  -- Filtro x sync
				
				
				if Align_Fail_2r = '1' and  Align_Monostabile  = Max_OVF  and  TX_SYNC_DONE_in  ='1' then
				     Align_Monostabile  <= X"0000";   -- all'arrivi di un fail
				else
				                ----    Conta x Monostabile 
				     if  Align_Monostabile = Max_OVF then
								Align_Monostabile <= Align_Monostabile;  -- Cont Bloccato
								 Align_OFF <= '0' ;
				     else	Align_Monostabile  <= Align_Monostabile + 1  ;   -- start monostabile
					         Align_OFF <= '1' ;
					  end if;  
				end if;
				
	---------------------                      RESET _ del GTX   ------------
	        if  Align_Monostabile < X"000F" then
			          Wire_RX_LockFailed <= '1' ;
				else   Wire_RX_LockFailed <= '0' ;
			   end if;
		 

        end if;
    end process;
----------------------------------------------------------------------------------------------



end RTL;

