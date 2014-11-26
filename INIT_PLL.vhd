----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:04:19 10/31/2011 
-- Design Name: 
-- Module Name:    INIT_PLL - Behavioral 
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

entity INIT_PLL is
    Port ( CLK 		: in  STD_LOGIC;
           RESET 		: in  STD_LOGIC;
           FATTO 		: out  STD_LOGIC;
			  
			  SDO   	 	: out  STD_LOGIC;
           SCK   	 	: out  STD_LOGIC;
			  LE_1PLL   : out  STD_LOGIC;
			  LE_2PLL   : out  STD_LOGIC
			  );
end INIT_PLL;

architecture Behavioral of INIT_PLL is

----------------------------------------------------
--         COMPONENTI
-----------------------------------------------------

component SPI_out is
    Port ( Data_IN : in  STD_LOGIC_VECTOR (31 downto 0);
           CLK 	 : in  STD_LOGIC;
           RESET 	 : in  STD_LOGIC;
           SDO   	 : out  STD_LOGIC;
           SCK   	 : out  STD_LOGIC;
           SLE   	 : out  STD_LOGIC;
           Start   : in  STD_LOGIC;
           Busy    : out  STD_LOGIC);
end component;


----------------------------------------------------------
--				            SEGNALI
----------------------------------------------------------
 
-----------------------------------------------------------
SIGNAL Data_IN   		:std_logic_vector(31 downto 0); -- Data in 
SIGNAL Conta_PAROLE	:std_logic_vector(7 downto 0); --  Conta la sequenza
SIGNAL SLE           :std_logic; -- 
SIGNAL Start         :std_logic; -- 
SIGNAL Busy          :std_logic; -- 
SIGNAL mem_Busy      :std_logic; -- 

SIGNAL cSDO            :std_logic; --
Signal cSCK            :std_logic; --
       

Constant LMK_Reset     :std_logic_vector(31 downto 0) :=  X"80000000";  -- R0 RESET
                                                   -- PLL 5MHz to 25MHz
Constant LMK_R0_PLL1   :std_logic_vector(31 downto 0) :=  X"00010100";  -- R0 ON
Constant LMK_R1_PLL1   :std_logic_vector(31 downto 0) :=  X"00010101";  -- R1 ON
Constant LMK_R2_PLL1   :std_logic_vector(31 downto 0) :=  X"00010102";  -- R2 ON
Constant LMK_R3_PLL1   :std_logic_vector(31 downto 0) :=  X"00010103";  -- R3 ON
Constant LMK_R4_PLL1   :std_logic_vector(31 downto 0) :=  X"00000104";  -- R4 off
Constant LMK_R5_PLL1   :std_logic_vector(31 downto 0) :=  X"00000105";  -- R5 off
Constant LMK_R6_PLL1   :std_logic_vector(31 downto 0) :=  X"00000106";  -- R6 off
Constant LMK_R7_PLL1   :std_logic_vector(31 downto 0) :=  X"00000107";  -- R7 off
Constant LMK_R11_PLL1  :std_logic_vector(31 downto 0) :=  X"0082000B";  -- R11 (( 0082800B) Div4on )  ( 0082000B ) Div4 off )
Constant LMK_R14_PLL1  :std_logic_vector(31 downto 0) :=  X"2940010E";  -- R14  x 25MHz 
Constant LMK_R15_PLL1  :std_logic_vector(31 downto 0) :=  X"4000010F";  -- R15 Divisore N
                                                  -- PLL 25MHz to 150MHz
--Constant LMK_R0_PLL2   :std_logic_vector(31 downto 0) :=  X"00010100";  -- R0 ON 
  Constant LMK_R0_PLL2   :std_logic_vector(31 downto 0) :=  X"000501A0";  -- R0 ON + 1.5ns
Constant LMK_R1_PLL2   :std_logic_vector(31 downto 0) :=  X"00000101";  -- R1 off
Constant LMK_R2_PLL2   :std_logic_vector(31 downto 0) :=  X"00000102";  -- R2 off
Constant LMK_R3_PLL2   :std_logic_vector(31 downto 0) :=  X"00000103";  -- R3 off
Constant LMK_R4_PLL2   :std_logic_vector(31 downto 0) :=  X"00000104";  -- R4 off
Constant LMK_R5_PLL2   :std_logic_vector(31 downto 0) :=  X"00000105";  -- R5 off
Constant LMK_R6_PLL2   :std_logic_vector(31 downto 0) :=  X"00000106";  -- R6 off
Constant LMK_R7_PLL2   :std_logic_vector(31 downto 0) :=  X"00000107";  -- R7 off
Constant LMK_R11_PLL2  :std_logic_vector(31 downto 0) :=  X"0082000B";  -- R11
Constant LMK_R14_PLL2  :std_logic_vector(31 downto 0) :=  X"2940010E";  -- R14
Constant LMK_R15_PLL2  :std_logic_vector(31 downto 0) :=  X"4000060F";  -- R15 Divisore N


 
--------------------------------------------------------------
begin
----------------------------  Port MAP -----------------
u1: SPI_out port map (                        
									Data_IN		=> 	Data_IN,
									CLK 	   	=>    CLK,
									RESET 	   =>    RESET, 
									SDO   	   =>    cSDO,  
									SCK   	   =>    cSCK, 
									SLE   	   =>    SLE,  
									Start     	=>    Start,
									Busy      	=>    Busy );
									
	-- assegna le uscite								
		SDO   	   <=    cSDO ;							
		SCK   	   <=    cSCK ;
----------------------------------------------------------
--                      CODICE
----------------------------------------------------------
process (CLK, RESET)
begin

 if Reset ='1' then   ----------------  Condizioni dei RESET
	Start 			<=  '0' ;
	FATTO 	      <=  '0' ;
   mem_Busy	      <=  '0' ;
	Data_IN   		<=  (others => '0');
	Conta_PAROLE 	<=  (others => '0');


           ------------------------------------------------------------
			  
 elsif (CLK='1' and CLK'Event) then    --- ___|----  Fronte clk
      mem_Busy <= Busy;
  
case Conta_PAROLE is
 --                  USCITA              START                                -fine di busy                       Avanza                              Stai
 when X"00" => Data_IN <= LMK_Reset  ; Start <= not mem_Busy and not Busy; if mem_Busy = '1' and  Busy = '0' Then Conta_PAROLE <= Conta_PAROLE +1;  else Conta_PAROLE <= Conta_PAROLE ; end if;
 when X"01" => Data_IN <= LMK_R0_PLL1; Start <= not mem_Busy and not Busy; if mem_Busy = '1' and  Busy = '0' Then Conta_PAROLE <= Conta_PAROLE +1;  else Conta_PAROLE <= Conta_PAROLE ; end if;
 when X"02" => Data_IN <= LMK_R1_PLL1; Start <= not mem_Busy and not Busy; if mem_Busy = '1' and  Busy = '0' Then Conta_PAROLE <= Conta_PAROLE +1;  else Conta_PAROLE <= Conta_PAROLE ; end if;
 when X"03" => Data_IN <= LMK_R2_PLL1; Start <= not mem_Busy and not Busy; if mem_Busy = '1' and  Busy = '0' Then Conta_PAROLE <= Conta_PAROLE +1;  else Conta_PAROLE <= Conta_PAROLE ; end if; 
 when X"04" => Data_IN <= LMK_R3_PLL1; Start <= not mem_Busy and not Busy; if mem_Busy = '1' and  Busy = '0' Then Conta_PAROLE <= Conta_PAROLE +1;  else Conta_PAROLE <= Conta_PAROLE ; end if;
 when X"05" => Data_IN <= LMK_R4_PLL1; Start <= not mem_Busy and not Busy; if mem_Busy = '1' and  Busy = '0' Then Conta_PAROLE <= Conta_PAROLE +1;  else Conta_PAROLE <= Conta_PAROLE ; end if;
 when X"06" => Data_IN <= LMK_R5_PLL1; Start <= not mem_Busy and not Busy; if mem_Busy = '1' and  Busy = '0' Then Conta_PAROLE <= Conta_PAROLE +1;  else Conta_PAROLE <= Conta_PAROLE ; end if;
 when X"07" => Data_IN <= LMK_R6_PLL1; Start <= not mem_Busy and not Busy; if mem_Busy = '1' and  Busy = '0' Then Conta_PAROLE <= Conta_PAROLE +1;  else Conta_PAROLE <= Conta_PAROLE ; end if;
 when X"08" => Data_IN <= LMK_R7_PLL1; Start <= not mem_Busy and not Busy; if mem_Busy = '1' and  Busy = '0' Then Conta_PAROLE <= Conta_PAROLE +1;  else Conta_PAROLE <= Conta_PAROLE ; end if;
 when X"09" => Data_IN <= LMK_R11_PLL1; Start <= not mem_Busy and not Busy; if mem_Busy = '1' and  Busy = '0' Then Conta_PAROLE <= Conta_PAROLE +1;  else Conta_PAROLE <= Conta_PAROLE ; end if;
 when X"0A" => Data_IN <= LMK_R14_PLL1; Start <= not mem_Busy and not Busy; if mem_Busy = '1' and  Busy = '0' Then Conta_PAROLE <= Conta_PAROLE +1;  else Conta_PAROLE <= Conta_PAROLE ; end if;
 when X"0B" => Data_IN <= LMK_R15_PLL1; Start <= not mem_Busy and not Busy; if mem_Busy = '1' and  Busy = '0' Then Conta_PAROLE <= Conta_PAROLE +1;  else Conta_PAROLE <= Conta_PAROLE ; end if;
 
 when X"0C" => Data_IN <= LMK_R0_PLL2; Start <= not mem_Busy and not Busy; if mem_Busy = '1' and  Busy = '0' Then Conta_PAROLE <= Conta_PAROLE +1;  else Conta_PAROLE <= Conta_PAROLE ; end if;
 when X"0D" => Data_IN <= LMK_R1_PLL2; Start <= not mem_Busy and not Busy; if mem_Busy = '1' and  Busy = '0' Then Conta_PAROLE <= Conta_PAROLE +1;  else Conta_PAROLE <= Conta_PAROLE ; end if;
 when X"0E" => Data_IN <= LMK_R2_PLL2; Start <= not mem_Busy and not Busy; if mem_Busy = '1' and  Busy = '0' Then Conta_PAROLE <= Conta_PAROLE +1;  else Conta_PAROLE <= Conta_PAROLE ; end if; 
 when X"0F" => Data_IN <= LMK_R3_PLL2; Start <= not mem_Busy and not Busy; if mem_Busy = '1' and  Busy = '0' Then Conta_PAROLE <= Conta_PAROLE +1;  else Conta_PAROLE <= Conta_PAROLE ; end if;
 when X"10" => Data_IN <= LMK_R4_PLL2; Start <= not mem_Busy and not Busy; if mem_Busy = '1' and  Busy = '0' Then Conta_PAROLE <= Conta_PAROLE +1;  else Conta_PAROLE <= Conta_PAROLE ; end if;
 when X"11" => Data_IN <= LMK_R5_PLL2; Start <= not mem_Busy and not Busy; if mem_Busy = '1' and  Busy = '0' Then Conta_PAROLE <= Conta_PAROLE +1;  else Conta_PAROLE <= Conta_PAROLE ; end if;
 when X"12" => Data_IN <= LMK_R6_PLL2; Start <= not mem_Busy and not Busy; if mem_Busy = '1' and  Busy = '0' Then Conta_PAROLE <= Conta_PAROLE +1;  else Conta_PAROLE <= Conta_PAROLE ; end if;
 when X"13" => Data_IN <= LMK_R7_PLL2; Start <= not mem_Busy and not Busy; if mem_Busy = '1' and  Busy = '0' Then Conta_PAROLE <= Conta_PAROLE +1;  else Conta_PAROLE <= Conta_PAROLE ; end if;
 when X"14" => Data_IN <= LMK_R11_PLL2; Start <= not mem_Busy and not Busy; if mem_Busy = '1' and  Busy = '0' Then Conta_PAROLE <= Conta_PAROLE +1;  else Conta_PAROLE <= Conta_PAROLE ; end if;
 when X"15" => Data_IN <= LMK_R14_PLL2; Start <= not mem_Busy and not Busy; if mem_Busy = '1' and  Busy = '0' Then Conta_PAROLE <= Conta_PAROLE +1;  else Conta_PAROLE <= Conta_PAROLE ; end if;
 when X"16" => Data_IN <= LMK_R15_PLL2; Start <= not mem_Busy and not Busy; if mem_Busy = '1' and  Busy = '0' Then Conta_PAROLE <= Conta_PAROLE +1;  else Conta_PAROLE <= Conta_PAROLE ; end if;
 
 when others =>  Data_IN <= Data_IN;  Start <= '0' ; 		Conta_PAROLE <= Conta_PAROLE ;	FATTO    <=  '1' ;				
		
end case;

  
end if; 
end process;
-----------------------------------------
-- Per gli SLE della SPI
process (Conta_PAROLE , SLE   )
begin
if Conta_PAROLE = X"00"  then 
   LE_1PLL   <= SLE;
	LE_2PLL   <= SLE;
elsif Conta_PAROLE <= X"0B" and Conta_PAROLE > X"00" then 
   LE_1PLL   <= SLE;
	LE_2PLL   <= '1';
	else
   LE_1PLL   <= '1';
	LE_2PLL   <= SLE;
end if;
end process;

end Behavioral;



