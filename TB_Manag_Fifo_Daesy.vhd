--------------------------------------------------------------------------------
-- TB Fifo Daesy
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
 
 
ENTITY TB_Manag_Fifo_Daesy IS
END TB_Manag_Fifo_Daesy;
 
ARCHITECTURE behavior OF TB_Manag_Fifo_Daesy IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Manag_FIFO_Daisy
	 GENERIC ( MAX_T_Out : STD_LOGIC_VECTOR (15 downto 0) := X"000F");
    PORT(
         rd_clk : IN  std_logic;
         wr_clk : IN  std_logic;
         rst : IN  std_logic;
         ECProposed : IN  std_logic_vector(11 downto 0);
         REN : IN  std_logic;
         PASSO : OUT  std_logic;
         Busy : IN  std_logic;
         Data_in : IN  std_logic_vector(15 downto 0);
         Data_Out : OUT  std_logic_vector(15 downto 0);
         WR_EN_in : IN  std_logic;
         WR_EN_out : OUT  std_logic;
         en_wrt_fifo : IN  std_logic;
         almost_full : OUT  std_logic;
         Data_to_FIFO : IN  std_logic_vector(15 downto 0);
         Kin : IN  std_logic
        );
    END COMPONENT;
	 
----------------------   LEGGE FILE -----------                          
COMPONENT READ_FILE_Fibra_Format                                                     	    
	generic ( in_data_path  : string := "DATAFIFO_Modulo/LOC_FIFO_Lento.TXT"  );	                                            
                                       
	port (                                                                         			  
		clk		: in std_logic;
		rst		: in std_logic; 
		RD_EN		: in std_logic;
		data	   : out std_logic_vector (15 downto 0 );
		Kout		: out std_logic_vector (1 downto 0 )                             
	);	                                                                          
end COMPONENT; 

   --Inputs
   signal rd_clk : std_logic := '0';
   signal wr_clk : std_logic := '0';
   signal rst : std_logic := '1';
   signal ECProposed : std_logic_vector(11 downto 0) := (others => '0');
   signal REN : std_logic := '0';
   signal Busy : std_logic := '0';
   signal Data_in : std_logic_vector(15 downto 0) := (others => '0');
   signal WR_EN_in : std_logic := '0';
   signal en_wrt_fifo : std_logic := '0';
   signal Data_to_FIFO : std_logic_vector(15 downto 0) := (others => '0');
   signal Kin : std_logic_vector(1 downto 0) := (others => '0');

 	--Outputs
   signal PASSO : std_logic;
   signal Data_Out : std_logic_vector(15 downto 0);
   signal WR_EN_out : std_logic;
   signal almost_full : std_logic;

   -- Clock period definitions
   constant rd_clk_period : time := 10 ns;
   constant wr_clk_period : time := 11.111111 ns;
	
	--   Interni  Miei
	signal RD_EN 	:std_logic :='0';
	signal intDel 	:std_logic :='0';
	signal flag_primo :std_logic :='0';
	
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Manag_FIFO_Daisy 
	GENERIC MAP ( MAX_T_Out => X"000F")
	PORT MAP (
          rd_clk 	=> rd_clk,
          wr_clk 	=> wr_clk,
          rst 		=> rst,
			 
          ECProposed => ECProposed,
          REN 			=> REN,
          PASSO 		=> PASSO,
          Busy 		=> Busy,
          Data_in 	=> Data_in,
          Data_Out 	=> Data_Out,
          WR_EN_in 	=> WR_EN_in,
          WR_EN_out 	=> WR_EN_out,
          en_wrt_fifo => en_wrt_fifo, -- Slow control
			 
          almost_full => almost_full,
          Data_to_FIFO => Data_to_FIFO,
          Kin => Kin(1)
        );



File_Data_FIBRA : READ_FILE_Fibra_Format   ------   FILE EVENTI dall Blockcard
--generic map ( in_data_path   =>  "DATAFIFO/OUT_GLOBAL_FIFO.TXT" )
generic map ( in_data_path   =>  "DATAFIFO/BLK_IN_0.TXT" )
port map ( 
				clk 	=> wr_clk , 
				rst 	=> rst,
				RD_EN => RD_EN , 
				Kout => Kin,					
				data	=> Data_to_FIFO );
-----------------------------------

   -- Clock process definitions
   rd_clk_process :process
   begin
		rd_clk <= '0';
		wait for rd_clk_period/2;
		rd_clk <= '1';
		wait for rd_clk_period/2;
   end process;
 
   wr_clk_process :process
   begin
		wr_clk <= '0';
		wait for wr_clk_period/2;
		wr_clk <= '1';
		wait for wr_clk_period/2;
   end process;
 
 
    -- Daesy  Processo   Lettura
Deesy_process :process (rd_clk, rst)
   begin                               
		if rst = '1'  then
		REN <= '0' ;
		ECProposed <= X"FF0";
		flag_primo <= '0';
		
		elsif  (rd_clk ='1' and rd_clk'Event) then -- _|- fronte
			 
			 if   flag_primo = '0' and  PASSO = '0' and REN = '0' and intDel = '1'  and almost_full = '0' then
			      REN <= '1' ;
					
					flag_primo <= '1' ;
					
				elsif REN = '1' and  PASSO = '1' THEN
				   REN <= '0' ;
					flag_primo <= '0';
					ECProposed <= ECProposed + X"001";
				 end if;
				
		end if;
  end process;


--  Processo X Scrittura e BUSY per HF fifo
CLK_Proc_WR : Process ( rst , wr_clk)
begin
	if rst='1' then -- RESET
		 RD_EN <= '0' ;
		
	elsif (wr_clk='1' and wr_clk'Event) then    --- ___|----  Fronte clk
	
		
		if almost_full = '0'  and intDel = '1' then  --  Gestione Half FULL X scritture FIFO CANALE
		      RD_EN <= '1';
			else
			    RD_EN <= '0' ;
				end if;
	end if;
	end process;
 ----------------------------------------------------
 
 
 
   -- Stimulus process
   stim_proc: process
   begin		
     rst <= '1';
      wait for 100 ns;	
	 rst <= '0';
	 
	 wait for rd_clk_period*2;
	 
	 en_wrt_fifo <= '1';
	 
	 wait for rd_clk_period*22;
	 
	   intDel <= '1';
		
		

    --  ECProposed <= X"001";
		
--      wait for rd_clk_period*10; GLTRG <= '1'; 	wait for rd_clk_period ; GLTRG <= '0'; ECProposed <= X"002";
--		wait for rd_clk_period*12; GLTRG <= '1'; 	wait for rd_clk_period ; GLTRG <= '0'; ECProposed <= X"003";
--		wait for rd_clk_period*4;  GLTRG <= '1'; 	wait for rd_clk_period ; GLTRG <= '0'; ECProposed <= X"004";
--		wait for rd_clk_period*22; GLTRG <= '1'; 	wait for rd_clk_period ; GLTRG <= '0'; ECProposed <= X"005";
--		wait for rd_clk_period*13; GLTRG <= '1'; 	wait for rd_clk_period ; GLTRG <= '0'; ECProposed <= X"006"; Busy <= '1';
--		wait for rd_clk_period*5;  GLTRG <= '1'; 	wait for rd_clk_period ; GLTRG <= '0'; ECProposed <= X"007"; 
--		wait for rd_clk_period*8; GLTRG <= '1'; 	wait for rd_clk_period ; GLTRG <= '0'; ECProposed <= X"008";
--		wait for rd_clk_period*9; GLTRG <= '1'; 	wait for rd_clk_period ; GLTRG <= '0'; ECProposed <= X"009"; Busy <= '0';
--		wait for rd_clk_period*2; GLTRG <= '1'; 	wait for rd_clk_period ; GLTRG <= '0'; ECProposed <= X"00A";
--		wait for rd_clk_period*7; GLTRG <= '1'; 	wait for rd_clk_period ; GLTRG <= '0'; ECProposed <= X"00B";


      -- insert stimulus here 

      wait;
   end process;

END;
