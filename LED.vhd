library IEEE;
library UNISIM;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use UNISIM.vcomponents.all;

entity LED is

   port ( PulsanteA, CLK            :  in  STD_LOGIC; --  RESET e CLK a 25MHz
	       LedA, LedB, LedC			   : out  std_logic;
			 SDO   	 						: out  STD_LOGIC;
			 SCK   	 						: out  STD_LOGIC;
			 LE_1PLL   						: out  STD_LOGIC;
			 LE_2PLL   						: out  STD_LOGIC;
			 PLL1_Locked, PLL2_Locked  :  in  STD_LOGIC;
          SYNC                      : out  STD_LOGIC;

--		GTX	--
			CLK_150_N	:  in  STD_LOGIC; --   CLK a 150MHz
			CLK_150_P   :  in  STD_LOGIC; --   CLK a 150MHz
			CLK_25_N    :  in  STD_LOGIC; --   CLK a 25MHz
			CLK_25_P    :  in  STD_LOGIC; --   CLK a 25MHz				
				       
--		3Gbit RX e TX	(FEE)	--
			SFP_EN	: out  std_logic;  -- Abilita il trasmettitore in fibra	 	 
			RXN_IN   : in   std_logic;  
			RXP_IN   : in   std_logic;
			TXN_OUT  : out  std_logic;
			TXP_OUT  : out  std_logic;
	
--		3Gbit RX e TX	(blk)	--
			SFP_EN_2	    : out  std_logic;  -- Abilita il trasmettitore in fibra	 	 
			RXN_IN_2   : in   std_logic;  
			RXP_IN_2   : in   std_logic;
			TXN_OUT_2  : out  std_logic;
			TXP_OUT_2  : out  std_logic;
			
--		Seriale	--
			RS232_RX    : out std_logic;  -- Slow controll
			RS232_TX    : in  std_logic;  -- Slow controll
			RS232cmdRX	: in  std_logic;  -- comandi
			RS232cmdTX	: out std_logic;  -- comandi

--		LEMO x TRIGGER	--
			LEMO_TRG_IN 		: in  std_logic; 
			LEMO_VETO_IN   	: in  std_logic; 
			LEMO_VETO_OUT  	: out std_logic;
			LEMO_MAJ_OUT 		: out std_logic;
			LEMO_TRG_OUT 		: out std_logic;

--		Monitoraggio	--

         TestPoint	: out  std_logic_vector(17 downto 0); -- TEST POINT Connettore 20pin 
			  
--		USB 16 bit		--
			 USBCLK	: in    std_logic;  
			 UFE 		: in    std_logic;  --	Flag Fifo nEmpty			
			 UFF		: in    std_logic;  --	Flag Fifo nFull  
			 UAD	   : out   std_logic_vector(1 downto 0);	-- Sel End Point
			 BD		: inout std_logic_vector(15 downto 0);	-- Bus a 16 bit
			 UWR		: out   std_logic;  
			 URD  	: out   std_logic;  
			 UOE   	: out   std_logic;  
			 UCS     : out   std_logic;  
			 UPKND	: out   std_logic;



--		CLK RECOVERED clk FIBRA 1		--
			REC_CLK_OUT_P     : out   std_logic;
			REC_CLK_OUT_N		: out   std_logic	;

--		CLK 1,56MHz Riferimento esterno della BLK Card		--								
		  Freq_1M5625HZ      : out std_logic	 );
		
end LED;


architecture Behavioral of LED is

----------------------------------------
--   COMPONENTI
----------------------------------------

--   Inizializzazione PLL        
Component INIT_PLL is
    Port ( CLK 		: in  STD_LOGIC;
           RESET 		: in  STD_LOGIC;
           FATTO 		: out  STD_LOGIC;
			  SDO   	 	: out  STD_LOGIC;
           SCK   	 	: out  STD_LOGIC;
			  LE_1PLL   : out  STD_LOGIC;
			  LE_2PLL   : out  STD_LOGIC
			  );
end component;
------------------------------   Componente GTX  ---------

component GTX_FISSO_TOP is
generic(
    EXAMPLE_CONFIG_INDEPENDENT_LANES	: integer   := 1;
    EXAMPLE_LANE_WITH_START_CHAR       : integer   := 0;
    EXAMPLE_WORDS_IN_BRAM              : integer   := 512;
    EXAMPLE_SIM_MODE                   : string    := "FAST";
    EXAMPLE_SIM_GTXRESET_SPEEDUP       : integer   := 1;
    EXAMPLE_SIM_PLL_PERDIV2            : bit_vector:= x"14d";
    EXAMPLE_USE_CHIPSCOPE              : integer   := 0 );    -- Set to 1 to use Chipscope to drive resets

port (
    tile0_refclk_i      : in   std_logic;   -- REF CLK

    --     Sezione RESET
    RESET_DONE_OUT      : out  std_logic;   -- RESET DONE
    GTXRESET_IN         : in   std_logic;   -- RESET
    TILE0_PLLLKDET_OUT  : out  std_logic;   --  PLL LOCkED

    -- Sezione TX
    GTX_Data_IN         : in   std_logic_vector(15 downto 0);	-- DATA IN
    K_Comma_IN          : in   std_logic_vector( 1 downto 0);   -- K_COMMA IN
    Ref_CLK_OUT         : out  std_logic;    --	REF CLK    dal pin d'ingresso
    TX_SYNC_DONE        : out  std_logic;    --  TX SYNC DONE Sincronizzazione del TX eseguita
 
    -- Sezione RX
    GTX_Data_OUT        : out  std_logic_vector(15 downto 0);	-- DATA OUT
    K_Comma_OUT         : out  std_logic_vector( 1 downto 0);   -- K_COMMA OUT
    RX_REC_CLK_OUT      : out  std_logic;    --	RX  RECOVERED & Buffered  CLK
    RX_ALLINEATO_OUT		: out  std_logic;    --  RX _ ALLINEATO
	 LockFailed_OUT 		: out  std_logic;    --  RX  Allineato ma dispari ( 1 clk)

     --   3Gbit RX e TX    ----
    RXN_IN              : in   std_logic;
    RXP_IN              : in   std_logic;
    TXN_OUT             : out  std_logic;
    TXP_OUT             : out  std_logic);

end component;


-------------------  Componente Trasmettitore Pacchetti per GTX   ----------------
component TX_to_FEE_Blk is
    Port ( clk 				: in  STD_LOGIC; -- 150MHz
	        CLK25MHz        : in  STD_LOGIC;
           rst 				: in  STD_LOGIC; -- RESET
			  rst_ec_fS			: in  STD_LOGIC;  -- RESET  Event counter
			  Glb_Trg 			: in  STD_LOGIC;  --  > GLTRG 
			  SCCT_from_S2Rx	: in  STD_LOGIC;  --  > slow controll Seriale
			  --	Time tag zero
			  Reset_bc_fS		: in  STD_LOGIC;  --  >  RESER Block CARD
			  ACQ_BUSY			: in  STD_LOGIC;  --  >  Blocca il trasferimento dei dati
			  PULSER				: in  STD_LOGIC;  --  >  Inpulsatore
			  Tx_is_ready		: in  STD_LOGIC;	-- Tile0_PLLLKDET_OUT GTX pronto a trasmettere
			  Trg_Pattern		: in  STD_LOGIC_VECTOR (11 downto 0);	
			  EC					: out  STD_LOGIC_VECTOR (11 downto 0);			  
			  K_Tx				: out  STD_LOGIC_VECTOR (1 downto 0);
           Stream_Tx 		: out  STD_LOGIC_VECTOR (15 downto 0);
			  Acc_TRG			: out  STD_LOGIC ;    --	Trigger inviato 
			  Freq_1M5625HZ 	: out  STD_LOGIC	  );	   -- Freq x Riferimento esterno BLK 

end component;

-------------  Componente RS232 Comandi
component TOP_Serial_TX_RX is
    Port ( clk 					: in  STD_LOGIC; -- 150MHZ ( GTX receiver )
			  rst 					: in  STD_LOGIC;
			  -- SERIALE
           Serial_rx_async 	: in  STD_LOGIC; -- RX
			  Serial_tx			 	: out  STD_LOGIC; -- TX
			  -- TX
           trasmitting_word	: in  STD_LOGIC_VECTOR(0 to 7); 			 
			  start_tx				: in  STD_LOGIC;
			  busy_tx				: out	 STD_LOGIC;
		     ---  RX 
			  accepted_word			: out	 STD_LOGIC; -- RX Dato valid
			  received_word			: out  STD_LOGIC_VECTOR(7 downto 0)  );	  
end component;

-----------------  Comp. DECODER
component Decoder is
    Port ( clk 				: in  STD_LOGIC; -- 150MHz
           rst 				: in  STD_LOGIC;
			  accepted_word	: in  STD_LOGIC;
			  received_word	: in  STD_LOGIC_VECTOR(7 downto 0);
			  g_trg				: out  STD_LOGIC	; --
			  rst_bc				: out  STD_LOGIC	; --  Reset BLCK CARD
			  rst_ec				: out  STD_LOGIC	; --  Reset Event Counter
			  en_comp_bmult	: out  STD_LOGIC	; -- Enable --
			  en_wrt_fifo		: out  STD_LOGIC	:='0';
			  Serial_USB      : out  STD_LOGIC	:='0';
			  read_fifo       : out  STD_LOGIC	:='0';
			  EN_pulser 		: out  STD_LOGIC  :='0';
			  ths_bmult       : out  STD_LOGIC_VECTOR(4 downto 0);
			  Freq_Pulser 		: out  STD_LOGIC_VECTOR(11 downto 0);
			  scaler          : out  STD_LOGIC_VECTOR(11 downto 0) ;
			  trg_pattern     : out  STD_LOGIC_VECTOR(11 downto 0);
			Slow_EN_FIFO		: out  STD_LOGIC_VECTOR(3 downto 0);
			Time_W				: out  STD_LOGIC_VECTOR(7 downto 0) 	  );  -- Time Windows	
end  component;

-------------  Component RX da GTX
component RX_from_FEE_Blk is
    Port ( clk 				: in  STD_LOGIC; -- 150MHz recovered
           rst 				: in  STD_LOGIC;
           K 					: in  STD_LOGIC_VECTOR (1 downto 0);
			  ENABLE				: in  STD_LOGIC;
           Stream_Data 		: in  STD_LOGIC_VECTOR (15 downto 0);
			  SCCR_to_S2Tx		: out STD_LOGIC;
			  valid				: out STD_LOGIC;
			  GTT					: out STD_LOGIC;
			  BMult				: out STD_LOGIC_VECTOR (4 downto 0)		  
			  );
end component;

COMPONENT ALL_FIFO_Daisy is
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
			  HF_EC			:out 	STD_LOGIC	  
   );	
end component;	


COMPONENT Global_Trg_Gen
  GENERIC ( Tmax          :STD_LOGIC_VECTOR (16 downto 0)   := '1' & X"FFFF" ) ; -- Tempo Monostabile (( Da ridurre in simulazione  )) 
    Port ( 
			  clk 				: in  STD_LOGIC; -- 150MHz
           rst 				: in  STD_LOGIC;
           G_trg_fS	 		: in  STD_LOGIC; -- Dalla seriale
           GTT_1				: in  STD_LOGIC; -- Block1 full
           GTT_2				: in  STD_LOGIC; -- Block2 full
			  FIFO_half_full 	: in  STD_LOGIC;
			  bmult_1			: in  STD_LOGIC_VECTOR (4 downto 0); -- dalla Block1 (( Dominio di clk diversi))
			  bmult_2			: in  STD_LOGIC_VECTOR (4 downto 0); -- dalla Block2 (( Dominio di clk diversi))
			  Bm_Valid_1		: in  STD_LOGIC;
			  Bm_Valid_2		: in  STD_LOGIC;
			  
           en_comp_bmult 	: in  STD_LOGIC;
           ths_bmult 		: in  STD_LOGIC_VECTOR (4 downto 0);  -- dalla SERIALE
			  Scaler          : in  STD_LOGIC_VECTOR (11 downto 0);  -- Divider 
			  Time_W				: in  STD_LOGIC_VECTOR (7 downto 0);  -- Divider 
			  
			  LEMO_TRG_IN		: in  STD_LOGIC;
			  LEMO_VETO_IN		: in  STD_LOGIC;
			  LEMO_VETO_OUT	: out  STD_LOGIC;
           LEMO_MAJ_OUT		: out  STD_LOGIC;
			  LEMO_TRG_OUT		: out  STD_LOGIC; 
			  
			  TP_MSB	 			: out  STD_LOGIC;   -- 12° bit del Trig Pattern (Trigger da Downscale)
           Glb_TRG 			: out  STD_LOGIC);
 END COMPONENT;

COMPONENT USB16bit
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
end COMPONENT;

--    PLL per shift di fase x           USB CLK
  COMPONENT USB_PLL_Fase
	PORT(
		CLKIN_IN 	: IN std_logic;
		RST_IN 		: IN std_logic;          
		CLK0_OUT 	: OUT std_logic;
		LOCKED_OUT	: OUT std_logic
		);
end component; 

--  Inpulsatore
    COMPONENT Pulser_Freq_FIX
    PORT(
         REF_CLK 		: IN  std_logic;
         RESET 		: IN  std_logic;
         EN 			: IN  std_logic;
			Tmax        : IN  STD_LOGIC_VECTOR (11 downto 0); -- Tempo Monostabile (( step 2621 uS  )) 7FF = 5,4 Sec
         Puls_OUT 	: OUT  std_logic
        );
    END COMPONENT;


--===================================================================================
-- COSTANTI & SEGNALI

signal RX_REC_CLK_OUT	:  std_logic ;
signal CLK25MHz         :  std_logic ;
signal UConta 				:	std_logic_vector (22 downto 0)  ; -- Lompeggio LED
signal Conta 				:	std_logic_vector (22 downto 0)  ; -- Lampeggio LED
signal RESET 				:  std_logic ;   -- reset interno
signal ContaReset 		:  std_logic_vector (15 downto 0) := (others => '0'); -- monostabile RESET
signal Stato_1PLL 		:  std_logic ;
signal Stato_2PLL 		:  std_logic ;
signal flg 					:  std_logic ;
signal EC					:  std_logic_vector (11 downto 0);
signal K_Comma_IN			:	std_logic_vector (1 downto 0);
signal K_Comma_OUT		:	std_logic_vector (1 downto 0);
signal K_Comma_OUT_2	:	std_logic_vector (1 downto 0);
signal GTX_Data_IN 		:	std_logic_vector (15 downto 0);
signal GTX_Data_OUT 		:	std_logic_vector (15 downto 0);
signal GTX_Data_OUT_2	:	std_logic_vector (15 downto 0);
signal Ref_CLK_OUT 		:	std_logic ;
signal TX_SYNC_DONE 		:	std_logic ;
signal TX_SYNC_DONE_2	:	std_logic ;
signal set_trg_pattern	:	std_logic ;
signal data_set			:	std_logic_vector (7 downto 0);	
signal RX_ALLINEATO_OUT :	std_logic ;	
signal RX_ALLINEATO_OUT_2 :std_logic ;	
signal LockFailed_OUT   :	std_logic ;	
signal rst_ec_fS        :	std_logic ;
signal ACQ_BUSY			:	std_logic ;
signal g_trg          	:	std_logic ;	
signal Reset_bc_fS     	:	std_logic ;	
signal accepted_word  	:	std_logic ;	
signal received_word 	:	std_logic_vector (7 downto 0);
signal wrt_FIFO			:	std_logic ;
signal en_wrt_fifo		:	std_logic ;
signal trasmitting_word	:	std_logic_vector (7 downto 0);
signal req_read_fifo		:	std_logic ; 
signal busy_tx				:	std_logic ; 
signal start_tx 			:	std_logic ; 
signal GTT              :	std_logic ;
signal BMult_1           :	std_logic_vector (4 downto 0);
signal GTT_2          :	std_logic ;
signal BMult_2        :	std_logic_vector (4 downto 0);
signal ths_bmult        :	std_logic_vector (4 downto 0);
signal en_comp_bmult    :	std_logic ;
signal scaler           :	std_logic_vector (11 downto 0);
signal TP_MSB           :	std_logic ;
signal trg_pattern      :	std_logic_vector (11 downto 0);
signal TP					:	std_logic_vector (11 downto 0);
signal tile0_refclk_i   :	std_logic ;
signal g_trg_Seriale    :	std_logic ;
signal Lemo_Veto_OUT_Interno :std_logic ;
signal LEMO_TRG_OUT_Interno  :std_logic ;
signal LEMO_MAJ_OUT_Interno  :std_logic ;
-- USB 
signal Din_to_USB     	:	std_logic_vector (15 downto 0); -- Out FIFO
--signal Din_to_USB_2  	:	std_logic_vector (15 downto 0); -- Out FIFO
signal USB_REG_ALL		:	std_logic_vector (15 downto 0); -- X ECO Comando
--signal USB_REG_ALL_2	:	std_logic_vector (15 downto 0); -- X ECO Comando
signal USB_EP2_DATA		:	std_logic_vector (15 downto 0); -- X Eco Comando
--signal USB_EP2_DATA_2	:	std_logic_vector (15 downto 0); -- X Eco Comando
signal USB_B_WR			:	std_logic ;
--signal USB_B_WR_2		:	std_logic ;
signal BD_in     			:	std_logic_vector (15 downto 0);  --  nel bus TRI x USB CYxxx
signal BD_out     		:	std_logic_vector (15 downto 0);  --  nel bus TRI x USB CYxxx
--signal BD_in_2 			:	std_logic_vector (15 downto 0);  --  nel bus TRI x USB CYxxx
--signal BD_out_2   		:	std_logic_vector (15 downto 0);  --  nel bus TRI x USB CYxxx
signal UCLK				   :	std_logic ;
--signal UCLK_2		   :	std_logic ;
signal FIFO_nEmpty      :	std_logic ;
signal FIFO_nEmpty_2  :	std_logic ;
signal Serial_USB       :	std_logic ;		-- FLAG dalla seriale
signal PK_ACK 				:	std_logic ;
--signal PK_ACK_2			:	std_logic ;
signal BD_dir				:	std_logic ;
--signal BD_dir_2			:	std_logic ;
signal EN_pulser			:	std_logic ;    -- x pulser
signal Pulser_OUT			:	std_logic ;
signal Freq_Pulser		:	std_logic_vector (11 downto 0);
signal Slow_EN_FIFO		:	std_logic_vector (3 downto 0);
  --  x monostabile LED (test_point)
signal TRG_Monostabile :std_logic_vector (17 downto 0);
signal  Monostabile    :std_logic_vector (17 downto 0);

signal RS232_RX_1			:	std_logic ;
signal RS232_RX_2			:	std_logic ;
signal RX_REC_CLK_OUT_2	:	std_logic ;
signal Acc_TRG				:	std_logic ;
signal ENABLE_RX_f_BLK  :	std_logic ;
signal ENABLE_RX_f_BLK_2 :	std_logic ;

signal Bm_Valid_1			:	std_logic ;
signal Bm_Valid_2       :	std_logic ;
signal Time_W				:	std_logic_vector (7 downto 0);
signal HF_EC				:	std_logic ;

 
constant MAX_T_Out 		: STD_LOGIC_VECTOR (15 downto 0) := X"FFFF";
--signal Freq_1M5625HZ		: std_logic ;



--   Attributi per mantenere i nomi in  CHIP Scope
 	attribute keep : string;

	attribute keep of  Time_W				: signal is "true";
	attribute keep of  g_trg				: signal is "true";
	attribute keep of  g_trg_Seriale		: signal is "true";
	attribute keep of  K_Comma_IN			: signal is "true";
	attribute keep of  EC					: signal is "true";
	attribute keep of  Acc_TRG				: signal is "true";
	attribute keep of ENABLE_RX_f_BLK   : signal is "true";
	attribute keep of ENABLE_RX_f_BLK_2 : signal is "true";

	
------------------------------------------------------------------------------	
begin
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--                  PORT  map 
------------------------------------------------------------------------------

--   PLL LMKxxxx

PLLU1: INIT_PLL port map (   
           CLK 		=>   	CLK,
           RESET 		=>  	RESET,
           FATTO 		=>    open,

			  SDO   	 	=> 	SDO,
           SCK   	 	=> 	SCK,	
			  LE_1PLL   => 	Stato_1PLL,
			  LE_2PLL   =>    Stato_2PLL
			  );        
---------------------

--    GTX  -----------------   GTX ------------------------- GTX --------------
-- Ric DIFF 
    tile0_refclk_ibufds_i : IBUFDS
    port map
    (
        O	=>	tile0_refclk_i,
        I   => CLK_150_P,		--  PIN  
        IB  => CLK_150_N    	--  PIN   
    );


inst_GTX_FISSO_TOP_noReset_1  : GTX_FISSO_TOP 
port map (      
    tile0_refclk_i		=>	tile0_refclk_i,   -- Dal ric Diff  PIN          
                                   
     --     Sezione RESET
    RESET_DONE_OUT      =>   open,    ----- non usato          
    GTXRESET_IN         =>   RESET ,      --          
    TILE0_PLLLKDET_OUT	=>   open, --  
  

        -- Sezione TX
    GTX_Data_IN         =>    GTX_Data_IN ,  -- x                
    K_Comma_IN          =>    K_Comma_IN ,   -- x           
    Ref_CLK_OUT         =>    Ref_CLK_OUT    , -- x               
    TX_SYNC_DONE        =>    TX_SYNC_DONE  , --  x             
                                
        -- Sezione RX
    GTX_Data_OUT        =>     GTX_Data_OUT,                     
    K_Comma_OUT         =>     K_Comma_OUT ,  --  <<<<                   
    RX_REC_CLK_OUT      =>     RX_REC_CLK_OUT,  --        
    RX_ALLINEATO_OUT    =>     RX_ALLINEATO_OUT , 	--     
	 LockFailed_OUT      =>     LockFailed_OUT,	 	--   Dispari    Non usato
                                
     --   3Gbit RX e TX    ----
    RXN_IN              =>      RXN_IN ,    --  PIN     
    RXP_IN              =>      RXP_IN ,    --  PIN   
    TXN_OUT             =>      TXN_OUT,    --  PIN    
    TXP_OUT             =>      TXP_OUT );  --  PIN   


--    GTX	-----------------   GTX ------------------------- GTX --------------

----- Seconda fibra
inst_GTX_FISSO_TOP_noReset_2  : GTX_FISSO_TOP 
port map (      
    tile0_refclk_i		=>	  tile0_refclk_i,   -- Dal ric Diff  PIN           
    --     Sezione RESET
    RESET_DONE_OUT      =>   open,
    GTXRESET_IN         =>   RESET,
    TILE0_PLLLKDET_OUT	=>   open,
    --		Sezione TX
    GTX_Data_IN         =>	  GTX_Data_IN,  
    K_Comma_IN          =>   K_Comma_IN,   
    Ref_CLK_OUT         =>   open, --Ref_CLK_OUT,		
    TX_SYNC_DONE        =>   TX_SYNC_DONE_2,
    -- 		Sezione RX
    GTX_Data_OUT        =>   GTX_Data_OUT_2,
    K_Comma_OUT         =>   K_Comma_OUT_2, 
    RX_REC_CLK_OUT      =>   RX_REC_CLK_OUT_2,  -- Cambiato !!!!!!!!!!!!!!!!!!!!!!!   
    RX_ALLINEATO_OUT    =>   RX_ALLINEATO_OUT_2,--RX_ALLINEATO_OUT, 	--   Allineato      
	 LockFailed_OUT      =>   open,--LockFailed_OUT_blk,	 	--   Dispari 
    --   	3Gbit RX e TX
    RXN_IN              =>   RXN_IN_2,    --  PIN     
    RXP_IN              =>   RXP_IN_2,    --  PIN   
    TXN_OUT             =>   TXN_OUT_2,   --  PIN 
    TXP_OUT             =>   TXP_OUT_2);  --  PIN   


--------  Componenti Rice/Trasmettitore    ----------------
--           TX su GTX
trasmissione : TX_to_FEE_Blk   --        TX
    port map ( 
	        clk 		  			=>		Ref_CLK_OUT , -- 150MHz di trasmissione
	        CLK25MHz           =>    CLK25MHz,
           rst 				   =>    RESET,
			  rst_ec_fS			   =>    rst_ec_fS,		  
			  Glb_Trg 			   =>    g_trg,
			  SCCT_from_S2Rx	   =>    RS232_TX,	   
			  Reset_bc_fS		   =>   	Reset_bc_fS,
			  ACQ_BUSY				=>		ACQ_BUSY	,
			  PULSER					=>    Pulser_OUT,		
			  Tx_is_ready		   =>   	TX_SYNC_DONE ,                    
			  Trg_Pattern		   =>    Trg_Pattern , 
			  EC						=>    EC ,
			  K_Tx				   =>  	K_Comma_IN,
           Stream_Tx 		   =>   	GTX_Data_IN ,
			  Acc_TRG				=>    Acc_TRG  ,
			  Freq_1M5625HZ		=>		Freq_1M5625HZ	);

--       receiver da GTX
Inst_RX_from_FEE_Blk: RX_from_FEE_Blk        --   RX
port map (
          clk 				=>		RX_REC_CLK_OUT,
          rst 				=>		RESET,
          K 				=>		K_Comma_OUT,
			 ENABLE			=>    ENABLE_RX_f_BLK ,
          Stream_Data 	=>		GTX_Data_OUT,
          SCCR_to_S2Tx	=>		RS232_RX_1,
			 valid			=>		Bm_Valid_1,
          GTT				=>		GTT,
          BMult			=>		BMult_1
			 );

--       receiver da GTX seconda fibra
Inst_RX_from_FEE_Blk_2 : RX_from_FEE_Blk        --   RX
port map (
          clk 				=>		RX_REC_CLK_OUT_2, -- 
          rst 				=>		RESET,
          K 				=>		K_Comma_OUT_2,
			 ENABLE			=>    ENABLE_RX_f_BLK_2,
          Stream_Data 	=>		GTX_Data_OUT_2,
          SCCR_to_S2Tx	=>		RS232_RX_2,  -- 
			 valid			=>		Bm_Valid_2,
          GTT				=>		GTT_2,
          BMult			=>		BMult_2
			 );
	
  
RS232_RX <= RS232_RX_1 and RS232_RX_2 ;

ENABLE_RX_f_BLK     <= RX_ALLINEATO_OUT   and  Slow_EN_FIFO(0);	
ENABLE_RX_f_BLK_2   <= RX_ALLINEATO_OUT_2 and Slow_EN_FIFO(1);

---------------------------  BUFFER Ricevitore Diff
  bufds_i : IBUFDS
  port map ( O => CLK25MHz,  I  => CLK_25_P,   IB => CLK_25_N );
  
 --    -------------------   Buffer OUT Recovered CLK
 
 OBUFDS_inst : OBUFDS
   generic map ( IOSTANDARD => "DEFAULT")
   port map (   O  => REC_CLK_OUT_P ,     	-- Diff_p output (connect directly to top-level port)
					 OB => REC_CLK_OUT_N ,    	-- Diff_n output (connect directly to top-level port)
					 I	 => RX_REC_CLK_OUT   );  	-- Buffer input  
 

---------          SERIALE    RS232  -----
Inst_Seriale : TOP_Serial_TX_RX
port map (
        clk 					=>		Ref_CLK_OUT,
        rst 					=>    RESET,
        -- SERIALE
        Serial_rx_async		=>		RS232cmdRX,
        Serial_tx				=>		RS232cmdTX,
        -- TX
        trasmitting_word	=>		trasmitting_word,							
        start_tx				=>		start_tx,									
        busy_tx				=>		busy_tx,										
        ---  RX 	
        accepted_word		=>   accepted_word,
        received_word	   =>   received_word);


--               DECODER  comandi seriali
Inst_Decoder : Decoder 
port map (
          clk 					=>	  Ref_CLK_OUT,				    
          rst 				   =>   RESET,                    
          accepted_word	   =>   accepted_word,            
          received_word	   =>   received_word,            
          g_trg				=>   g_trg_Seriale,                    
          rst_bc				=>   Reset_bc_fS,              
          rst_ec				=>   rst_ec_fS,                
          en_comp_bmult	   =>   en_comp_bmult,                																					
          en_wrt_fifo		=>	  en_wrt_fifo,	--  Internamente in AND con Slow_EN_FIFO  (Usato solo per LED)
			 Serial_USB       =>   Serial_USB,                           
          read_fifo        =>	  req_read_fifo, 
			 EN_pulser			=>   EN_pulser, 
          ths_bmult    		=>   ths_bmult,   
			 Freq_Pulser	   =>	  Freq_Pulser,
          trg_pattern 		=>   trg_pattern ,
          scaler     		=>   scaler			,
			Slow_EN_FIFO		=>	  Slow_EN_FIFO ,
			Time_W				=>   Time_W			);	       
 ---------------------------------------------------------
     TP(10 downto 0 ) <=  trg_pattern(10 downto 0 );
	  TP(11)      <= trg_pattern(11) or TP_MSB ; 

	--  --------------------------   ALL FIFO  ----------------
 Inst_All_fifo_Deasy: ALL_FIFO_Daisy
   GENERIC MAP ( MAX_T_Out => MAX_T_Out )
	PORT MAP (
          CLK150 				=> Ref_CLK_OUT,
          RESET 				=> RESET,
	 ---   Slow Controll
			 Slow_DIN 			=>  Slow_EN_FIFO ,	
			 Serial_USB 		=>  Serial_USB , -- Select flusso _USB o Seriale
			 
	  --  Connessione della Seriale	( OUT Dati )
          req_read_fifo 	=> req_read_fifo, 
          busy_Tx 			=>	busy_tx 		,
          Data_to_Serial 	=> trasmitting_word,
          Send_Data 			=> start_tx ,		
			 
		--   USB	 Det_fiber_OK => Det_fiber_OK,
		    Data_to_USB 		=>	Din_to_USB,
      	 USB_CLK     		=>	UCLK , -- 48MHz 
      	 FIFO_nEmpty 		=>	FIFO_nEmpty,
			 PK_ACK    			=>	PK_ACK  , 
			 
		 --    Ingressi dai GTX
          Data_to_FIFO_0  	=>	GTX_Data_OUT,
          Kin_0 				=>	K_Comma_OUT(1),			
			 Rec_CLK_0 			=> RX_REC_CLK_OUT, 		
			 RX_ALLIN_0			=> RX_ALLINEATO_OUT	,	
			                     
			 Data_to_FIFO_1 	=> GTX_Data_OUT_2,
          Kin_1 				=> K_Comma_OUT_2(1) ,			
			 Rec_CLK_1 			=> RX_REC_CLK_OUT_2, 		
			 RX_ALLIN_1			=> RX_ALLINEATO_OUT_2 ,	

--  Globale
          ACQ_BUSY 			=> ACQ_BUSY,

--  Event Counter Writer
         EC          		=> EC,
			GLTRG       		=>  Acc_TRG,
			HF_EC					=> HF_EC );	

--    TRIGGER 
	Inst_Global_Trg_Gen : Global_Trg_Gen 
	   GENERIC MAP (
				Tmax => '0' & x"0EA6" --  25uS
				)
			PORT MAP (
          clk 					=> Ref_CLK_OUT,
          rst 					=> RESET,
          G_trg_fS 			=> g_trg_Seriale,
          GTT_1				=> GTT,
          GTT_2				=> GTT_2,
			 
          FIFO_half_full 	=> HF_EC , -- Fifo ECC piena
			 
          bmult_1				=> BMult_1,
          bmult_2				=> BMult_2,
			 Bm_Valid_1			=> Bm_Valid_1,
			 Bm_Valid_2			=> Bm_Valid_2,
			 
          en_comp_bmult 	=> en_comp_bmult,
          ths_bmult 			=> ths_bmult,
          Scaler 				=> scaler,
			 Time_W				=> Time_W,
			  
          LEMO_TRG_IN 		=> not LEMO_TRG_IN,
          LEMO_VETO_IN 		=> not LEMO_VETO_IN,
          LEMO_VETO_OUT 	=> Lemo_Veto_OUT_Interno,
          LEMO_MAJ_OUT 		=> LEMO_MAJ_OUT_Interno,
          LEMO_TRG_OUT 		=> LEMO_TRG_OUT_Interno,
          TP_MSB 				=> TP_MSB,
          Glb_TRG 			=> g_trg
        );

LEMO_TRG_OUT	<= LEMO_TRG_OUT_Interno;
LEMO_MAJ_OUT   <= LEMO_MAJ_OUT_Interno;
LEMO_VETO_OUT 	<= Lemo_Veto_OUT_Interno;

--			USB			USB			USB			--
-----------------------------------------------
-- I/O TRI
 GEN_REG: 
   for I in 0 to 15 generate

IOBUF_inst : IOBUF
   port map ( 	O	 	=> BD_in(I),    
					IO 	=> BD(I),   
					I 		=> BD_out(I),    
					T 		=> BD_dir      -- 3-state enable input, high=input, low=output 
   );
   end generate GEN_REG;
---------------------------------- -  USB 
inst_USB16bit :    USB16bit   Port MAP(  -- USB Device
		USB_CLK 			=>	UCLK, 
		nCLR 				=>	not RESET,
		 --  USB	  
		USB_FE 			=>	UFE, 
		USB_FF			=> UFF,
		USB_EPSEL		=> UAD,
		USB_TRI			=>	BD_dir, 
		USB_DOUT			=>	BD_out,
		USB_DIN			=>	BD_in, 
		USB_WR			=> UWR,
		USB_RD			=> URD, 
		USB_OE			=>	UOE,
		USB_CS			=>	UCS,
		USB_PKEND		=>	UPKND,
									
		--   INTERNI				
		PKT_REQ			=>	FIFO_nEmpty,	
		PKT_ACK			=>	PK_ACK,	
		Fifo_DATA		=>	Din_to_USB,
		BDATA_IN			=> USB_REG_ALL, -- EP 6 
		BDATA_OUT		=> USB_EP2_DATA,  -- Bus comandi,
		BADDR				=> open,
		BWR				=> USB_B_WR, -- Normalmente - '0'
		BRD				=> open
	);
	-- Seconda USB
	-- I/O TRI


----------------------------------------
------- USB    Registri per testare l'USB agli EP2 ed EP6    --   USB
process (UCLK, RESET)
begin

if RESET = '1' then
	USB_REG_ALL	<= (others => '0');

elsif ( UCLK='1' and UCLK'Event) then    ---   ___|----  Fronte clk

    if  USB_B_WR = '1'  then
           USB_REG_ALL <= USB_EP2_DATA ;
		 
	  end if;  
end if; 

end process;


	
--         PLL   PLL    x  CLK USB
--    CLOCk FASE shift  USB CLK
	Inst_USB_PLL_Fase: USB_PLL_Fase PORT MAP(
		CLKIN_IN =>  USBCLK ,
		RST_IN 	=>  RESET,
		CLK0_OUT =>  UCLK ,
		LOCKED_OUT => open 
	);
	

--------------

	-- Inpulsatore
  inst_Pulser: Pulser_Freq_FIX 
	PORT MAP (
          REF_CLK 	=> CLK25MHz,
          RESET 		=> RESET,
          EN 			=> EN_pulser,
			 Tmax 		=> Freq_Pulser,
          Puls_OUT 	=> Pulser_OUT
        );
		  
	
----------------------------------------------------------------
-- 	     Assegna le Uscite e gli Ingressi 
----------------------------------------------------------------
   	
SFP_EN        <= not TX_SYNC_DONE;
SFP_EN_2    <= not TX_SYNC_DONE_2;

-- ------------------------------------
-- 			Assegna le uscite
-- ------------------------------------
SYNC  <= not RESET ;
LE_1PLL <= Stato_1PLL ;
LE_2PLL <= Stato_2PLL ;



-------------------------
--  Assegna i Test Point
---------------------------

--   IN Monostabile x LED
  TRG_Monostabile(0)  <=  not LEMO_TRG_IN ;
  TRG_Monostabile(1)  <=  LEMO_TRG_OUT_Interno ;
  TRG_Monostabile(2)  <=  not LEMO_VETO_IN ;
  TRG_Monostabile(3)  <=  Lemo_Veto_OUT_Interno ; 
  TRG_Monostabile(4)  <=  LEMO_MAJ_OUT_Interno;                   
  TRG_Monostabile(5)  <=  g_trg ;
  TRG_Monostabile(6)  <=  g_trg_Seriale ;							  
  TRG_Monostabile(7)  <=  Reset_bc_fS;    
  TRG_Monostabile(8)  <=  rst_ec_fS ;    
  TRG_Monostabile(9)  <=  en_comp_bmult ;  
  TRG_Monostabile(10) <=  en_wrt_fifo;	
  TRG_Monostabile(11) <=  Serial_USB;     
  TRG_Monostabile(12) <=  EN_pulser ;                              
  TRG_Monostabile(13) <=  Pulser_OUT;	                               
  TRG_Monostabile(14) <=  FIFO_nEmpty;    						           
  TRG_Monostabile(15) <=  ACQ_BUSY;	 					            
  TRG_Monostabile(16) <=  start_tx	;					            
  TRG_Monostabile(17) <=  PK_ACK 	;					
  --    OUT Monostabile x LED 
	TestPoint(0)  <=  Monostabile(0);
	TestPoint(1)  <=	Monostabile(1);
	TestPoint(2)  <=  Monostabile(2);
	TestPoint(3)  <=  Monostabile(3);
	TestPoint(4)  <=  Monostabile(4);
	TestPoint(5)  <=  Monostabile(5);
	TestPoint(6)  <=  Monostabile(6);
	TestPoint(7)  <=  Monostabile(7);
	TestPoint(8)  <=  Monostabile(8);
	TestPoint(9)  <=  Monostabile(9);
	TestPoint(10) <=  Monostabile(10);
	TestPoint(11) <=  Monostabile(11);
	TestPoint(12) <=  Monostabile(12);
	TestPoint(13) <=  Monostabile(13);
	TestPoint(14) <=  Monostabile(14);
	TestPoint(15) <=  Monostabile(15);
	TestPoint(16) <=  Monostabile(16);
	TestPoint(17) <=  Monostabile(17);
 


--------------------------------------------------------------
--                   Mio Codice 
---------------------------------------------------------------


--   Processo per RESET  -----------------------    ---|___
process (CLK, PulsanteA)
begin

if PulsanteA = '0' then
	ContaReset <= (others => '0');
	RESET <= '1';

elsif (CLK='1' and CLK'Event) then    ---   ___|----  Fronte clk

    if  ContaReset < X"FFFF"    then
           ContaReset <= ContaReset +1 ;
			  RESET <= '1';			 
	  else 
	       ContaReset <= ContaReset;
			 RESET <= '0';
	  end if;  
end if; 

end process;


--   Processo di  Conta per LAMPEGGIO  LED  ---------------------------------
process (Ref_CLK_OUT, RESET)
begin
--   LED '1' = OFF
 if Reset ='1' then
  LedA <= '0';
  LedB <= '0';
  LedC <= '0';
  Conta <= (others => '0');

  elsif (Ref_CLK_OUT='1' and Ref_CLK_OUT'Event) then    --- ___|----  Fronte clk
  Conta <=Conta +1 ;
   ------    Monostabile per LED su Test Point
  for i in 0 to 17 loop
     if TRG_Monostabile(i) = '1'  		THEN  Monostabile(i) <= '1' ;
	    elsif  Conta = "000" & X"00000" then  Monostabile(i) <= '0' ;
		 end if ;
   end loop;
  
  
  if RX_ALLINEATO_OUT  = '1' then 
                       LedA <= '0';
		elsif  Conta = "00000000000000000000000" then 
		                   LedA <= '1';
      end if;
 
  if RX_ALLINEATO_OUT_2 = '1'  then 
                       LedB <= '0';
		elsif  Conta = "00000000000000000000000" then 
		                   LedB <= '1';  
      end if;
		
  if PLL2_Locked = '0' and PLL1_Locked = '0'  then   LedC <=  '0';
       		elsif  Conta = "00000000000000000000000" then 
		                   LedC <= '1'; 
				end if;

  end if; 
end process;


end Behavioral;