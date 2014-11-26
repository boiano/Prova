----------------------------------------------------------------------------------
-- Company: INFN  
-- Engineer: 
-- 
-- Create Date:    19:11:22 21/06/2012
-- Design Name: 
-- Module Name:    ALL_FIFO_Daisy - Behavioral 
-- Project Name: 
-- Target Devices:       <<<          XC5VFX70T     >>>>>>
-- MEMORY     CI SONO    <<<  148 Blocchi da 36Kbit >>>>>>
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 0
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.vcomponents.all;


entity ALL_FIFO_Daisy is
 GENERIC ( MAX_T_Out : STD_LOGIC_VECTOR (15 downto 0) := X"FFFF");
    Port ( 
			  CLK150 : in  STD_LOGIC; -- CLK Ref CLK Dello GTX
			  RESET  : in  STD_LOGIC; -- RESET
 ---   Slow Controll
           Slow_DIN 		: in   STD_LOGIC_VECTOR (3 downto 0);  -- Per abilitare i singoli canali
			  Serial_USB  	: in  STD_LOGIC; -- Select flusso _USB o Seriale
			  
 --  Connessione della Seriale	( OUT Dati )	  
           req_read_fifo 	: in  STD_LOGIC;
           busy_Tx 			: in  STD_LOGIC;
           Data_to_Serial 	: out  STD_LOGIC_VECTOR (7 downto 0);
           Send_Data 		: out  STD_LOGIC;
	--   USB
           Data_to_USB 	: out  STD_LOGIC_VECTOR (15 downto 0);
			  USB_CLK     	: in  STD_LOGIC;
			  FIFO_nEmpty 	: out  STD_LOGIC;
			  PK_ACK    	: in   STD_LOGIC; 
------
  --    Ingressi dai GTX
           Data_to_FIFO_0 	: in  STD_LOGIC_VECTOR (15 downto 0);
           Kin_0 				: in  STD_LOGIC;
			  Rec_CLK_0 		: in std_logic; -- Recovered a 150MHz
			  RX_ALLIN_0		: in  std_logic;    --  RX _ ALLINEATO
			  
			  Data_to_FIFO_1 	: in  STD_LOGIC_VECTOR (15 downto 0);
           Kin_1 				: in  STD_LOGIC;
			  Rec_CLK_1 		: IN std_logic; -- Recovered a 150MHz
			  RX_ALLIN_1		: in  std_logic;    --  RX _ ALLINEATO		  

--  Globale
           ACQ_BUSY 			: out  STD_LOGIC;  -- Per la generazione del segnale ACQ_BUSY

--  Event Counter Writer
           EC          : in   STD_LOGIC_VECTOR (11 downto 0)  ;
			  GLTRG       : in   STD_LOGIC;
			  HF_EC		  : out  STD_LOGIC  --  Deve bloccare i trigger
   );			 
								 		  
end ALL_FIFO_Daisy;

architecture Behavioral of ALL_FIFO_Daisy is

-- ============================================================================
--    COMPONENTI
-- ============================================================================
 
--------------------------------------------------------------------------------

-------------------------------------------------------------------------------
COMPONENT Modulo_EC_LAST is
    GENERIC ( Num_Moduli : STD_LOGIC_VECTOR (3 downto 0) := X"A" );   -- Per il ritardo di PASS 
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
 --          WR_EN_out  : out  STD_LOGIC;
           Data_Out 	 : out  STD_LOGIC_VECTOR (15 downto 0)
			   );
end COMPONENT;
 
 
 COMPONENT Manag_FIFO_Daisy 
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
			  almost_full :  out  STD_LOGIC;

	--   Dal GTX		  
           Data_to_FIFO : in  STD_LOGIC_VECTOR (15 downto 0);
           Kin 			: in  STD_LOGIC;
			  RX_ALLIN 		: in STD_LOGIC);
  END COMPONENT;

-- Per la seriale  
component Reader_FIFO is
     Port (clk 				: in  STD_LOGIC;
           rst 				: in  STD_LOGIC;
           req_read_fifo 	: in  STD_LOGIC;
           Data_from_Fifo 	: in  STD_LOGIC_VECTOR (15 downto 0);
           busy_Tx 			: in  STD_LOGIC;
			  empty_fifo		: in  STD_LOGIC;
			  read_fifo 		: out  STD_LOGIC:= '0';
           Data_to_Serial 	: out  STD_LOGIC_VECTOR (7 downto 0);
           Send_Data 		: out  STD_LOGIC);
end component Reader_FIFO;

------------- Begin Cut here for COMPONENT Declaration ------  FIFO Globale

component Glob_Fifo
	port (
	rst: IN std_logic;
	wr_clk: IN std_logic;
	rd_clk: IN std_logic;
	din: IN std_logic_VECTOR(15 downto 0);
	wr_en: IN std_logic;
	rd_en: IN std_logic;
	dout: OUT std_logic_VECTOR(15 downto 0);
--	full: OUT std_logic;
	empty: OUT std_logic;
	prog_full: OUT std_logic);
end component;

-- Synplicity black box declaration
attribute syn_black_box : boolean;
attribute syn_black_box of Glob_Fifo: component is true;
---------------------------------------------------------------------------------------

-- ===================================================
--  Costanti e SEGNALI
TYPE D_ARRAY_LFIFO IS array (0 to 2) of std_logic_vector(15 downto 0);  -- OUT FIFO + ADC
signal Dat_Daisy        :  D_ARRAY_LFIFO ; -- Dati out Local FIFO ( compreso ADC )

signal Loc_HF           : std_logic_VECTOR(2 downto 0); --
signal D_Mux_OUT        : std_logic_VECTOR(15 downto 0); --
signal GL_WR_EN         : std_logic ;
signal GlobHF           : std_logic ;
signal Sel              : std_logic_VECTOR(2 downto 0); --
signal CRC              : std_logic_VECTOR(7 downto 0); --
signal Lenght           : std_logic_VECTOR(11 downto 0); -- 

-- Daisy signal
signal ECProposed 		: std_logic_VECTOR(11 downto 0); --
signal REN              : std_logic_VECTOR(3 downto 0); --
signal Busy_RD_ALL      : std_logic ;
signal WR_EN_DSY   		: std_logic_VECTOR(2 downto 0); --
signal EC_Valido			: std_logic ;
signal Seq_WR				: std_logic ;
signal ResFifo_EC 		: std_logic ;
signal ResFifo_GLB      : std_logic ;
signal rd_clk_FIFO  		: std_logic ;
signal read_fifo			: std_logic ;
signal Data_from_Fifo	: std_logic_VECTOR(15 downto 0); --
signal empty_fifo			: std_logic ;
signal Empty_Fifo_x_SERIALE : std_logic ;
signal read_fifo_RS  	: STD_LOGIC;

constant BLK_ID         : std_logic_VECTOR(11 downto 0) := X"7FF"; -- Blocco equivalente alla Test CARD
constant REG_ID         : std_logic_VECTOR(11 downto 0) := X"800"; -- Fine Dati dalla regionale

--   Attributi per mantenere i nomi in  CHIP Scope
 	attribute keep : string;
	
	attribute keep of  Sel				: signal is "true";
	attribute keep of  REN				: signal is "true";
	attribute keep of  WR_EN_DSY		: signal is "true";
	attribute keep of  EC_Valido		: signal is "true";
	attribute keep of  ResFifo_EC		: signal is "true";
	attribute keep of  read_fifo		: signal is "true";
	attribute keep of  Slow_DIN		: signal is "true";
	attribute keep of  Dat_Daisy		: signal is "true";
	
	
	
-- ===============================================================
----------------------  INIZIO  ------------------------
begin
------------------------   Vettore d'errore OR due a due 


--   ====================================================
--        Instanza Componenti

	
	Modulo_Canale_0: Manag_FIFO_Daisy 
    GENERIC MAP ( MAX_T_Out => MAX_T_Out)			
    Port MAP
	 ( rd_clk  		=> CLK150 ,     -- ref CLK a 150MHz
		wr_clk  		=> Rec_CLK_0 ,   -- Recovered a 150MHz
      rst  			=> RESET ,	
			
	--   Daisy chain
		ECProposed  => ECProposed,
		REN 			=>	REN(0),	
		PASSO 		=>	REN(1),	
		Busy 			=> Busy_RD_ALL,
		Data_in 		=>	Dat_Daisy(1),
		Data_Out 	=> Dat_Daisy(0),				
		WR_EN_in 	=> WR_EN_DSY(1),	
		WR_EN_out 	=>	WR_EN_DSY(0),		
				
	--  WR FIFO 
		en_wrt_fifo	=> Slow_DIN(0),   -- Abilita la scrittura  dallo slow control 
		almost_full => Loc_HF(0),

	--   Dal GTX		
     Data_to_FIFO => Data_to_FIFO_0,
      Kin 			=> Kin_0 ,
		RX_ALLIN		=>  RX_ALLIN_0
	);
					  		
 Modulo_Canale_1: Manag_FIFO_Daisy 
    GENERIC MAP ( MAX_T_Out => MAX_T_Out)			
    Port MAP
	 ( rd_clk  		=> CLK150 ,     -- ref CLK a 150MHz
		wr_clk  		=> Rec_CLK_1 ,   -- Recovered a 150MHz
      rst  			=> RESET ,	
			
	--   Daisy chain
		ECProposed  => ECProposed,
		REN 			=>	REN(1),	
		PASSO 		=>	REN(2),	
		Busy 			=> Busy_RD_ALL,
		Data_in 		=>	Dat_Daisy(2),
		Data_Out 	=> Dat_Daisy(1),				
		WR_EN_in 	=> WR_EN_DSY(2),
		WR_EN_out 	=>	WR_EN_DSY(1),		
				
	--  WR FIFO 
		en_wrt_fifo	=> Slow_DIN(1),   -- Abilita la scrittura  dallo slow control 
		almost_full => Loc_HF(1),

	--   Dal GTX		
     Data_to_FIFO => Data_to_FIFO_1,
      Kin 			=> Kin_1 ,
		RX_ALLIN		=> RX_ALLIN_1
	);
  
------------------------------------------------------------------------------
--   BUSY

 Busy_RD_ALL <=  GlobHF and Slow_DIN(3) ;  --- nella lettura 
 
 ACQ_BUSY    <= 	( Loc_HF(0) and  Slow_DIN(0)) or  
						( Loc_HF(1) and  Slow_DIN(1)) ;
						
 HF_EC	<=( Loc_HF(2) and  Slow_DIN(2)) ; -- Busy inviato alla Fobra x stoppare i dati 

----------------------------------------------------------------	
 -- Modulo EC LAST 
  inst_Modulo_EC: Modulo_EC_LAST 
  GENERIC MAP (  Num_Moduli => X"2" )-- Ritardo per last PASS
  PORT MAP (   -- Modulo EC
          f150MHz 	=> CLK150,
          Reset 		=> ResFifo_EC,
          Busy 		=> '0', -- Sempre attivo
          HFull 		=> Loc_HF(2) , -- per la generazione del segnale ACQ_BUSY
          GLTRG 		=> GLTRG,
          EC_Fibra 	=> EC, -- Alla  Fibra
          ECProposed => ECProposed,-- EC che si vuole leggere
          EC_Valido 	=> EC_Valido,    -- C'è almeno un evento da leggere
          REN 			=> REN(2),
          PASSo 		=> REN(3),
  --        WR_EN_out 	=> WR_EN_DSY(2),
          Data_Out 	=> Dat_Daisy(2)
        );
 ----------------
 
 WR_EN_DSY(2) <= '0';
 
 ResFifo_EC  <= RESET  or not Slow_DIN(2); -- RESET FIFO EC
 ResFifo_GLB <= RESET  or not Slow_DIN(3);	-- RESET FIFO GLOBALE	
	

-------------------------------------------------------------
Inst_Global_Fifo :  Glob_Fifo -- Global FIFO 
PORT MAP (
	rst        =>  ResFifo_GLB,
	wr_clk     =>  CLK150,
	rd_clk     =>  rd_clk_FIFO,
	din        =>  D_Mux_OUT,
	wr_en      =>  GL_WR_EN,
	rd_en      =>  read_fifo,
	dout       =>  Data_from_Fifo,
--	full       =>  OPEN,
	empty      =>  empty_fifo,
	prog_full  => GlobHF
);  

GL_WR_EN <= Seq_WR or WR_EN_DSY(0) ; -- WR alla FIFO

-------------------------------------------------------------

-- ===============================================================
--   INIZIO CODICE 
---------------------------------------------------------------------------
-- Inizio Sequenza di lettura
process (Reset , CLK150 )  -- Seq_LETTURA
begin
if Reset =  '1' Then

SEL 		<= (others => '0');
REN(0) 	<= '0';
Seq_WR 	<= '0';								

elsif (CLK150 ='1' and CLK150'Event) then  

 if  REN(0) = '0' and EC_Valido = '1' and REN(3) = '0' and Busy_RD_ALL = '0' THEN -- Da il REN
      REN(0) 	<= '1';
		SEL  		<= "000"; 
		Seq_WR <= '0';
	elsif REN(3) = '1' and REN(0) = '1'  and SEL = "000" then -- Aspetta il PASS ( ren(3) )
	   REN(0) <= '1';
	   SEL    <= "001" ;
		Seq_WR <= '1';
--   elsif SEL < "100" and  SEL /= "000" then
--	   REN(0) <= '1';
--	   SEL    <=  SEL + 1;
--		Seq_WR <= '1';
	elsif SEL > "000" then
	   REN(0) 	<= '0';
		SEL  		<= "000"; 
		Seq_WR <= '0';
	 end if;      	
   
end if;

end process;
----------------------------------------------------------------------
-- ------------------------------------------------------------------
process (Sel ,Dat_Daisy(0)  ) -- ,Lenght,CRC)  --MUX 4 TO 1 
begin
   case Sel is
      when "000" => 	D_Mux_OUT <= Dat_Daisy(0);
--		when "001" => 	D_Mux_OUT <= "1100" & BLK_ID; -- Ma
--		when "010" => 	D_Mux_OUT <= "1010" & Lenght;		
--		when "011" => 	D_Mux_OUT <= "1101" & CRC & "0000" ;		
      when others => D_Mux_OUT <= "1100" & REG_ID; -- Fine Regionale
   end case;
end process;
--------------------------------------------------------------------------


process (Reset , CLK150 )  --Lenght EVENT parte da +2    + CRC
begin
 
if Reset =  '1'  Then
		Lenght <= X"002" ; -- 12bit  
		CRC     <= X"00" ; -- CRC 8 bit
 
elsif (CLK150 ='1' and CLK150'Event) then  
	  
   if SEL = X"4" and GL_WR_EN = '1'     then     Lenght <= X"002" ; -- 12bit resettato 
	                                              CRC     <= X"00" ; -- CRC 8 bit
																 
	elsif SEL /= X"4" and GL_WR_EN = '1' then     Lenght <=  Lenght +1 ; -- Conta
	                                               CRC     <=  D_Mux_OUT(15 downto 8) xor D_Mux_OUT(7 downto 0) xor CRC ; -- Calcola
																  
					else                              Lenght <=  Lenght;   -- Rimane
																 CRC     <= CRC  ;    -- Rimane 
	end if;

end if;

end process;
---------------------------------------------------------------------------

 
 ----------------------------------------------------------------------------------------
 ----------------------------------------------------------------------------------------
 --                     PARTE per LETTURA FIFO
 ----------------------------------------------------------------------------------------
 ----------------------------------------------------------------------------------------
Lettura_FIFO: Reader_FIFO
	Port map( 	clk 				=> CLK150			,
					Rst 				=> Reset       ,
					req_read_fifo	=> req_read_fifo	,
					Data_from_Fifo => Data_from_Fifo ,
					busy_Tx        => busy_Tx        ,
					empty_fifo     => Empty_Fifo_x_SERIALE  ,
					read_fifo      => read_fifo_RS		,
					Data_to_Serial	=> Data_to_Serial	,
					Send_Data      => Send_Data		);
					
   Empty_Fifo_x_SERIALE <=  empty_fifo  or  Serial_USB ;
-- Connessione a USB

	Data_to_USB 	<= 	Data_from_Fifo ;		-- Collega il bus DATI	
	FIFO_nEmpty 	<=		(not empty_fifo)  and Serial_USB  ; 					
					

-- MUX 
 -- Processo combinatoriale
Process (Serial_USB, read_fifo_RS, read_fifo, PK_ACK)
 begin
      if Serial_USB = '1' THEN read_fifo <= PK_ACK;					
		  else                   read_fifo <= read_fifo_RS;
		  end if;			
end process;
	
-- CLK MUX 
    BUFGMUX_CTRL_inst : BUFGMUX_CTRL
   port map (
      O =>  rd_clk_FIFO ,    -- Clock MUX output
      I0 => CLK150 ,  -- Clock0 dalla seriale
      I1 => USB_CLK,  -- Clock1 USB
      S => Serial_USB     -- Clock select input
   );
---------------------------------------------------------------------------------------
end Behavioral;

