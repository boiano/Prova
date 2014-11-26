----------------------------------------------------------------------------------
-- Company:   INFN Napoli
-- Engineer:     Alfonso Boiano
-- 
-- Create Date:    09:56:35 09/10/2012 
-- Module Name:    USB16bit - Behavioral 
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments:    FUNZIONA BENE --- TESTATO 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--------------------------------------------------------


entity USB16bit is
    Port ( USB_CLK 	: in  STD_LOGIC;
           nCLR 		: in  STD_LOGIC ;
		-- USB	  
			  USB_FE 	: in  STD_LOGIC; -- '1' = non vuoto
			  USB_FF		: in  STD_LOGIC;
			  USB_EPSEL	: out STD_LOGIC_VECTOR (1 downto 0);
			  USB_TRI	: out STD_LOGIC;   -- '0' OUTPUT   '1' = Input
			  USB_DOUT	: out STD_LOGIC_VECTOR (15 downto 0);
			  USB_DIN	: in  STD_LOGIC_VECTOR (15 downto 0);
			  USB_WR		: out STD_LOGIC; --  '0' = Attivo
			  USB_RD		: out STD_LOGIC; --  '0' = Attivo
			  USB_OE		: out STD_LOGIC; --  '0' = Attivo va attivato un ciclo prima della lettura
			  USB_CS		: out STD_LOGIC;        	
			  USB_PKEND	: out STD_LOGIC; --  '0' = Attivo     		  
															
		--  INTERNI										
				PKT_REQ	: in  STD_LOGIC;			
				PKT_ACK	: out STD_LOGIC;			
				Fifo_DATA: in  STD_LOGIC_VECTOR (15 downto 0);
				BDATA_IN	: in  STD_LOGIC_VECTOR (15 downto 0);
				BDATA_OUT: out STD_LOGIC_VECTOR (15 downto 0);
				BADDR		: out STD_LOGIC_VECTOR (15 downto 0);
				BWR		: out STD_LOGIC;
				BRD		: out STD_LOGIC
			  
			  );
end USB16bit;

architecture Behavioral of USB16bit is

-- COMPONENTI 

component RegistroComando is 
    Port ( CLK48M 		: in  STD_LOGIC;
           nRESET 		: in  STD_LOGIC;
           EN_CMD 		: in  STD_LOGIC;
			  ERR				: in  STD_LOGIC;
			  BD_IN 			: in  STD_LOGIC_VECTOR (15 downto 0);
           I_OPC 			: out  STD_LOGIC_VECTOR (15 downto 0);
           II_ADDR 		: out  STD_LOGIC_VECTOR (15 downto 0);
           III_DATA 		: out  STD_LOGIC_VECTOR (15 downto 0));
end component;



----------------------------------------------------------
--				            SEGNALI
----------------------------------------------------------
    --   X Macchina a  STATI 
  type cmds is (S0, SWAIT, COMANDO, ENDCMD, CMDWR, CMDERR, CMDRD, ANSW, PK_END, ANSW2, ANS_RD, PREWAIT, SBLOCK, EP8FREE, EP8TESTA, PK_ACK, PK_END2, PK_ACK_LAST );
signal state : cmds;
-----------------------------------------------------------
--signal iUSB_FE : STD_LOGIC;
signal EN_CMD	: STD_LOGIC;
signal ERR		: STD_LOGIC;
signal I_OPC 	: STD_LOGIC_VECTOR (15 downto 0);
signal II_ADDR : STD_LOGIC_VECTOR (15 downto 0); 
signal III_DATA : STD_LOGIC_VECTOR (15 downto 0);
signal OPC  	: STD_LOGIC_VECTOR (3 downto 0);
signal MUX_SEL : STD_LOGIC_VECTOR (1 downto 0);
signal ContaWRD : STD_LOGIC_VECTOR (7 downto 0);
signal iUSB_DOUT :STD_LOGIC_VECTOR (15 downto 0);
signal EN_CONTA : STD_LOGIC;

begin
--   Assegna segnali

OPC <= I_OPC (15 downto 12);

--  USCITE
USB_CS 		<= '0';      -- Sempre abilitato
BDATA_OUT	<= III_DATA;
BADDR			<= II_ADDR;
USB_DOUT		<= iUSB_DOUT;

--------------------------------------------------------------
--      CODICE
--------------------------------------------------------------
--
-----------------------------------------------------------------	
instReg_Comando: RegistroComando port map (
			CLK48M  	=>	USB_CLK,             -- Ingresso clock a 48 MHz
			nRESET  	=>	nCLR,						-- n RESET
         EN_CMD   => EN_CMD, 
         ERR		=> ERR, 						-- OPCODE ERRORE
         BD_IN 	=> USB_DIN,
         I_OPC 	=> I_OPC 	,
         II_ADDR  => II_ADDR ,
         III_DATA => III_DATA
);							
----------------------------------------


--           -----------------------------   MACCHINA a STATI ------------------
-- STATI >   S0, SWAIT, COMANDO, ENDCMD, CMDWR, CMDERR, CMDRD, ANSW, PK_END, ANSW2, ANS_RD, PREWAIT, SBLOCK, EP8FREE, EP8TESTA, PK_ACK, PK_END2
MSTATI : process (nCLR, USB_CLK)
begin
  if nCLR ='0' then
  state <= S0 ;
  

  elsif (USB_CLK='1' and USB_CLK'Event) then    --- ___|----  Fronte clk
    

       case state is
		 
		      when S0 => ----------------  S0
				             state <= SWAIT ;
		 
				when SWAIT => ----------------  SWAIT
				             if USB_FE = '1'  				then  			state <= COMANDO ;
									elsif USB_FE = '0' and PKT_REQ = '1' then state <= SBLOCK;
										else             								state <= SWAIT ;
								end if;

				when COMANDO => ----------------  COMANDO
				              if  USB_FE = '0'    then  	state <= ENDCMD ;
													else           state <= COMANDO ;
									end if;								
 
				when ENDCMD => ----------------  ENDCMD
				             if OPC = X"1"  				then  	state <= CMDWR ;
									elsif OPC = X"2"        then 		state <= CMDRD ;
										else             					state <= CMDERR ;
								end if;
 -----------------
				when CMDRD => ----------------  CMDRD    COMANDO Di Lettura
				                state <= ANSW2 ;
				when ANSW2 => ----------------  ANSW2
				                state <= ANS_RD ;
				when ANS_RD => ----------------  ANS_RD
				                state <= PK_END ;	
									 
 -----------------
           when CMDWR => ----------------  CMDWR    COMANDO Di scrittura
				                state <= ANSW ;
			  when ANSW => ----------------   ANSW
				                state <= PK_END ;	
			  when PK_END => ----------------   PK_END
				                state <= PREWAIT ;								 
 -----------------
				when CMDERR => ----------------  CMDERR    COMANDO ERRATO
				                state <= ANSW ;
				
  -----------------
				when SBLOCK => ----------------  SBLOCK    Lettura FIFO FPGA
				                state <= EP8FREE ;
					 
				when EP8FREE => ----------------  EP8FREE
				             if USB_FE = '0'				then  	state <= EP8TESTA ;
										else             					state <= PK_END2  ;
								end if;
								
			  when EP8TESTA => ----------------   EP8TESTA
				                state <= PK_ACK ;		

									 
				when PK_ACK => ----------------  PK_ACK
				             if PKT_REQ  =  '0'  		 	then  						state <= PK_END2 ;
									elsif USB_FF = '0' or ContaWRD = X"FE" 	 then 	state <= PK_ACK_LAST ;
												else             									state <= PK_ACK ;
								end if;	
								
			  when PK_ACK_LAST => -----------    PK_ACK_LAST   --  Invia un ultimo write all'USB
										state <= PREWAIT ;
			
			  when PK_END2 => ----------------    PK_ACK
				                state <= PREWAIT ;				
				
			when PREWAIT => ----------------    PREWAIT
				                state <= SWAIT ;	
			

			
         when others => ----------------  ALTRI
				               state <= S0 ;

            END CASE ;
  end if ;
 end process MSTATI;                 
----------------------------------------------------------------------------------------------------
-- MS_Combinatoriale
-- STATI >>>  S0, SWAIT, COMANDO, ENDCMD, CMDWR, CMDERR, CMDRD, ANSW, PK_END, ANSW2, ANS_RD, PREWAIT, SBLOCK, EP8FREE, EP8TESTA, PK_ACK, PK_END2
PRO2 : process (state) 
  begin          --       **************   Le USCITE    *********************************************
  case state is  
  --  USB_EPSEL  	  USB_TRI(1=In)   USB_WR(0=WR)  USB_RD(0=WR) USB_OE(0=CY Out) USB_PKEND(0=send) MUX_SEL      ERR        EN_CMD        EN_CONTA        PK_ACK         BWR        BRD	   				
	when S0 	   	=> ------------
	USB_EPSEL <="00"; USB_TRI <='1'; USB_WR <='1'; USB_RD <='1'; USB_OE <='1'; USB_PKEND <='1'; MUX_SEL <="00"; ERR <='0'; EN_CMD <='0'; EN_CONTA <='0'; PKT_ACK <='0'; BWR <='0'; BRD <='0';  
	when SWAIT  	=> ------------
	USB_EPSEL <="00"; USB_TRI <='1'; USB_WR <='1'; USB_RD <='1'; USB_OE <='0'; USB_PKEND <='1'; MUX_SEL <="00"; ERR <='0'; EN_CMD <='0'; EN_CONTA <='0'; PKT_ACK <='0'; BWR <='0'; BRD <='0';  
	when COMANDO 	=> ------------
	USB_EPSEL <="00"; USB_TRI <='1'; USB_WR <='1'; USB_RD <='0'; USB_OE <='0'; USB_PKEND <='1'; MUX_SEL <="00"; ERR <='0'; EN_CMD <='1'; EN_CONTA <='0'; PKT_ACK <='0'; BWR <='0'; BRD <='0';  
	when ENDCMD		=> ------------
	USB_EPSEL <="10"; USB_TRI <='1'; USB_WR <='1'; USB_RD <='1'; USB_OE <='1'; USB_PKEND <='1'; MUX_SEL <="00"; ERR <='0'; EN_CMD <='0'; EN_CONTA <='0'; PKT_ACK <='0'; BWR <='0'; BRD <='0';  
	when CMDWR		=> ------------
	USB_EPSEL <="10"; USB_TRI <='0'; USB_WR <='1'; USB_RD <='1'; USB_OE <='1'; USB_PKEND <='1'; MUX_SEL <="00"; ERR <='0'; EN_CMD <='0'; EN_CONTA <='0'; PKT_ACK <='0'; BWR <='1'; BRD <='0';  
	when CMDERR  	=> ------------
	USB_EPSEL <="10"; USB_TRI <='0'; USB_WR <='1'; USB_RD <='1'; USB_OE <='1'; USB_PKEND <='1'; MUX_SEL <="00"; ERR <='1'; EN_CMD <='0'; EN_CONTA <='0'; PKT_ACK <='0'; BWR <='0'; BRD <='0';  
	when CMDRD 	   => ------------
	USB_EPSEL <="10"; USB_TRI <='0'; USB_WR <='1'; USB_RD <='1'; USB_OE <='1'; USB_PKEND <='1'; MUX_SEL <="00"; ERR <='0'; EN_CMD <='0'; EN_CONTA <='0'; PKT_ACK <='0'; BWR <='0'; BRD <='1';  
	when ANSW 	   => ------------
	USB_EPSEL <="10"; USB_TRI <='0'; USB_WR <='0'; USB_RD <='1'; USB_OE <='1'; USB_PKEND <='1'; MUX_SEL <="00"; ERR <='0'; EN_CMD <='0'; EN_CONTA <='0'; PKT_ACK <='0'; BWR <='0'; BRD <='0';  
	when PK_END 	 => ------------
	USB_EPSEL <="10"; USB_TRI <='0'; USB_WR <='1'; USB_RD <='1'; USB_OE <='1'; USB_PKEND <='0'; MUX_SEL <="00"; ERR <='1'; EN_CMD <='0'; EN_CONTA <='0'; PKT_ACK <='0'; BWR <='0'; BRD <='0';  
	when ANSW2 	   => ------------
	USB_EPSEL <="10"; USB_TRI <='0'; USB_WR <='0'; USB_RD <='1'; USB_OE <='1'; USB_PKEND <='1'; MUX_SEL <="00"; ERR <='0'; EN_CMD <='0'; EN_CONTA <='0'; PKT_ACK <='0'; BWR <='0'; BRD <='1';  
	when ANS_RD 	   => ------------
	USB_EPSEL <="10"; USB_TRI <='0'; USB_WR <='0'; USB_RD <='1'; USB_OE <='1'; USB_PKEND <='1'; MUX_SEL <="01"; ERR <='0'; EN_CMD <='0'; EN_CONTA <='0'; PKT_ACK <='0'; BWR <='0'; BRD <='1';  
	when PREWAIT 	   => ------------
	USB_EPSEL <="00"; USB_TRI <='1'; USB_WR <='1'; USB_RD <='1'; USB_OE <='1'; USB_PKEND <='1'; MUX_SEL <="00"; ERR <='0'; EN_CMD <='0'; EN_CONTA <='0'; PKT_ACK <='0'; BWR <='0'; BRD <='0';  
	when SBLOCK 	   => ------------
	USB_EPSEL <="11"; USB_TRI <='0'; USB_WR <='1'; USB_RD <='1'; USB_OE <='1'; USB_PKEND <='1'; MUX_SEL <="00"; ERR <='0'; EN_CMD <='0'; EN_CONTA <='0'; PKT_ACK <='0'; BWR <='0'; BRD <='0';  
	when EP8FREE 	   => ------------
	USB_EPSEL <="11"; USB_TRI <='0'; USB_WR <='1'; USB_RD <='1'; USB_OE <='1'; USB_PKEND <='1'; MUX_SEL <="10"; ERR <='0'; EN_CMD <='0'; EN_CONTA <='0'; PKT_ACK <='0'; BWR <='0'; BRD <='0';  
	when EP8TESTA 	   => ------------
	USB_EPSEL <="11"; USB_TRI <='0'; USB_WR <='0'; USB_RD <='1'; USB_OE <='1'; USB_PKEND <='1'; MUX_SEL <="10"; ERR <='0'; EN_CMD <='0'; EN_CONTA <='1'; PKT_ACK <='1'; BWR <='0'; BRD <='0';  
	when PK_ACK 	   => ------------
	USB_EPSEL <="11"; USB_TRI <='0'; USB_WR <='0'; USB_RD <='1'; USB_OE <='1'; USB_PKEND <='1'; MUX_SEL <="11"; ERR <='0'; EN_CMD <='0'; EN_CONTA <='1'; PKT_ACK <='1'; BWR <='0'; BRD <='0';  
	when PK_END2 	   => ------------
	USB_EPSEL <="11"; USB_TRI <='0'; USB_WR <='1'; USB_RD <='1'; USB_OE <='1'; USB_PKEND <='0'; MUX_SEL <="11"; ERR <='0'; EN_CMD <='0'; EN_CONTA <='0'; PKT_ACK <='0'; BWR <='0'; BRD <='0';  
   when PK_ACK_LAST  =>
	USB_EPSEL <="11"; USB_TRI <='0'; USB_WR <='0'; USB_RD <='1'; USB_OE <='1'; USB_PKEND <='1'; MUX_SEL <="11"; ERR <='0'; EN_CMD <='0'; EN_CONTA <='0'; PKT_ACK <='0'; BWR <='0'; BRD <='0';  

	when others 	=> -------  ERRORE 
	USB_EPSEL <="00"; USB_TRI <='0'; USB_WR <='0'; USB_RD <='0'; USB_OE <='0'; USB_PKEND <='0'; MUX_SEL <="00"; ERR <='0'; EN_CMD <='0'; EN_CONTA <='0'; PKT_ACK <='0'; BWR <='0'; BRD <='0';  
                
    end case;                
end process PRO2;
--------------------------------------------------------------------------------------------------------
 --         CONTATORE 
U_CONTATORE : process (nCLR, USB_CLK)
begin
  if nCLR ='0' then
		ContaWRD <= X"00" ;

  elsif (USB_CLK='1' and USB_CLK'Event) then    --- ___|----  Fronte clk
      
		  if  EN_CONTA = '1'  then ContaWRD <= ContaWRD + 1;
			else                 ContaWRD <= X"00" ;
				end if;
  end if;
end process U_CONTATORE;

---------------------------------------------------------------------------------------------------
TRE_MUX : process (MUX_SEL, I_OPC, BDATA_IN, Fifo_DATA)              ---  i 4  MUX 
begin
 iUSB_DOUT <= (others => '0');
 
 case MUX_SEL is      --     iUSB_DOUT         
		      when "00" => iUSB_DOUT  <= I_OPC ;  
				when "01" => iUSB_DOUT  <= BDATA_IN;  
				when "10" => iUSB_DOUT  <= X"8000"; -- OPCode  
          when others => iUSB_DOUT  <= Fifo_DATA;  
  end case;
end process TRE_MUX ;
--------------------------------------------------------------------------------------------------


end Behavioral;

																																			
																			