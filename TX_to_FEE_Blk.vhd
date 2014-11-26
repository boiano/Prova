----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:18:27 09/27/2011 
-- Design Name: 
-- Module Name:    TX_to_FEE_Blk - Behavioral 
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
library UNISIM;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use UNISIM.VComponents.all;

entity TX_to_FEE_Blk is
    Port ( 	clk 				: in  STD_LOGIC;  -- 150MHz
				CLK25MHz       : in  STD_LOGIC;
				rst 				: in  STD_LOGIC;  -- RESET
				rst_ec_fS		: in  STD_LOGIC;  -- RESET  Event counter
				Glb_Trg 			: in  STD_LOGIC;  --  > GLTRG 
				SCCT_from_S2Rx	: in  STD_LOGIC;  --  > slow controll Seriale		  
				Reset_bc_fS		: in  STD_LOGIC;  --  >  RESER Block CARD
				ACQ_BUSY			: in  STD_LOGIC;  --  >  Blocca il trasferimento dei dati
				PULSER			: in  STD_LOGIC;  --  >  Inpulsatore
				Tx_is_ready		: in  STD_LOGIC;	-- Tile0_PLLLKDET_OUT GTX pronto a trasmettere
				Trg_Pattern		: in   STD_LOGIC_VECTOR (11 downto 0);
				EC					: out  STD_LOGIC_VECTOR (11 downto 0);
				K_Tx				: out  STD_LOGIC_VECTOR (1 downto 0);
				Stream_Tx 		: out  STD_LOGIC_VECTOR (15 downto 0);
				Acc_TRG			: out  STD_LOGIC ;
				Freq_1M5625HZ 	: out  STD_LOGIC );	-- Rif Esterno Fibra
			  
end TX_to_FEE_Blk;

architecture Behavioral of TX_to_FEE_Blk is
------------------------------------------
--     SEGNALI
------------------------------------------
signal event_counter 	: STD_LOGIC_VECTOR (11 downto 0);
signal Reset_Event_cnt	: STD_LOGIC;
signal GTTAG_cnt			: STD_LOGIC_VECTOR (14 downto 0);
signal TTSync				: STD_LOGIC;
signal xreset_bc, reset_bc 	: STD_LOGIC;
signal xSCCT, SCCT				: STD_LOGIC;
signal pEn_Tx, En_Tx				: STD_LOGIC;
signal cnt_part_of_frame		: STD_LOGIC_VECTOR (2 downto 0);

type Type_of_word is (idle, heather, Event_cntr , Trg_ptrn);
signal State	: Type_of_word := idle;

signal selector 					: STD_LOGIC_VECTOR (3 downto 0);
signal Accepted_Trg, Busy_Trg	: STD_LOGIC;
signal Counter_busy				: STD_LOGIC_VECTOR (7 downto 0);
signal r_send_trg, send_trg, flag_Trg, clr_flag_trg	: STD_LOGIC;
signal R_CLK25MHz    : STD_LOGIC; 
signal R2_CLK25MHz   : STD_LOGIC; 
signal R3_CLK25MHz   : STD_LOGIC; 
signal S_ACQ_BUSY		: STD_LOGIC;  
signal S_Pulser		: STD_LOGIC; 


--Constant K28_5          :STD_LOGIC_VECTOR (7 downto 0) := X"1A";   -- ????? Strano non funziona 

constant K28_5 :  std_logic_vector (7 downto 0) := "10111100";   -- X"bc"  - Per Trasmettere il K 28.5 di sincronizzazione


--   Attributi per mantenere i nomi in  CHIP Scope
 	attribute keep : string;
   attribute keep of  send_trg		: signal is "true";
	attribute keep of  flag_Trg		: signal is "true";
	attribute keep of  r_send_trg		: signal is "true";



begin


------------- Sincro Dati da Seriale con CLK della sez di TX ----- > SCCT , Reset_bc
sync_clk_Tx: process(clk, rst)
begin
	if (rst='1')then
		xSCCT <= '0';
		SCCT  <= '0';	
		reset_bc  <= '0';
		xreset_bc <= '0';		
	elsif(clk'event and clk ='1')then
		xSCCT <= SCCT_from_S2Rx;
		SCCT  <= xSCCT;
		reset_bc  <= xreset_bc;
		xreset_bc <= Reset_bc_fS;
	end if;
end process sync_clk_Tx;

------------Sincro  En_Tx     alla Trasmissione --------------------------
en_Tx_proc: process(clk, rst)
begin
	if (rst='1')then
		pEn_Tx <= '0';
		En_Tx  <= '0';
	elsif (clk'event and clk='1')then
		pEn_Tx <= Tx_is_ready;
		En_Tx  <= pEn_Tx;
	end if;
end process en_Tx_proc;

----------------  Riconoscimento parti dello Stream --------------------
count_data_Tx: process(clk, rst)
begin
	if(rst='1')then
		cnt_part_of_frame <= "000";
		S_ACQ_BUSY			<= '0';
		S_PULSER				<= '0';
		R_CLK25MHz 			<= '0';
		R2_CLK25MHz 		<= '0';
		R3_CLK25MHz 		<= '0';
		
	elsif(clk'event and clk='1')then
	  R3_CLK25MHz <= R2_CLK25MHz ; R2_CLK25MHz <= R_CLK25MHz ; R_CLK25MHz <= CLK25MHz ;
	  S_ACQ_BUSY <= ACQ_BUSY;	
	  S_PULSER	 <= PULSER ;		
	
		if  R3_CLK25MHz = '0' and R2_CLK25MHz = '1'  then  -- Fronte di salita del 25MHz
			         cnt_part_of_frame <= "000";
		else     cnt_part_of_frame <= cnt_part_of_frame + 1;
		end if;	                        
		
	end if;
end process count_data_Tx;



----------------------------
------------------ MULTIPLEXER DI TRASMISSIONE -----------------------

selector <= En_Tx & cnt_part_of_frame;

with selector select
	State <= heather 		when ("1000"),
				Event_cntr 	when ("1001"),
				Trg_ptrn		when ("1010"),			
				idle			when others;
----------------------------

mux: process (state, send_trg, SCCT, TTSync, reset_bc, event_counter, Trg_Pattern, S_ACQ_BUSY, S_PULSER)
begin
 case state is
	-----------------------------------

	-----------------------------------
	when heather =>
		Stream_Tx(15 downto 8) 	<= K28_5 ;
		Stream_Tx(7)  			 	<= send_trg; 
		Stream_Tx(6)  			 	<= SCCT;
		Stream_Tx(5) 			 	<= TTSync;
		Stream_Tx(4) 			 	<= Reset_bc;
		Stream_Tx(3) 			 	<= S_ACQ_BUSY;
		Stream_Tx(2) 			 	<= S_PULSER;
		Stream_Tx(1 downto 0) 	<= (others => '0');
		K_Tx		 <= "10";
	-----------------------------------
	when Event_cntr =>
		Stream_Tx(15 downto 4) 	<= Event_counter;
		Stream_Tx(3 downto 0)	<= (others => '0');
	   K_Tx		 <= "00";
	-----------------------------------
	when Trg_ptrn =>
		Stream_Tx(15 downto 4) 	<= Trg_Pattern;
		Stream_Tx(3 downto 0)	<= (others => '0');
		K_Tx		 <= "00";
	-----------------------------------
	when others => 
		Stream_Tx <= (others => '0');	
		K_Tx		 <= "00";
 end case;
end process mux;


----------------  Busy_TRG    c.ca 0.85u sec ------------------
Busy_for_Trg: process (clk,rst)								---- ~0,8533 uSec @150MHz clk ----
	begin
		if rst = '1' then 				
			Counter_busy <= x"00";
			
		elsif (clk'event and clk = '1') then
		
			if(Accepted_Trg ='1')then
				Counter_busy <= x"80";
			elsif(Counter_busy /=  x"00") then
				Counter_busy <= Counter_busy - 1;
			end if;
		end if;
end process Busy_for_Trg;										

Busy_Trg_proc :process(clk)
begin
   if (clk'event and clk ='1') then   
      if (Counter_busy =  x"00") then 
         Busy_Trg <= '0';
      else 
         Busy_Trg <= '1';
      end if;
   end if; 
end process Busy_Trg_proc; 

Accepted_Trg <= Glb_Trg and not Busy_Trg;

----------------------------------------------
ready2Send_Trg: process(clk, clr_flag_trg)
 begin
	if(clk'event and clk='1')then
		if(clr_flag_trg='1')then
			flag_Trg <='0';
		elsif(accepted_trg ='1')then
			flag_trg <='1';
		end if;
	end if;
end process ready2Send_Trg;

clr_flag_trg <= rst or r_send_trg;

sending_trg_proc: process(selector, flag_trg)
 begin
--	if(rst='1')then
--		send_trg <='0';		
--	elsif(clk'event and clk='1')then
		if(selector="1000")then
			send_trg <= flag_trg;
		else
			send_trg <= '0';
		end if;
--	end if;
end process sending_trg_proc;



rit_send_trg: process(clk, rst)
 begin
	if(rst='1')then
		r_send_trg <='0';		
	elsif(clk'event and clk='1')then
		r_send_trg <= send_trg;
	end if;
end process rit_send_trg;

---------------- CONTEGGIO EVENTI ------ EC -------------
Cnt_Event: process(clk, Reset_Event_cnt)
 begin
	if(Reset_Event_cnt ='1')then
		event_counter <= x"000";
	elsif(clk'event and clk='1')then
		if(send_trg ='1')then
			event_counter <= event_counter +1;
		end if;
	end if;
end process Cnt_Event;
 
Reset_Event_cnt <= rst or rst_ec_fS;

------------- CONTEGGIO FRAME INVIATI ------  GTTAG ------  Time TAG 
Cnt_GTTAG: process(clk, rst)
 begin
	if(rst='1')then
		GTTAG_cnt <= "000" & x"000";
	elsif(clk'event and clk='1')then
		if(State = heather)then
			GTTAG_cnt <= GTTAG_cnt +1;
			else
			  GTTAG_cnt <= GTTAG_cnt ;
		end if;
	end if;
end process Cnt_GTTAG;

with GTTAG_cnt select
	TTSync <= '1' 		when ("000" & x"000"),
				 '0'		when others;


---------------------
--Assegna uscita

 EC 				<= Event_counter;
 Acc_TRG 		<= send_trg;
 Freq_1M5625HZ <= GTTAG_cnt(3);
------------------------------------------------------------
end Behavioral;