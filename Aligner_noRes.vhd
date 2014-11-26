----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:34:41 04/17/2009 
-- Design Name: 
-- Module Name:    Aligner - Behavioral 
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
                                     --   ENTITY  ------------
entity Aligner_noRes is
    Port ( clk 			: in  STD_LOGIC;
           rst 			: in  STD_LOGIC;
           DATAIN 		: in  STD_LOGIC_VECTOR (19 downto 0);
			  Tx_Sync_done : in  STD_LOGIC;
           Aligned 		: out  STD_LOGIC;
			  LockFailed 	: out STD_LOGIC; 
           RXSLIDE 		: out  STD_LOGIC );
end Aligner_noRes;
-------------------------------------------------------------
architecture Behavioral of Aligner_noRes is
                                       --    COMPONENTI   -------
component commadetector is
    generic ( pcomma : std_logic_vector(9 downto 0) := "0101111100";  -- K285p
	           mcomma : std_logic_vector(9 downto 0) := "1010000011"); --  K285m
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
			  datain : in  STD_LOGIC_VECTOR (19 downto 0);
           found : out  STD_LOGIC;
           bitoffset : out  STD_LOGIC_VECTOR (4 downto 0));
end component;


component pulsegenerator is
    Port ( clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           start : in  STD_LOGIC;
           nofpulses : in  STD_LOGIC_VECTOR (4 downto 0);
			  done : out std_logic;
           pulse_out : out  STD_LOGIC);
end component;
--------------------------------------------------------------------
                                     ---   SEGNALI   ---------------
signal found : std_logic;
signal pulsedone : std_logic;
signal nofpulses :  STD_LOGIC_VECTOR (4 downto 0);
signal int_lock_fail : std_logic;
signal Enable_pulse_gen : std_logic;
--signal Numeri_reali_di_impulsi : STD_LOGIC_VECTOR (4 downto 0);

constant K285p :  std_logic_vector (9 downto 0) := "0011111010";  
constant K285m :  std_logic_vector (9 downto 0) := "1100000101";  



signal r0Tx_Sync_done :  std_logic;
signal Assestato      :  std_logic;
signal Delay          : std_logic_vector(7 downto 0);
signal NumFallimenti  : std_logic_vector(21 downto 0);
signal Fall_OVF       :  std_logic;
constant Max_Fall_OVF :  std_logic_vector (21 downto 0) := "11" & X"FFFFF" ;  --

signal noZero   :  std_logic;

begin

---------------------------------------------------------------------


--lockfailed <= int_lock_fail;
lockfailed <= int_lock_fail ; 


Slider: pulsegenerator                      -- COMPONENTE  Pulsegen
PORT MAP(
		clock => clk,
		reset => rst ,
		start => Enable_pulse_gen, -- PRIMA era FOUND  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
		nofpulses => nofpulses,
		done => pulsedone,
		pulse_out => RxSlide
	);


inst_Commadetector: commadetector          --  COMPONENTE  COMMADET
GENERIC MAP (
      pcomma => K285p, -- K28.5
	   mcomma => K285m
	 ) 	
PORT MAP (
		clk => clk,
		rst => rst,
		datain => DATAIN,
		found => found,
		bitoffset =>  nofpulses
	);
	------------------------------------------------------------------------------------
	
Enable_pulse_gen <= found  and  Assestato and pulsedone and  noZero ;  -- Ebilita il generatore di pulse solo quando pari


-------------   Combinatoriale
noZEROproc : process(nofpulses ) -- Se non ZERO
begin
if nofpulses = "00000" THEN noZero <= '0' ;
     else                   noZero <= '1' ;
	    end if;
end process ; 	  






--                                                                  Da modificare se non si vuole Autoreset con i Dispari 
lockfail_proc: process(clk,rst) --  Per Autoreset 
begin
	if rst='1' then
		int_lock_fail  <= '0';
	elsif rising_edge(clk) then
	   if  Fall_OVF = '1'  THEN
	                int_lock_fail  <=  '1' ;
				else
				       int_lock_fail  <=  '0' ;
	            end if;
	end if;
end process;	
---------------------------

aligned_flop: process(clk,rst)  -- Allineato
begin
	if rst='1' then
		Aligned <= '0';
	elsif rising_edge(clk) then
		if found='1'  then
		   if nofpulses = "0000"  and Assestato = '1'  then
				Aligned <= '1';
			else
				Aligned <= '0';
			end if;
		end if;
	end if;
end process;


Monostabile_proc: process(clk,rst) -- Monostabile  OUTPUT >>  Assestato
begin
 if rst='1' then     -- RESET
       r0Tx_Sync_done 	<= '0' ;
	    Assestato     	<= '0' ;   
	    Delay     			<= (others => '0');  
       NumFallimenti 	<= (others => '0'); 	
       Fall_OVF		   <= '0';
	    NumFallimenti 	<= (others => '0'); 
		 
  elsif rising_edge(clk) then
	   r0Tx_Sync_done <=  Tx_Sync_done ;
		
		if r0Tx_Sync_done = '0'  THEN      -- Assestato
						Delay  		<= (others => '0');    
						Assestato   <= '0' ; 	 
        elsif 	Delay < X"FF"  THEN	
     		         Delay   <= Delay +1;
						Assestato   <= '0' ; 
			 else
				      Delay   <= Delay ;
	              Assestato   <= '1' ;
					
             end if; 
		  ---
		  
		if Assestato = '1'  THEN     --   Conta i FAIL restituisce  >>  Fall_OVF ( per 1 clk )
		       if Enable_pulse_gen = '1' Then
					                     NumFallimenti <= NumFallimenti +1 ;
												Fall_OVF <= '0' ;
					 elsif  NumFallimenti >= Max_Fall_OVF  Then
                                   	Fall_OVF <= '1' ;	
												NumFallimenti 	<= (others => '0'); 	
                  else				  
                                   NumFallimenti <= NumFallimenti  ;
											  Fall_OVF <= '0' ;
								end if ;
								
			  else
			          NumFallimenti 	<= (others => '0'); 
					    Fall_OVF <= '0' ;
						 
              end if;						 
					 										
				 
	end if;
end process;









end Behavioral;

