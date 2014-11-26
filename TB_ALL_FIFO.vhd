--------------------------------------------------------------------------------
-- Company: INFN 
-- Engineer: A.Boiano SER Napoli

--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use std.textio.all;
 
ENTITY TB_ALL_FIFO IS
END TB_ALL_FIFO;
 
ARCHITECTURE behavior OF TB_ALL_FIFO IS 
 
    -- Component Declaration for the Unit Under Test (UUT)    

 COMPONENT ALL_FIFO_Daisy
GENERIC ( MAX_T_Out : STD_LOGIC_VECTOR (15 downto 0) := X"FFFF");
    Port ( 
			  CLK150 : in  STD_LOGIC; -- CLK Ref CLK Dello GTX
			  RESET  : in  STD_LOGIC; -- RESET
 ---   Slow Controll
           Slow_DIN 		: in   STD_LOGIC_VECTOR (3 downto 0);  -- Per abilitare i singoli canali (0 = GTX0, 1 = GTX1, 2  
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
			  GLTRG       : in   STD_LOGIC			  
   );	
  END COMPONENT; 	
                                                                       
----------------------   LEGGE FILE -----------    

COMPONENT READ_FILE_Fibra_Format                                                     	    
	generic ( in_data_path  : string   );	                                            
                                       
	port (                                                                         			  
		clk		: in std_logic;
		rst		: in std_logic; 
		RD_EN		: in std_logic;
		data	   : out std_logic_vector (15 downto 0 );
		Kout		: out std_logic_vector (1 downto 0 )                             
	);	                                                                          
end COMPONENT; 

                                                                  		  
----------------------- SCRIVE FILE --------------                                
COMPONENT WRITE_FILE is                                                           
generic ( out_data_path  : string   );	          
   Port ( CLK 		   : in  STD_LOGIC;                                             
          WR_EN 		: in  STD_LOGIC;                                       
          DATA_IN 	: in  STD_LOGIC_VECTOR (15 downto 0));
end COMPONENT;
--------------------------------------------------------------
	 
	 
	--TYPE D_ARRAY_Type IS array (0 to 7) of std_logic_vector(15 downto 0); 

   --Inputs
   signal CLK150 		: std_logic := '0';
   signal RESET 		: std_logic  := '1';
   signal Slow_DIN 			: std_logic_vector(3 downto 0) := (others => '0');
   signal Serial_USB 		: std_logic := '0'; -- 1 = USB
   -- SERIALE
   signal req_read_fifo 	: std_logic := '0';
   signal busy_Tx 			: std_logic := '0';
	-- USB 
   signal USB_CLK 			: std_logic := '0';
	signal PK_ACK				: std_logic := '0';
  --    GTX     
   signal   Data_to_FIFO_0 :  STD_LOGIC_VECTOR (15 downto 0):= (others => '0');
   signal   Kin_0 			:  STD_LOGIC := '0';
	signal	Rec_CLK_0 		:  STD_LOGIC := '0'; -- Recovered a 150MHz
	signal	RX_ALLIN_0		:  STD_LOGIC := '1';    --  RX _ ALLINEATO
			  
	signal	Data_to_FIFO_1 : STD_LOGIC_VECTOR (15 downto 0):= (others => '0');
   signal   Kin_1 			:  STD_LOGIC := '0';
	signal	Rec_CLK_1 		:  STD_LOGIC := '0'; -- Recovered a 150MHz
	signal	RX_ALLIN_1		:  STD_LOGIC := '1';   --  RX _ ALLINEATO		
  
   --  Event Counter Writer
   signal   EC          	: STD_LOGIC_VECTOR (11 downto 0):= (others => '0');
	--signal	Trg_Pat	  		: STD_LOGIC_VECTOR (11 downto 0):= (others => '0');
	signal	GLTRG       	:  STD_LOGIC := '0';
 
 	--  Outputs -----------------------------------
   signal Data_to_Serial 	: std_logic_vector(7 downto 0);
	signal Send_Data 			: std_logic;
   signal Data_to_USB 		: std_logic_vector(15 downto 0); 
   signal FIFO_nEmpty 		: std_logic;	
   signal ACQ_BUSY 			: std_logic;

   -- Clock period definitions
	constant  Rec_CLK_0_Period : time := 6.4 ns;  -- 150MHz Recovered Ref CLK 
	constant  Rec_CLK_1_Period : time := 6.8 ns;  -- 150MHz Recovered Ref CLK
   constant CLK150_period 		: time := 6.666667 ns;  -- 150MHz Ref CLK
	constant USB_CLK_period 	: time := 20.83334 ns; -- 48MHz
	constant CLK25_period   	: time := 40 ns;       -- 25MHz

----------------------------------------------------
   --        MIEI ----
	
signal clk25	:  STD_LOGIC := '0';

signal CONTA25  : std_logic_vector(31 downto 0) := (others => '0'); -- CONTATORE 25
signal VRD_EN   :   std_logic_vector(1 downto 0) := (others => '0'); -- Abilita la lettura da FILE


signal Kout_Z : std_logic_vector(1 downto 0) := (others => '0');
signal Kout_U : std_logic_vector(1 downto 0) := (others => '0');
signal conta_150M : std_logic_vector(3 downto 0) := (others => '0');
signal flag_Inizio_Ev :  STD_LOGIC := '0';

CONSTANT MAX_T_Out :   std_logic_vector(15 downto 0) := x"002F"; -- Abilita la lettura da FILE
       
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ALL_FIFO_Daisy
   GENERIC MAP ( MAX_T_Out => MAX_T_Out )
	PORT MAP (
          CLK150 				=> CLK150,
          RESET 				=> RESET,
	 ---   Slow Controll
			 Slow_DIN 			=> Slow_DIN ,	
			 Serial_USB 		=> Serial_USB ,
			 
	  --  Connessione della Seriale	( OUT Dati )
          req_read_fifo 	=> req_read_fifo, 
          busy_Tx 			=>	busy_Tx 		,
          Data_to_Serial 	=> Data_to_Serial,
          Send_Data 			=> Send_Data ,		
			 
		--   USB	 Det_fiber_OK => Det_fiber_OK,
		    Data_to_USB 		=>	Data_to_USB,
      	 USB_CLK     		=>	USB_CLK    ,
      	 FIFO_nEmpty 		=>	FIFO_nEmpty,
			 PK_ACK    			=>	PK_ACK  , 
			 
		 --    Ingressi dai GTX
          Data_to_FIFO_0  	=>	Data_to_FIFO_0,
          Kin_0 				=>	Kin_0 ,			
			 Rec_CLK_0 			=> Rec_CLK_0, 		
			 RX_ALLIN_0			=> RX_ALLIN_0	,	
			                     
			 Data_to_FIFO_1 	=> Data_to_FIFO_1,
          Kin_1 				=> Kin_1 ,			
			 Rec_CLK_1 			=> Rec_CLK_1, 		
			 RX_ALLIN_1			=> RX_ALLIN_1	,	

--  Globale
          ACQ_BUSY 			=> ACQ_BUSY,

--  Event Counter Writer
         EC          		=> EC,
		--	Trg_Pat	  			=> Trg_Pat, 
			GLTRG       		=>  GLTRG	 );	
	
--------------------------------------------------------------------------


U_RD_0_FIFO : READ_FILE_Fibra_Format   ------   FILE EVENTI BLOCCO 0
generic map ( in_data_path   =>  "DATAFIFO/BLK_IN_0.TXT" )
	port map ( 	clk 		=> Rec_CLK_0 ,
					rst		=> RESET,
					RD_EN 	=>  VRD_EN(0) and not ACQ_BUSY ,  
					data 		=> Data_to_FIFO_0,
					Kout		=> Kout_Z);

U_RD_1_FIFO : READ_FILE_Fibra_Format   ------   FILE EVENTI BLOCCO 1
generic map ( in_data_path   => "DATAFIFO/BLK_IN_1.TXT" )
	port map ( 	clk 		=> Rec_CLK_1 ,
					rst		=> RESET,
					RD_EN 	=>  VRD_EN(1) and not ACQ_BUSY ,  
					data 		=> Data_to_FIFO_1,
					Kout		=> Kout_U);

---  Assegna il K
   Kin_0 <= Kout_Z(1);
	Kin_1 <= Kout_U(1);


--------------------------------
-- Genera i segnali di EC , di GLTRG  e trigger pattern da FILE EVENTI BLOCCO 0
Genera_GLTRG : Process (CLK150 , Reset )  ------------------  Processo a 150MHZ
   begin
if RESET = '1' then
    EC 		<= (others => '0');
	 GLTRG 	<= '0';
	-- Trg_Pat <= (others => '0');
	 conta_150M <= (others => '0');
	 flag_Inizio_Ev <= '0';
	  
elsif (CLK150'event and CLK150 = '1') then
    
	 if (Data_to_FIFO_0(15 downto 12) = X"E")	and  (flag_Inizio_Ev = '0') then 
					EC 	<= Data_to_FIFO_0(11 downto 0) ;
					GLTRG <= '1';
					conta_150M <= X"2";
				--	Trg_Pat <= Trg_Pat +1 ;
					flag_Inizio_Ev <='1';
	 elsif 	(Data_to_FIFO_0(15 downto 12) = X"D")	and  (flag_Inizio_Ev = '1') then
  	            flag_Inizio_Ev <= '0';
					
	 else     EC 		<= EC;
				-- Trg_Pat <= Trg_Pat ;
				if( conta_150M = X"0" )then
						GLTRG <= '0';
						else
						conta_150M <= conta_150M-1;
					 end if;
	 end if;
	        
	  
end if;
end process;


----------------  Lettura dei DATI da  USB e scrittura in FILE  -------------------------

U_OUT_FILE : WRITE_FILE  ---------------  WRITE FILE
generic map ( out_data_path   => "DATAFIFO/TB_ALL_OUT.TXT" )
	port map ( 	clk 		=> USB_CLK ,
					WR_EN 	=> PK_ACK   ,  
					DATA_IN 	=> Data_to_USB  );   

----

 CLK150_process :process (USB_CLK , Reset )  ------------------  Processo Legge Dati da USB
   begin
     if RESET = '1' then
			PK_ACK <= '0' ;
	  
	  elsif (USB_CLK'event and USB_CLK = '1') then
	      PK_ACK <= FIFO_nEmpty ;

   end if;
   end process;

---------------------------------------------------------------------------



				--    SLOW CONTROLL
 CLK25_process :process (CLK25 , RESET )  -------------------  PROCESSO a 25MHZ
   begin
     if RESET = '1' then
	  
	  CONTA25 		<= (others => '0');
	  Serial_USB   <= '1'; --  USB or RS232 
	  Slow_DIN 		<= X"0"; -- Abilita le diverse FIFO
	  VRD_EN <= "00" ; -- Abilita la scrittura delle fifo tramite file
	  
	  elsif (CLK25'event and CLK25 = '1') then
	  CONTA25 <= CONTA25 +1 ; -----   CONTA 25
	  
		if CONTA25 = 3   then  Slow_DIN <= X"F";   		-- WR  BLOCK_ID L
		

      elsif CONTA25 > 120 and CONTA25 < 210 then 	VRD_EN <= "11" ; 
		elsif CONTA25 = 210                   then   VRD_EN <= "00" ; 
		elsif CONTA25 = 510                   then   VRD_EN <= "11" ; 
			
		else         Slow_DIN <= X"F"; VRD_EN <= "11" ; 
	      end if;
			
	end if;		
   end process;

--------------------------------------------------------------------------
   -- Clock process definitions
   CLK_CLK150 :process  		-- 150MHZ
   begin
		CLK150 <= '0';
		wait for CLK150_period/2;
		CLK150 <= '1';
		wait for CLK150_period/2;
   end process;
	
	   CLK_USB_CLK :process		-- CLK USB 48MHz
   begin
		USB_CLK <= '0';
		wait for USB_CLK_period/2;
		USB_CLK <= '1';
		wait for USB_CLK_period/2;
   end process;

 
   CLK_CLK25 :process     -- CLK a 25MHz
   begin
		CLK25 <= '0';
		wait for CLK25_period/2;
		CLK25 <= '1';
		wait for CLK25_period/2;
   end process;
	
	C_Rec_CLK_0 : process -- recovered 150MHz GTX 0 
    begin
		Rec_CLK_0 <= '0';
		wait for Rec_CLK_0_Period/2;
		Rec_CLK_0 <= '1';
		wait for Rec_CLK_0_Period/2;
   end process;
	
	C_Rec_CLK_1 : process -- recovered 150MHz GTX 1 
    begin
		Rec_CLK_1 <= '0';
		wait for Rec_CLK_1_Period/2;
		Rec_CLK_1 <= '1';
		wait for Rec_CLK_1_Period/2;
   end process;

   -- RESET ---
   stim_proc: process
   begin		
      RESET <='1';
      wait for 100 ns;	
       RESET <='0';
      wait;
   end process;

END;
