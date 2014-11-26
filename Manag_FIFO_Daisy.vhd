--
--   Per Test_Card
--		24/10/14

library IEEE;
library UNISIM;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use UNISIM.VComponents.all;

entity Manag_FIFO_Daisy is
    GENERIC ( MAX_T_Out : STD_LOGIC_VECTOR (15 downto 0) := X"FFFF");
					
    Port ( rd_clk : IN std_logic; -- ref CLK a 150MHz
			  wr_clk : IN std_logic; -- Recovered a 150MHz
           rst : in  STD_LOGIC;
  
	--   Daisy chain
				ECProposed 	: in  STD_LOGIC_VECTOR (11 downto 0);
				REN 			: in  STD_LOGIC;
				PASSO 		: out STD_LOGIC; 
				Busy 			: in  STD_LOGIC;
				Data_in 		: in  STD_LOGIC_VECTOR (15 downto 0);
				Data_Out 	: out STD_LOGIC_VECTOR (15 downto 0);				
				WR_EN_in 	: in  STD_LOGIC;
				WR_EN_out 	: out STD_LOGIC;				
				
	--  WR FIFO 
			  en_wrt_fifo	: in  STD_LOGIC;  -- Abilita la scrittura  dallo slow control 
			  almost_full  : out  STD_LOGIC;

	--   Dal GTX		  
           Data_to_FIFO : in  STD_LOGIC_VECTOR (15 downto 0);
           Kin 			: in  STD_LOGIC;
			  RX_ALLIN 		: in STD_LOGIC);
end Manag_FIFO_Daisy ;

architecture Behavioral of Manag_FIFO_Daisy is


 COMPONENT FIFO_CANALE
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    valid : OUT STD_LOGIC;
    prog_full : OUT STD_LOGIC 
  );
END COMPONENT;
-- Synplicity black box declaration
attribute syn_black_box : boolean;
attribute syn_black_box of FIFO_CANALE: component is true;

			
signal empty	 			: STD_LOGIC;
signal wr_en 				: STD_LOGIC;
signal xwr_en 				: STD_LOGIC;

signal RES_CONTA_BYTE 	:  STD_LOGIC_VECTOR(2 downto 0);
signal RES_CONTA_BYTEr 	:  STD_LOGIC_VECTOR(2 downto 0);
signal Timeout_Det 		:  STD_LOGIC_VECTOR(7 downto 0);
signal Det_fiber_OK 		: STD_LOGIC;
--
signal RD_EN        		: std_logic ;
signal DO_FIFO				: STD_LOGIC_VECTOR (15 downto 0);
signal full 				: std_logic ;
signal valid				: std_logic ;
signal prog_full			: std_logic ;
signal Counter  			: STD_LOGIC_VECTOR (15 downto 0);
signal TimeOut 			: std_logic ;
signal EC_Cmp_Ma			: std_logic ;
signal EC_Cmp_Mi        : std_logic ;
signal EC_Cmp_Eq        : std_logic ;
signal EC_Cmp_Next		: std_logic ;
--signal FlgTRASH			: std_logic ;
signal Wide_Time_Out    : std_logic ;
signal Monost_T_OUT     : STD_LOGIC_VECTOR (3 downto 0);
signal ECProposed_Next  : STD_LOGIC_VECTOR (11 downto 0);
signal OVF_EC        	: std_logic ;
signal OVF_Proposed     : std_logic ;
signal intHFull			: std_logic ;
signal intDOUT   			: STD_LOGIC_VECTOR (15 downto 0);
signal intWR_EN_OUT		: std_logic ;
signal intPASS          : std_logic ;
signal IntWrEn				: std_logic ; 

    --   X Macchina a  STATI 
  type cmds is (IDLE, RD_EC, TRASH, LE_EC, RD, WAITH, PASS );
signal state : cmds;

constant Ty_EC          : STD_LOGIC_VECTOR (3 downto 0) := X"E" ;
constant Ty_CRCB      : STD_LOGIC_VECTOR (3 downto 0) := X"D" ;
signal   nXWR_EN			: std_logic ; 


begin
 nXWR_EN <= not xwr_en	;
			                                                
-----   FIFO del CANALE
FIFO_BLOCCO : FIFO_CANALE
  PORT MAP (
    rst 			=> nXWR_EN , -- Resetta la FIFO se non abilitata   
    wr_clk 		=> wr_clk,  -- Recovered CLK 150MHz
    rd_clk 		=> rd_clk,	-- Ref  CLK 150MHz
    din 			=> Data_to_FIFO, 
    wr_en 		=>  wr_en		, 
    rd_en 		=> RD_EN,
    dout 		=> DO_FIFO,
    full 		=> full,
    empty 		=> empty,
    valid 		=> valid ,
    prog_full 	=> prog_full
  );
-------------------------------
------------------------------------

--	FIFO_nEmpty 	<=		(not empty_fifo) and  xwr_en and Serial_USB  ; 					
--	FIFO_nEmpty 	<=		(not empty_fifo) and  xwr_en ; 					
					
intHFull <= full or   prog_full;  
almost_full 	<= intHFull; -- and XWR_EN ;
---------------------------------
-----   SCRITTURA   -------------
---------------------------------

--    Processo combinatoriale per WREN della fifo
Comb_Proc : process ( xwr_en, Kin  , Data_to_FIFO )
begin
if  xwr_en = '1' and  Kin = '0' and  Data_to_FIFO /= X"8080"  then
											wr_en  <= '1' ;
				else
                                  wr_en  <= '0' ;
						end if;

end process ;
-----------------------------

--   Pre bloccare la scrittura se fibra sganciata 
process(wr_clk, rst)
 begin
	if rst = '1' then
		xwr_en 				<= '0';
		RES_CONTA_BYTE 	<= "110" ; -- Conta le LWord RICEVUTE
		RES_CONTA_BYTEr 	<= "101" ;
		Timeout_Det 		<= X"00" ;
		Det_fiber_OK 		<= '0' ;
		
	elsif rising_edge (wr_clk)then
	--  SYNC 
	   RES_CONTA_BYTEr <= RES_CONTA_BYTE ;
	   xwr_en <= en_wrt_fifo and Det_fiber_OK ;
		
		  --  Conta le parole tra i Kin 
		if Kin = '1' then   RES_CONTA_BYTE <= "000";
		elsif		RES_CONTA_BYTE < "101" THEN  	RES_CONTA_BYTE <= RES_CONTA_BYTE +1 ; --  CONTA le LWORD	
           else			                     RES_CONTA_BYTE <= "000" ;    -- 
      end if;
		
------- Blocca segnali se fibra non agganciata
  
  if Kin = '1' and RES_CONTA_BYTEr = "100"  then
                 if   Timeout_Det  < X"FF" then
					               Timeout_Det <= Timeout_Det +1 ;
										 Det_fiber_OK <= '0' ;
						else
						          Timeout_Det <= Timeout_Det ;
									 Det_fiber_OK <= '1' ;
							end if;

	elsif ( Kin = '1' and RES_CONTA_BYTEr /= "100" )  or ( Kin = '0' and RES_CONTA_BYTEr = "100") or  (RX_ALLIN = '0')
						then
	                         Timeout_Det <= X"00" ;
									 Det_fiber_OK <= '0' ; 
		end if ;
		
		
		
	end if;
end process;
-----------------------------------------------------------------------------------------------


---------------------------------------------
---------   Parte di lettura   --------------
---------------------------------------------

----------------------   MACCHINA a STATI ------------------

MSTATI : process (rst, rd_clk)
begin
  if rst ='1' then
  state 		<= IDLE ;
  Counter 	<= (others => '0');
  TimeOut   <= '0' ;
  EC_Cmp_Ma <= '0' ;
  EC_Cmp_Mi <= '0' ;
  EC_Cmp_Eq <= '0' ;
  EC_Cmp_Next <= '0' ;
  --FlgTRASH   <= '0' ;
  Wide_Time_Out <= '0';
  Monost_T_OUT <= (others => '0');
  ECProposed_Next <= (others => '0');

  elsif (rd_clk='1' and rd_clk'Event) then    --- ___|----  Fronte clk
  
    ECProposed_Next <= ECProposed + 1 ;  --  Calcola il Prossimo 
  
    
   if (state = RD_EC ) or (state = WAITH ) then --   CONTATORE
	   Counter <= 	 Counter +1 ;
	 else
	   Counter 	<= (others => '0');
		end if ;
------------------------		
	if Counter = MAX_T_Out then  -- TimeOut
	     TimeOut   <= '1' ;
	 else
	     TimeOut   <= '0' ;
		  end if ;
-------------------------
   if TimeOut = '1' and Monost_T_OUT = X"0" THEN
	      Monost_T_OUT <= X"A";
			Wide_Time_Out <= '1';
	 elsif  Monost_T_OUT > X"0" THEN
	      Monost_T_OUT <= Monost_T_OUT-1;
			Wide_Time_Out <= '1';
	else
			Wide_Time_Out <= '0';
	 end if;
-----------------------------------


                     --  FLG per capire se è sata buttata roba...  se si allora l'EOE dev'essere buttato

--   if ( state = IDLE ) then
--				FlgTRASH <= '0' ; -- reset FLAG
--	elsif  ( state = TRASH ) then
--	         FlgTRASH <= '1' ; --  Ho buttato Roba
--	end if;
-----------------------------	

   if (state = RD_EC ) then    --   Comparatore di EC
     if ( DO_FIFO(15 downto 12) = Ty_EC ) and ( OVF_EC & (DO_FIFO(11 downto 0)) < (OVF_Proposed &	ECProposed )) then
	      EC_Cmp_Ma 	<= '0' ;                   
			EC_Cmp_Mi 	<= '1' ; --   Minore
			EC_Cmp_Eq 	<= '0' ;
			EC_Cmp_Next <= '0' ;
	  elsif ( DO_FIFO(15 downto 12) = Ty_EC ) and 	(  DO_FIFO(11 downto 0) = 	ECProposed_Next ) then
	      EC_Cmp_Ma 	<= '0' ;
			EC_Cmp_Mi 	<= '0' ;
			EC_Cmp_Eq 	<= '0' ;
			EC_Cmp_Next <= '1' ;	 --  Next ( EC  = ECProposed + 1 )
	 	elsif ( DO_FIFO(15 downto 12) = Ty_EC ) and 	( OVF_EC & (DO_FIFO(11 downto 0)) > (OVF_Proposed &	ECProposed )) then
	      EC_Cmp_Ma 	<= '1' ;
			EC_Cmp_Mi 	<= '0' ;
			EC_Cmp_Eq 	<= '0' ;
			EC_Cmp_Next <= '0' ;  -- Vuol dire che è UGUALE oppure EOE
		elsif ( DO_FIFO(15 downto 12) = Ty_EC ) and 	( OVF_EC & (DO_FIFO(11 downto 0)) = (OVF_Proposed &	ECProposed )) then
			EC_Cmp_Ma 	<= '0' ;
			EC_Cmp_Mi 	<= '0' ;
			EC_Cmp_Eq 	<= '1' ;
			EC_Cmp_Next <= '0' ;
		end if ;
	end if;
-----------------------------	

-- STATI >  IDLE, RD_EC, TRASH, LE_EC, RD, WAITH, PASS	
 case state is
		 
	when IDLE => ----------------  IDLE
	             if xwr_en  = '0' and  REN = '1'       then  state <= PASS  ;
					  elsif  REN = '1' and xwr_en = '1'  then  state <= RD_EC ;
						else                   state <= IDLE  ;
					    end if;

	when RD_EC => ----------------  RD_EC
	              if ( empty = '0') and (valid ='1') and  (DO_FIFO(15 downto 12) = Ty_EC ) 
															then  	state <= LE_EC ; -- 
																										
					 elsif  ( empty = '0') and (valid ='1') and ( DO_FIFO(15 downto 12) /= Ty_EC )  
														then  	state <= TRASH;
						
					      elsif TimeOut = '1'   then    	state <= PASS;
						  
					           else                     	state <= RD_EC ;
						end if;								

	when TRASH => ----------------  TRASH
	              state <= RD_EC ;

	when LE_EC => ----------------  LE_EC
	             if  (EC_Cmp_Mi = '1') or ( EC_Cmp_Ma = '1' and intHFull = '1' ) then state <= TRASH;  -- Se minore
					 
					  elsif  EC_Cmp_Next = '1'  or 
					         ( EC_Cmp_Ma = '1' and intHFull = '0' )  then  state <= PASS  ;  -- Se maggio  di 1 or maggiore senza fifo HF
								
							else                    state <= RD ;
						        end if ;


	when RD => ----------------  RD
	           if ( DO_FIFO(15 downto 12) = Ty_CRCB ) 					then  state <= PASS ;
					 elsif ( empty = '1')   or ( busy  = '1' )							then	state <= WAITH ;
						else                						                              state <= RD ;
					end if;

	when PASS => ----------------  PASS
	              if  REN = '1'  then  state <= PASS ;
						else                state <= IDLE  ;
					    end if;

   when others => ----------------  WAITH
	               if ( empty = '0') and (valid ='1') and ( busy  = '0' ) then 	state <= RD ;
						   elsif TimeOut = '1'    and      	( busy  = '0' )	 then   	state <= PASS ; -- se buy il timeout non vale 
                       else																		state <= WAITH ;
							    end if;

   END CASE ;
	
  end if ;
 end process MSTATI;



--   Processo MUX Registrato
Registri : process (rst, rd_clk)
begin
  if rst ='1' then

  intDOUT 	     <= (others => '0');
  intWR_EN_OUT   <= '0' ;

  elsif (rd_clk='1' and rd_clk'Event) then 

		if intPASS = '0' then                   -- Senza PASS (interno)
	             intDOUT 		<= DO_FIFO ;
	             intWR_EN_OUT 	<= IntWrEn ;
					 
		else		 intDOUT 		<= Data_in ;		-- Se con PASS  
                intWR_EN_OUT 	<= WR_EN_in ;
			end if;

  end if ;
 end process Registri;
--------------------------------------------
-- Uscite 
 
 Data_Out  	<= intDOUT ;
 WR_EN_out 	<= intWR_EN_OUT ;
 
 RD_EN   	<= '1' WHEN  (state = TRASH) or (state = RD) ELSE '0' ;
 IntWrEn  	<= '1'  WHEN ((state = RD) and valid = '1' ) ELSE  '0';
 intPASS   	<= '1' WHEN  (state = PASS)  ELSE '0' ;
 PASSO 		<= intPASS;
 --
 
-- Gestione degli OVF per i comparatori --
--  ovf | EC |   <Comparatore> ovf |ECProposed|
--    0 0XX                       0 0XX
--    0 FXX                       1 0XX  -- Setta  il bit di OVF sul EC(OUT FIFO)
--    0 FXX                       0 FXX
--    1 0XX                       0 FXX  -- Setta il boto di OVF sul ECProposed

OVF_EC       <=  not DO_FIFO(11) and not DO_FIFO(10) and not DO_FIFO(9) and not DO_FIFO(8) and  ECProposed(11) and ECProposed(10) and ECProposed(9) and ECProposed(8);
OVF_Proposed <=  DO_FIFO(11) and DO_FIFO(10) and DO_FIFO(9) and DO_FIFO(8) and not  ECProposed(11) and not ECProposed(10) and not ECProposed(9) and not ECProposed(8);
----------------------------------------------------


end Behavioral;

