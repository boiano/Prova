----------------------------------------------------------------------------------
-- Company:  INFN
-- Engineer: 
-- 
-- Create Date:    20:31:12 10/28/2011 
-- Design Name: 
-- Module Name:    SPI_out - Behavioral 
-- Project Name:    Invia via SPI dati


----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SPI_out is
    Port ( Data_IN : in  STD_LOGIC_VECTOR (31 downto 0);
           CLK : in  STD_LOGIC;
           RESET : in  STD_LOGIC;
           SDO   : out  STD_LOGIC;
           SCK   : out  STD_LOGIC;
           SLE   : out  STD_LOGIC;
           Start : in  STD_LOGIC;
           Busy  : out  STD_LOGIC);
end SPI_out;

architecture Behavioral of SPI_out is

--===================================================================================
-- COSTANTI & SEGNALI


signal CLKDivisore :				std_logic_vector (7 downto 0)  ; -- Contatore Divisore
constant Valore_Divisore :    std_logic_vector ( 7 downto 0):=  X"12";  -- Valore del divisore

signal ISLE      :            std_logic := '1';   -- SLE 
signal ISCK       :           std_logic;   -- SCK 
signal ISDO       :           std_logic ;   -- SDO
signal Mem_start :            std_logic ;   -- Memorizza lo start == busy
signal Reg_Shift :			   std_logic_vector (31 downto 0)  ; -- Registro di Shift 
signal MEM_Num_bit :          std_logic_vector (5 downto 0)  ; -- Conta i bit inviati


----------------------------------------------------------------------------------	


begin
----------------------------------------------------------------------------------

process (CLK, RESET)
begin

 if Reset ='1' then   ----------------  Condizioni dei RESET
	ISCK 			<=  '0' ;
	ISLE 			<=  '1' ;
	Mem_start 	<=	 '0' ;
	
	Reg_Shift   <=  (others => '0');
	MEM_Num_bit <=  (others => '0');
	CLKDivisore <=  (others => '0');

           ------------------------------------------------------------
			  
 elsif (CLK='1' and CLK'Event) then    --- ___|----  Fronte clk
  
		if  (CLKDivisore <= Valore_Divisore) and  Mem_start = '1'  then  ---------  Divisore  (( parte con lo start ))
	                 CLKDivisore <= CLKDivisore + 1 ;
		else 			  CLKDivisore <= (others => '0');
		end if; ----------------------------------------------------


      if Start = '1' and  Mem_start = '0' then --  	Fronte dello Start
		         Mem_start <= '1';  
               Reg_Shift <=  Data_IN ;     -- Carica il registro
					ISLE <= '1';
					ISCK  <= '0';
					MEM_Num_bit <= (others => '0');
					
		 elsif	(Mem_start = '1') and ISLE = '1'  and CLKDivisore = Valore_Divisore  then --Aspetta per mettere SLE
		                  ISLE <= '0';
					
      elsif	(Mem_start = '1') and ISLE = '0' then --and Start = '1'  then
             if 	CLKDivisore =   '0' & Valore_Divisore (7 downto 1) then  -- Dovisore mezzi 
				            ISCK  <= '1';
							
								MEM_Num_bit <= MEM_Num_bit+1 ;
								Reg_Shift <= Reg_Shift ;
				  elsif   CLKDivisore = Valore_Divisore then 
								ISCK  <= '0';	
                        Reg_Shift <=  Reg_Shift (30 downto 0) & '0'  ;	 -- shifta
								
								if MEM_Num_bit = X"20" then   -- Controlla la fine 
								         Mem_start <= '0'; 
											ISLE <= '1';
									else   	Mem_start <= Mem_start ;
												ISLE 			<=  ISLE ;
                              end if;
					end if;
		
		else    ISLE 			<= '1' ;
		        Reg_Shift <= Reg_Shift ;
		    
      end if;
  
 end if; 
end process;

------   Assegna l'uscita 
ISDO 			<=  Reg_Shift(31) ;
busy        <=   Mem_start ;
SLE         <=  ISLE ;
SCK         <=  ISCK;

SDO   <= ISDO ;

end Behavioral;

