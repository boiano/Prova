----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:50:25 06/19/2012 
-- Design Name: 
-- Module Name:    Modulo_EC_LAST - Behavioral 
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

entity Modulo_EC_LAST is
    GENERIC ( Num_Moduli : STD_LOGIC_VECTOR (3 downto 0) := X"5" );   -- Per il ritardo di PASS 
    Port (
           f150MHz 	: in  STD_LOGIC;
           Reset 		: in  STD_LOGIC;
	        Busy 		: in  STD_LOGIC;
			  HFull     : out STD_LOGIC; 
			-- IN 	
			  GLTRG	   	: in  	STD_LOGIC;
           EC_Fibra   	: in  	STD_LOGIC_VECTOR (11 downto 0); -- Inviato  alla fibra
			
           ECProposed 	: out  	STD_LOGIC_VECTOR (11 downto 0); 
			  EC_Valido    : out  	STD_LOGIC;
	   -- Deasy 		  
           REN 			: in  	STD_LOGIC;
           PASSo 			: out  	STD_LOGIC; --   
  --         WR_EN_out  : out  STD_LOGIC;
           Data_Out 	 : out  STD_LOGIC_VECTOR (15 downto 0)
			   );
end Modulo_EC_LAST;

architecture Behavioral of Modulo_EC_LAST is

-- ============================================================================
--    COMPONENTI
-- ============================================================================

 COMPONENT EC_FIFO
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
   -- full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    valid : OUT STD_LOGIC;
    prog_full : OUT STD_LOGIC 
  );
END COMPONENT;
-- Synplicity black box declaration
attribute syn_black_box : boolean;
attribute syn_black_box of EC_FIFO: component is true;


-- ===================================================
--  Costanti e SEGNALI
-- ===================================================
signal GLTRGr				: std_logic ;
signal GLTRGrr				: std_logic ;
signal GLTRGrrr			: std_logic ;
signal EC_WR_EN			: std_logic ;
signal intPASSo         : std_logic ;
--signal int_WR_EN_out    : std_logic ;
signal RD_EN            : std_logic ;
signal empty				: std_logic ;
signal valid				: std_logic ;
signal RENr, RENrr		: std_logic ;
signal WR_MUX 				: std_logic ;

signal Delay_PASS				: STD_LOGIC_VECTOR (3 downto 0);
signal Data_Out_FIFO       : STD_LOGIC_VECTOR (15 downto 0);
signal Din_FIFO 				: STD_LOGIC_VECTOR (15 downto 0);

constant Ty_EC          : STD_LOGIC_VECTOR (3 downto 0) := X"E" ;

-------------------------------------------------------
begin

-- ===============================================================
----------------------  INIZIO  ------------------------
-- ===============================================================

PASSo 		<= intPASSo ;
--WR_EN_out 	<= int_WR_EN_out;
ECProposed	<= Data_Out_FIFO(11 downto 0);
Data_Out    <= Data_Out_FIFO ;
Din_FIFO    <= Ty_EC & EC_Fibra;


--   ====================================================
--        Instanza Componenti
--   ====================================================

-----   FIFO del CANALE
FIFO_EC : EC_FIFO
  PORT MAP (
    rst 			=> Reset,
    wr_clk 		=> f150MHz,
    rd_clk 		=> f150MHz,
    din 			=> Din_FIFO  , -- Direttamente EC
    wr_en 		=> EC_WR_EN ,
    rd_en 		=> RD_EN,
    dout 		=> Data_Out_FIFO,
    --full 		=> open,
    empty 		=> empty,
    valid 		=> valid ,
    prog_full 	=> HFull
  );
----------------

-- Scrittura FIFO con SOLO EC senza EOE

--     WR_EC    EVENT COUNTER
process (Reset, f150MHz )
begin
if reset = '1' then   --   RESET

  GLTRGr				<= '0' ;
  GLTRGrr			<= '0' ;
  GLTRGrrr			<= '0' ;
  EC_WR_EN     	<= '0';	
  WR_MUX    		<= '0';
  
elsif  (f150MHz ='1' and f150MHz'Event) then -- _|- fronte
  GLTRGrrr <= GLTRGrr ; GLTRGrr <= GLTRGr ; GLTRGr <= GLTRG ; --  Per il detect del fronte di salita
  
					
    if GLTRGrrr = '0'  and  GLTRGrr = '1' THEN      -- E' arrivato un GLTRG  ------
					EC_WR_EN  <= '1';		  
		  else
		         EC_WR_EN  <= '0';			  
        end if;
		
end if;
end Process;		
------------------------------------------------------------------------------------------------	


--     RD_EC    Lettura della FIFO e DELAY per PASS
process (Reset, f150MHz )
begin
if reset = '1' then   --   RESET

  RENr			<= '0' ;
  Delay_PASS 	<= (others => '0');
  intPASSo     <= '0';  
  RD_EN     	<= '0';	
  EC_Valido   	<= '0';
 -- int_WR_EN_out <= '0';

elsif  (f150MHz ='1' and f150MHz'Event) then -- _|- fronte
 
		  RENr 	<= REN;
		  RENrr 	<= RENr;  

																									-- E' arrivato un REN  ------
--	 if (RENr = '0'  and  REN = '1')   and busy = '0' THEN   -- Segnale di WR in uscita alla daesy   
--					int_WR_EN_out     	<= '1';   -- Lo legge due volte EC + Trigger Pattern
--		else
--		         int_WR_EN_out     	<= '0';			  		
--         end if;
  
   if (RENr = '0'  and  REN = '1')   and busy = '0' THEN      -- Legge la FIFO
					RD_EN     	<= '1';
	elsif   empty = '0'  and   valid = '1'  and (Data_Out_FIFO (15 downto 12) /= Ty_EC)	then	-- Legge e Butta se non un EC
               RD_EN     	<= '1';	
		else
		         RD_EN     	<= '0';			  
				
         end if;
			
	if RENr = '1'  and  REN = '1' and (  Delay_PASS  <= Num_Moduli ) THEN      -- E' arrivato un REN  
	     
	       Delay_PASS <= Delay_PASS + 1 ;
	 elsif REN = '0' THEN
	               Delay_PASS <= (others => '0');
		 end if;
		 
	if RENr = '1' and REN = '1' and  (  Delay_PASS  > Num_Moduli )  then  
							intPASSo <= '1';
		else
		               intPASSo <= '0';
			end if;
	
	  
	  if empty = '0'  and   valid = '1'  and (Data_Out_FIFO (15 downto 12) = Ty_EC) then 
	             EC_Valido <= '1';
	   else
					  EC_Valido <= '0';
			end if;
			
	    
		 
	    
	  --  Mettere la generazione di EC_VALIDO ---------------------vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
							
							
end if;
end Process;		
------------------------------------------------------------------------------------------------	










 

end Behavioral;

