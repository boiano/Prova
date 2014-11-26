library IEEE;
library UNISIM;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use UNISIM.VComponents.all;

entity Manager_FIFO_2 is
    Port ( --rd_clk : IN std_logic; -- ref CLK a 150MHz
			  wr_clk : IN std_logic; -- Recovered a 150MHz
           rst : in  STD_LOGIC;
	--  Connessione della Seriale		  
--           req_read_fifo : in  STD_LOGIC;
--           busy_Tx : in  STD_LOGIC;
--           Data_to_Serial : out  STD_LOGIC_VECTOR (7 downto 0);
--           Send_Data : out  STD_LOGIC;
	--   USB
           Data_to_USB 	: out  STD_LOGIC_VECTOR (15 downto 0);
			  USB_CLK     	: in  STD_LOGIC;
			  FIFO_nEmpty 	: out  STD_LOGIC;
			  PK_ACK    	: in   STD_LOGIC;         			  
				
	--  WR FIFO 
			  en_wrt_fifo	: in  STD_LOGIC;
			  almost_full :  out  STD_LOGIC;
--			  Serial_USB  : in  STD_LOGIC; -- Select flusso _USB o Seriale
			  
           Data_to_FIFO : in  STD_LOGIC_VECTOR (15 downto 0);
           Kin : in  STD_LOGIC);
end Manager_FIFO_2;

architecture Behavioral of Manager_FIFO_2 is

--component Reader_FIFO is
--     Port (clk : in  STD_LOGIC;
--           rst : in  STD_LOGIC;
--           req_read_fifo : in  STD_LOGIC;
--           Data_from_Fifo : in  STD_LOGIC_VECTOR (15 downto 0);
--           busy_Tx : in  STD_LOGIC;
--			  empty_fifo: in  STD_LOGIC;
--			  read_fifo : out  STD_LOGIC:= '0';
--           Data_to_Serial : out  STD_LOGIC_VECTOR (7 downto 0);
--           Send_Data : out  STD_LOGIC);
--end component Reader_FIFO;


COMPONENT fifo_ram  --- FIFO 
	port (
		rst 		: IN STD_LOGIC;
		wr_clk 	: IN STD_LOGIC;
		rd_clk 	: IN STD_LOGIC;
		din 		: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		wr_en 	: IN STD_LOGIC;
		rd_en 	: IN STD_LOGIC;
		dout 		: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		full 		: OUT STD_LOGIC;
		empty 	: OUT STD_LOGIC;
		prog_full : OUT STD_LOGIC) ;
END  COMPONENT;
			

signal Data_from_Fifo :  STD_LOGIC_VECTOR(15 downto 0);
signal empty_fifo, read_fifo  : STD_LOGIC;
signal wr_en, xwr_en : STD_LOGIC;
--signal rd_clk_FIFO   : STD_LOGIC;
signal read_fifo_RS  : STD_LOGIC;
signal rd_fifo_USB   : STD_LOGIC;
signal Empty_Fifo_x_SERIALE :  STD_LOGIC;

signal RES_CONTA_BYTE 	:  STD_LOGIC_VECTOR(2 downto 0);
signal RES_CONTA_BYTEr 	:  STD_LOGIC_VECTOR(2 downto 0);
signal Timeout_Det 		:  STD_LOGIC_VECTOR(7 downto 0);
signal Det_fiber_OK 		: STD_LOGIC;
--
--   Per chipscope 
attribute keep : string;
attribute keep of almost_full 	: signal is "true";
attribute keep of wr_en   			: signal is "true";
attribute keep of Data_to_FIFO   : signal is "true";
attribute keep of empty_fifo   	: signal is "true";
attribute keep of Det_fiber_OK   : signal is "true";
attribute keep of en_wrt_fifo   	: signal is "true";
attribute keep of xwr_en   		: signal is "true";

begin
			
Memory: fifo_ram --    FIFO
	Port map( 	rd_clk 			=> USB_CLK 	,      --XX                 
					wr_clk 			=> wr_clk 	,                  
					din 				=> Data_to_FIFO,               
					rd_en 			=> read_fifo	,  --XX              
					rst 				=> not xwr_en	 , -- Resetta la FIFO se non abilitata              
					wr_en 			=> wr_en		,               
					dout 				=> Data_from_Fifo	, --x            
					empty 			=> empty_fifo 		, --x
					prog_full 		=> almost_full,					
					full 				=> open		);           
                                                     
--Lettura_FIFO: Reader_FIFO
--	Port map( 	clk 				=> rd_clk			,
--					Rst 				=> rst 			   ,
--					req_read_fifo	=> req_read_fifo	,
--					Data_from_Fifo => Data_from_Fifo ,
--					busy_Tx        => busy_Tx        ,
--					empty_fifo     => Empty_Fifo_x_SERIALE  ,
--					read_fifo      => read_fifo_RS		,
--					Data_to_Serial	=> Data_to_Serial	,
--					Send_Data      => Send_Data		);
--					
--   Empty_Fifo_x_SERIALE <=  empty_fifo  or  Serial_USB ;
-- Connessione a USB

	Data_to_USB 	<= 	Data_from_Fifo ;		-- Collega il bus DATI	
--	FIFO_nEmpty 	<=		(not empty_fifo) and  xwr_en and Serial_USB  ; 					
	FIFO_nEmpty 	<=		(not empty_fifo) and  xwr_en ; 					
					

-- MUX 
 -- Processo combinatoriale
--Process (Serial_USB, read_fifo_RS, rd_fifo_USB, read_fifo, PK_ACK)
-- begin
--      if Serial_USB = '1' THEN read_fifo <= PK_ACK;					
--		  else                   read_fifo <= read_fifo_RS;
--		  end if;			
--end process;
	
-- CLK MUX 
--    BUFGMUX_CTRL_inst : BUFGMUX_CTRL
--   port map (
--      O =>  rd_clk_FIFO,    -- Clock MUX output
--      I0 => rd_clk ,  -- Clock0 dalla seriale
--      I1 => USB_CLK,  -- Clock1 USB
--      S => Serial_USB     -- Clock select input
--   );


--              ************    Protezione  Contro DE_LOOK Fibra ***************
--   Protezione contro DE_LOOCK Fibra + 
--   Sincronizza       EN / DIS  FIFO  restituisce "xwr_en"
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

	elsif ( Kin = '1' and RES_CONTA_BYTEr /= "100" )  or ( Kin = '0' and RES_CONTA_BYTEr = "100" )
						then
	                         Timeout_Det <= X"00" ;
									 Det_fiber_OK <= '0' ; 
		end if ;
		
		
		
	end if;
end process;
-----------------------------------------------------------------------------------------------


--    Processo combinatoriale per WREN della fifo
Comb_Proc : process ( xwr_en, Kin  , Data_to_FIFO )
begin
if  xwr_en = '1' and  Kin = '0' and  Data_to_FIFO /= X"8080"  then
											wr_en  <= '1' ;
				else
                                  wr_en  <= '0' ;
						end if;

end process ;
read_fifo <= PK_ACK;
end Behavioral;

