--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:56:08 06/25/2012
-- Design Name:  Alfonso INFN Na  
--
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 

 
ENTITY TB_Modulo_EC_Last IS
END TB_Modulo_EC_Last;
 
ARCHITECTURE behavior OF TB_Modulo_EC_Last IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Modulo_EC_LAST
    PORT(
         f150MHz : IN  std_logic;
         Reset : IN  std_logic;
         Busy : IN  std_logic;
         HFull : OUT  std_logic;
         GLTRG : IN  std_logic;
         EC_Fibra : IN  std_logic_vector(11 downto 0);
         ECProposed : OUT  std_logic_vector(11 downto 0);
         EC_Valido : OUT  std_logic;
         REN : IN  std_logic;
         PASSo : OUT  std_logic;
         WR_EN_out : OUT  std_logic;
         Data_Out : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
  
   signal f150MHz : std_logic := '0';
   signal Reset : std_logic := '1';
   signal Busy : std_logic := '0';
   signal GLTRG : std_logic := '0';
   signal EC_Fibra : std_logic_vector(11 downto 0) := (others => '0');
   signal REN : std_logic := '0';

 	--Outputs
   signal HFull : std_logic;
   signal ECProposed : std_logic_vector(11 downto 0);
   signal EC_Valido : std_logic;
   signal PASSo : std_logic;
   signal WR_EN_out : std_logic;
   signal Data_Out : std_logic_vector(15 downto 0);
	
	signal delay_REN  : std_logic_vector(7 downto 0) := (others => '0');
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
   constant f50MHz_period  : time := 20 ns;
	constant f150MHz_period : time := 6.66666666 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Modulo_EC_LAST PORT MAP (
          f150MHz => f150MHz,
          Reset => Reset,
          Busy => Busy,
          HFull => HFull,
          GLTRG => GLTRG,
          EC_Fibra => EC_Fibra,
          ECProposed => ECProposed,
          EC_Valido => EC_Valido,
          REN => REN,
          PASSo => PASSo,
          WR_EN_out => WR_EN_out,
          Data_Out => Data_Out
        );

   -- Clock process definitions
	
	   f150MHz_process :process
   begin
		f150MHz <= '0';
		wait for f150MHz_period/2;
		f150MHz <= '1';
		wait for f150MHz_period/2;
   end process;
 

   -- Stimulus process
ST_CLK_process :process (f150MHz, reset)
   begin
		if reset = '1'  then
		REN <= '0' ;
		delay_REN <= (others => '0');
		elsif  (f150MHz ='1' and f150MHz'Event) then -- _|- fronte
			 
			 if  EC_Valido = '1' and  PASSo = '0' and REN = '0' then
			     delay_REN <= delay_REN +1 ;
				   if delay_REN > X"06" then
			           REN <= '1' ;
					 end if;
				elsif REN = '1' and  PASSo = '1' THEN
				   REN <= '0' ;
					delay_REN <= (others => '0');
				 end if;
				
		end if;
                 			 
   end process;
	
	
	
	
-- Stimolo per GLTRG	
   stim_proc: process
   begin		
     Reset <= '1';
      wait for 100 ns;	
     Reset <= '0';
	  EC_Fibra <= X"001";
	   wait for f50MHz_period*10; GLTRG <= '1'; 	wait for f50MHz_period ; GLTRG <= '0'; EC_Fibra <= X"001";
      wait for f50MHz_period*10; GLTRG <= '1'; 	wait for f50MHz_period ; GLTRG <= '0'; EC_Fibra <= X"002";
		wait for f50MHz_period*12; GLTRG <= '1'; 	wait for f50MHz_period ; GLTRG <= '0'; EC_Fibra <= X"003";
		wait for f50MHz_period*4; GLTRG <= '1'; 	wait for f50MHz_period ; GLTRG <= '0'; EC_Fibra <= X"004";
		wait for f50MHz_period*22; GLTRG <= '1'; 	wait for f50MHz_period ; GLTRG <= '0'; EC_Fibra <= X"005";
		wait for f50MHz_period*13; GLTRG <= '1'; 	wait for f50MHz_period ; GLTRG <= '0'; EC_Fibra <= X"006"; Busy <= '1';
		wait for f50MHz_period*5; GLTRG <= '1'; 	wait for f50MHz_period ; GLTRG <= '0'; EC_Fibra <= X"007"; 
		wait for f50MHz_period*8; GLTRG <= '1'; 	wait for f50MHz_period ; GLTRG <= '0'; EC_Fibra <= X"008";
		wait for f50MHz_period*9; GLTRG <= '1'; 	wait for f50MHz_period ; GLTRG <= '0'; EC_Fibra <= X"009"; Busy <= '0';
		wait for f50MHz_period*2; GLTRG <= '1'; 	wait for f50MHz_period ; GLTRG <= '0'; EC_Fibra <= X"00A";
		wait for f50MHz_period*7; GLTRG <= '1'; 	wait for f50MHz_period ; GLTRG <= '0'; EC_Fibra <= X"00B";

      wait;
   end process;

END;
