--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:55:53 10/28/2011
-- Design Name:   
-- Module Name:   D:/PROGETTI/XILINX/LAVORI/FAZIA/Test_Card/Test_Card_V0/Prova0_0/Prova0/TB_LED.vhd
-- Project Name:  Prova0
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: LED
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
ENTITY TB_LED IS
END TB_LED;
 
ARCHITECTURE behavior OF TB_LED IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT LED
   port ( PulsanteA, CLK            :  in  STD_LOGIC; --  RESET e CLK a 25MHz
	       LedA, LedB, LedC			   : out std_logic;
			 SDO   	 						: out  STD_LOGIC;
			 SCK   	 						: out  STD_LOGIC;
			 LE_1PLL   						: out  STD_LOGIC;
			 LE_2PLL   						: out  STD_LOGIC;
			 PLL1_Locked, PLL2_Locked  :  in  STD_LOGIC ;
          SYNC                      : out  STD_LOGIC ;

 --  GTX  -------------
				CLK_150_N                :  in  STD_LOGIC; --   CLK a 150MHz
				CLK_150_P                :  in  STD_LOGIC; --   CLK a 150MHz
				CLK_25_N                 :  in  STD_LOGIC; --   CLK a 150MHz
				CLK_25_P                 :  in  STD_LOGIC; --   CLK a 150MHz				
				       


						--   3Gbit RX e TX    ----
				SFP_EN                     : out  std_logic;  -- Abilita il trasmettitore in fibra	 
	 
				RXN_IN               		: in   std_logic;       --
				RXP_IN                     : in   std_logic;
				TXN_OUT                    : out  std_logic;
				TXP_OUT                    : out  std_logic;
	
--   Seriale ------
            RS232_RX                   : out   std_logic;  -- Slow controll
				RS232_TX                   : in  std_logic; -- Slow controll
				
				RS232cmdRX						: in  std_logic;  -- comandi
				RS232cmdTX	 					: out   std_logic;  -- comandi
				
--   LEMO x TRIGGER
				LEMO_TRG_IN 					: in  std_logic; --
            LEMO_VETO_IN       			: in  std_logic; --
            LEMO_VETO_OUT         		: out   std_logic;  --
            LEMO_MAJ_OUT 					: out   std_logic;  --
			   LEMO_TRG_OUT 					: out   std_logic;  --

--		Monitoraggio

           TestPoint                      : out  std_logic_vector(17 downto 0) ); -- TEST POINT Connettore 20pin 
    END COMPONENT;
    

   --Inputs
   signal PulsanteA : std_logic := '0';
   signal CLK : std_logic := '0';

 	--Outputs
   signal LedA : std_logic;
   signal LedB : std_logic;
   signal LedC : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
	
	
	
	---------------------------------
	
	--   Per simulazione ANSIP
	
	---------------------------------
	
	signal CLK_1GHz 		: std_logic := '0';
	signal Conta_250M   : std_logic_vector (7 downto 0) := (others => '0'); 
	signal Conta_150M   : std_logic_vector (7 downto 0) := (others => '0'); 
	signal Conta_100M   : std_logic_vector (7 downto 0) := (others => '0'); 
	signal Conta_25M    : std_logic_vector (7 downto 0) := (others => '0'); 
   
   signal CLK_250pll  : std_logic := '0';
	signal CLK_100pll  : std_logic := '0';
   signal CLK_25pll   : std_logic := '0';
	signal CLK_150pll  : std_logic := '0';
	
	
   signal CLK_250_div  : std_logic := '0';
	signal CLK_100_div  : std_logic := '0';
   signal CLK_25_div   : std_logic := '0';
	signal CLK_150_div  : std_logic := '0';


   -- Clock period definitions
   constant Semiperiodo250M : time := 2 ns;
	constant Semiperiodo150M : time := 3333333 fs;
	constant Semiperiodo100M : time := 5 ns;
	constant Semiperiodo_25M : time := 20 ns;


	
	
	
	
	
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: LED PORT MAP (
          PulsanteA => PulsanteA,
          CLK => CLK,
          LedA => LedA,
          LedB => LedB,
          LedC => LedC
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ms.
      wait for 100 ms;	

      wait for CLK_period*10;

      -- insert stimulus here 

      wait;
   end process;

------------------------------------------------------------------------------
 --                SIMULAZIONE per ANSIP 
 --             clk PLL vs  clk divider
------------------------------------------------------------

CLK_1GHz_process :process
   begin
		CLK_1GHz <= '0';
		wait for 500 ps;
		CLK_1GHz <= '1';
		wait for 500 ps; 
   end process;


CLK_GENERATOR_process :process ( CLK_1GHz )
   begin
		
	if (CLK_1GHz ='1' and CLK_1GHz'Event) then    --- ___|----  Fronte clk
		 
		  if Conta_250M < X"02" then Conta_250M <= Conta_250M + 1;
		     else  Conta_250M <= (others => '0') ;
			     end if ;
				  
		  if Conta_150M < X"08" then Conta_150M <= Conta_150M + 1;
		     else  Conta_150M <= (others => '0') ;
			     end if ;
	
		  if Conta_100M < X"08" then Conta_100M <= Conta_100M + 1;
		     else  Conta_100M <= (others => '0') ;
			     end if ;	
		
		  if Conta_25M < X"28" then Conta_25M <= Conta_25M + 1;
		     else  Conta_25M <= (others => '0') ;
			     end if ;
		
		
	end if;
  end process;


---------------------------------------------

CLK_250MHz_PLL_process :process
   begin
		CLK_250pll <= '1';
		wait for 2 ns;
		CLK_250pll <= '0';
		wait for 2 ns; 
   end process;

CLK_100MHz_PLL_process :process
   begin
		CLK_100pll <= '1';
		wait for 5 ns;
		CLK_100pll <= '0';
		wait for 5 ns; 
   end process;
	
	
CLK_25MHz_PLL_process :process
   begin
		CLK_25pll <= '1';
		wait for 20 ns;
		CLK_25pll <= '0';
		wait for 20 ns; 
   end process;

CLK_150MHz_PLL_process :process
   begin
		CLK_150pll <= '1';
		wait for 3333333 fs;
		CLK_150pll <= '0';
		wait for 3333333 fs; 
   end process;



CLK_250MHz_process :process
   begin

		wait for Semiperiodo250M * 4;
		CLK_250_Div <= '0';
		wait for 2 ns; 
	   CLK_250_Div <= '1';
		wait for 2 ns;
		CLK_250_Div <= '0';
		wait for 2 ns; 
		CLK_250_Div <= '1';
		wait for 2 ns;
		CLK_250_Div <= '0';
		wait for 2 ns; 
	   CLK_250_Div <= '1';
		wait for 2 ns;
		CLK_250_Div <= '0';
		wait for 2 ns; 
	   CLK_250_Div <= '1';
		wait for 2 ns;
		CLK_250_Div <= '0';
		wait for 2 ns; 
		CLK_250_Div <= '1';
		wait for 2 ns;
		CLK_250_Div <= '0';
		wait for 2 ns; 
	   CLK_250_Div <= '1';
		wait for 2 ns;
		CLK_250_Div <= '0';
		wait for 2 ns; 
	   CLK_250_Div <= '1';
		wait for 2 ns;
		CLK_250_Div <= '0';
		wait for 2 ns; 
		CLK_250_Div <= '1';
		wait for 2 ns;
		CLK_250_Div <= '0';
		wait for 2 ns; 
		CLK_250_Div <= '1';
		wait for 2 ns;
		CLK_250_Div <= '0';
		wait for 2 ns; 
		CLK_250_Div <= '1';
		wait for 2 ns;
		CLK_250_Div <= '0';
		wait for 2 ns; 
	   CLK_250_Div <= '1';
		wait for 2 ns;
		CLK_250_Div <= '0';
		wait for 2 ns; 
	   CLK_250_Div <= '1';
		wait for 2 ns;
		CLK_250_Div <= '0';
		wait for 2 ns; 
		CLK_250_Div <= '1';
		wait for 2 ns;
		CLK_250_Div <= '0';
		wait for 2 ns; 
	   CLK_250_Div <= '1';
		wait for 2 ns;
		CLK_250_Div <= '0';
		wait for 2 ns; 
	   CLK_250_Div <= '1';
		wait for 2 ns;
		CLK_250_Div <= '0';
		wait for 2 ns; 
		CLK_250_Div <= '1';
		wait for 2 ns;
		CLK_250_Div <= '0';
		wait for 2 ns; 
		CLK_250_Div <= '1';
		wait for 2 ns;
		CLK_250_Div <= '0';
		wait for 2 ns; 
		CLK_250_Div <= '1';
		wait for 2 ns;
		CLK_250_Div <= '0';
		wait for 2 ns; 
	   CLK_250_Div <= '1';
		wait for 2 ns;
		CLK_250_Div <= '0';
		wait for 2 ns; 
	   CLK_250_Div <= '1';
		wait for 2 ns;
		CLK_250_Div <= '0';
		wait for 2 ns; 
		CLK_250_Div <= '1';
		wait for 2 ns;
		CLK_250_Div <= '0';
		wait for 2 ns; 
	   CLK_250_Div <= '1';
		wait for 2 ns;
		CLK_250_Div <= '0';
		wait for 2 ns; 
	   CLK_250_Div <= '1';
		wait for 2 ns;
		CLK_250_Div <= '0';
		wait for 2 ns; 
		CLK_250_Div <= '1';
		wait for 2 ns;
		CLK_250_Div <= '0';
		wait for 2 ns; 
   end process;






CLK_100MHz_process :process
   begin
		wait for Semiperiodo100M * 4;
		CLK_100_Div <= '0';
		wait for 5 ns;
		CLK_100_Div <= '1';
		wait for 5 ns;
		CLK_100_Div <= '0';
		wait for 5 ns;
	   CLK_100_Div <= '1';
		wait for 5 ns;
		CLK_100_Div <= '0';
		wait for 5 ns;
		CLK_100_Div <= '1';
		wait for 5 ns;
		CLK_100_Div <= '0';
		wait for 5 ns; 
	   CLK_100_Div <= '1';
		wait for 5 ns;
		CLK_100_Div <= '0';
		wait for 5 ns;
		CLK_100_Div <= '1';
		wait for 5 ns;
		CLK_100_Div <= '0';
		wait for 5 ns;
	   CLK_100_Div <= '1';
		wait for 5 ns;
		CLK_100_Div <= '0';
		wait for 5 ns;
		CLK_100_Div <= '1';
		wait for 5 ns;
		CLK_100_Div <= '0';
		wait for 5 ns; 
		CLK_100_Div <= '1';
		wait for 5 ns;
		CLK_100_Div <= '0';
		wait for 5 ns;
		CLK_100_Div <= '1';
		wait for 5 ns;
		CLK_100_Div <= '0';
		wait for 5 ns; 
	   CLK_100_Div <= '1';
		wait for 5 ns;
		CLK_100_Div <= '0';
		wait for 5 ns;
		CLK_100_Div <= '1';
		wait for 5 ns;
		CLK_100_Div <= '0';
		wait for 5 ns;
	   CLK_100_Div <= '1';
		wait for 5 ns;
		CLK_100_Div <= '0';
		wait for 5 ns;
		CLK_100_Div <= '1';
		wait for 5 ns;
		CLK_100_Div <= '0';
		wait for 5 ns; 
   end process;
	
	
	
	
CLK_25MHz_process :process
   begin
		CLK_25_Div <= '1';
		wait for 20 ns;
		CLK_25_Div <= '0';
		wait for 20 ns; 
   end process;




CLK_150MHz_process :process
   begin
	   wait for Semiperiodo150M * 2;
	   CLK_150_Div <= '1';
		wait for Semiperiodo150M;
		CLK_150_Div <= '0';
		wait for Semiperiodo150M;
	   CLK_150_Div <= '1';
		wait for Semiperiodo150M;
		CLK_150_Div <= '0';
		wait for Semiperiodo150M;
		CLK_150_Div <= '1';
		wait for Semiperiodo150M;
		CLK_150_Div <= '0';
		wait for Semiperiodo150M; 
	   CLK_150_Div <= '1';
		wait for Semiperiodo150M;
		CLK_150_Div <= '0';
		wait for Semiperiodo150M;
	   CLK_150_Div <= '1';
		wait for Semiperiodo150M;
		CLK_150_Div <= '0';
		wait for Semiperiodo150M;
		CLK_150_Div <= '1';
		wait for Semiperiodo150M;
		CLK_150_Div <= '0';
		wait for Semiperiodo150M;
	   CLK_150_Div <= '1';
		wait for Semiperiodo150M;
		CLK_150_Div <= '0';
		wait for Semiperiodo150M;
	   CLK_150_Div <= '1';
		wait for Semiperiodo150M;
		CLK_150_Div <= '0';
		wait for Semiperiodo150M;
		CLK_150_Div <= '1';
		wait for Semiperiodo150M;
		CLK_150_Div <= '0';
		wait for Semiperiodo150M; 
	   CLK_150_Div <= '1';
		wait for Semiperiodo150M;
		CLK_150_Div <= '0';
		wait for Semiperiodo150M;
	   CLK_150_Div <= '1';
		wait for Semiperiodo150M;
		CLK_150_Div <= '0';
		wait for Semiperiodo150M;
		CLK_150_Div <= '1';
		wait for Semiperiodo150M;
		CLK_150_Div <= '0';
		wait for Semiperiodo150M; 
		CLK_150_Div <= '1';
		wait for Semiperiodo150M;
		CLK_150_Div <= '0';
		wait for Semiperiodo150M;
	   CLK_150_Div <= '1';
		wait for Semiperiodo150M;
		CLK_150_Div <= '0';
		wait for Semiperiodo150M;
		CLK_150_Div <= '1';
		wait for Semiperiodo150M;
		CLK_150_Div <= '0';
		wait for Semiperiodo150M;
	   CLK_150_Div <= '1';
		wait for Semiperiodo150M;
		CLK_150_Div <= '0';
		wait for Semiperiodo150M;
	   CLK_150_Div <= '1';
		wait for Semiperiodo150M;
		CLK_150_Div <= '0';
		wait for Semiperiodo150M;
		CLK_150_Div <= '1';
		wait for Semiperiodo150M;
		CLK_150_Div <= '0';
		wait for Semiperiodo150M; 
	   CLK_150_Div <= '1';
		wait for Semiperiodo150M;
		CLK_150_Div <= '0';
		wait for Semiperiodo150M;
	   CLK_150_Div <= '1';
		wait for Semiperiodo150M;
		CLK_150_Div <= '0';
		wait for Semiperiodo150M;
		CLK_150_Div <= '1';
		wait for Semiperiodo150M;
		CLK_150_Div <= '0';
		wait for Semiperiodo150M; 
   end process;















END;
