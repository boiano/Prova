--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:50:38 01/18/2011
-- Design Name:   
-- Module Name:   D:/PROGETTI/XILINX/LAVORI/FAZIA/Giordano2/fixed_lateny2/TB_GTX_FISSO_top_Modificato.vhd
-- Project Name:  GTX_FISSO_MIO
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: GTX_FISSO_TOP
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
 
ENTITY TB_GTX_FISSO_top_Modifi_noReset IS
END TB_GTX_FISSO_top_Modifi_noReset;
 
ARCHITECTURE behavior OF TB_GTX_FISSO_top_Modifi_noReset IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT GTX_FISSO_TOP
    PORT(
         tile0_refclk_i : IN  std_logic;
         RESET_DONE_OUT : OUT  std_logic;
         GTXRESET_IN : IN  std_logic;
         TILE0_PLLLKDET_OUT : OUT  std_logic;
         --TRACK_DATA_OUT : OUT  std_logic;
         GTX_Data_IN : IN  std_logic_vector(15 downto 0);
         K_Comma_IN : IN  std_logic_vector(1 downto 0);
        -- TX_User_CLK_IN : IN  std_logic;
         Ref_CLK_OUT : OUT  std_logic;
         TX_SYNC_DONE : OUT  std_logic;
         GTX_Data_OUT : OUT  std_logic_vector(15 downto 0);
         K_Comma_OUT : OUT  std_logic_vector(1 downto 0);
         RX_REC_CLK_OUT : OUT  std_logic;
         RX_ALLINEATO_OUT : OUT  std_logic;
         RXN_IN : IN  std_logic;
         RXP_IN : IN  std_logic;
         TXN_OUT : OUT  std_logic;
         TXP_OUT : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
		signal TILE0_REFCLK_PAD_P_IN : std_logic := '0';

		signal GTXRESET_IN : std_logic := '1';
   signal GTX_Data_IN : std_logic_vector(15 downto 0) := (others => '0');
   signal K_Comma_IN : std_logic_vector(1 downto 0) := (others => '0');
  -- signal TX_User_CLK_IN : std_logic := '0';
   signal RXN_IN : std_logic := '0';
   signal RXP_IN : std_logic := '0';

 	--Outputs
   signal RESET_DONE_OUT : std_logic;
   signal TILE0_PLLLKDET_OUT : std_logic;
   --signal TRACK_DATA_OUT : std_logic;
   signal Ref_CLK_OUT : std_logic;
   signal TX_SYNC_DONE : std_logic;
   signal GTX_Data_OUT : std_logic_vector(15 downto 0);
   signal K_Comma_OUT : std_logic_vector(1 downto 0);
   signal RX_REC_CLK_OUT : std_logic;
   signal RX_ALLINEATO_OUT : std_logic;
   signal TXN_OUT : std_logic;
   signal TXP_OUT : std_logic;
	
	
	 --  MIEI INTERNI
	 
	signal Tempo      : std_logic_vector(31 downto 0) := (others => '0'); 
	signal C150Mhz    : std_logic := '0';
	signal P_Vett_delay : std_logic_vector(200 downto 0) := (others => '0'); 
	signal N_Vett_delay : std_logic_vector(200 downto 0) := (others => '0'); 
	signal Gig_clk    : std_logic := '0';
	-- x reset
	signal GTXRESET_IN_ovf   : std_logic := '0';
	signal GTXRESET_IN_PWUP  : std_logic := '1';
	
	signal Conta_RESET  : std_logic_vector(7 downto 0) := (others => '0'); 
	signal Assestamento  : std_logic_vector(8 downto 0) := (others => '0'); 
	
	constant IN_K285 :  std_logic_vector (7 downto 0) := "10111100";  
	constant K_en    :  std_logic_vector (1 downto 0) := "10";
	
   --constant C150Mhz_period : time  := 6.66666666667 ns; -- C150Mhz
	constant C150Mhz_period : time  := 8 ns; -- C125Mhz
	constant Gig_period : time  := 0.10 ns; -- 10Giga
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: GTX_FISSO_TOP PORT MAP (
          tile0_refclk_i => TILE0_REFCLK_PAD_P_IN,
          RESET_DONE_OUT => RESET_DONE_OUT,
          GTXRESET_IN => GTXRESET_IN,
          TILE0_PLLLKDET_OUT => TILE0_PLLLKDET_OUT,
          --TRACK_DATA_OUT => TRACK_DATA_OUT,
          GTX_Data_IN => GTX_Data_IN,
          K_Comma_IN => K_Comma_IN,
         -- TX_User_CLK_IN => TX_User_CLK_IN,
          Ref_CLK_OUT => Ref_CLK_OUT,
          TX_SYNC_DONE => TX_SYNC_DONE,
          GTX_Data_OUT => GTX_Data_OUT,
          K_Comma_OUT => K_Comma_OUT,
          RX_REC_CLK_OUT => RX_REC_CLK_OUT,
          RX_ALLINEATO_OUT => RX_ALLINEATO_OUT,
          RXN_IN => RXN_IN,
          RXP_IN => RXP_IN,
          TXN_OUT => TXN_OUT,
          TXP_OUT => TXP_OUT
        );
 
---------------------------------------------------------------
	
--              ASSEGNA USCITE e segnali

---------------------------------------------------------------

TILE0_REFCLK_PAD_P_IN <=     C150Mhz ;

with Conta_RESET select	
	RXN_IN 	<=	N_Vett_delay(0)  when X"00" ,
					N_Vett_delay(100)  when X"01" ,
					N_Vett_delay(50)  when X"02" ,
					N_Vett_delay(70)  when X"03" ,
					N_Vett_delay(21)  when X"04" ,
					N_Vett_delay(43)  when X"05" ,
					N_Vett_delay(10)  when X"06" ,
					N_Vett_delay(85)  when X"07" ,
					N_Vett_delay(27)  when X"08" ,
					N_Vett_delay(37)  when X"09" ,
					N_Vett_delay(62)  when X"0A" ,
					N_Vett_delay(82)  when X"0b" ,

	            N_Vett_delay(140)  when others;

with Conta_RESET select	
	RXP_IN 	<=	P_Vett_delay(0)  when X"00" ,
					P_Vett_delay(100)  when X"01" ,
					P_Vett_delay(50)  when X"02" ,
					P_Vett_delay(70)  when X"03" ,
					P_Vett_delay(21)  when X"04" ,
					P_Vett_delay(43)  when X"05" ,
					P_Vett_delay(10)  when X"06" ,
					P_Vett_delay(85)  when X"07" ,
					P_Vett_delay(27)  when X"08" ,
					P_Vett_delay(37)  when X"09" ,
					P_Vett_delay(62)  when X"0A" ,
					P_Vett_delay(82)  when X"0b" ,

	            P_Vett_delay(140)  when others;



----------------------------------------------------------------

x_proc: process( Gig_clk )
begin
	  if rising_edge(Gig_clk) then
	  
		P_Vett_delay <= P_Vett_delay (199 downto 0) & 	TXP_OUT;
		N_Vett_delay <= N_Vett_delay (199 downto 0) & 	TXN_OUT;
	end if;
end process;

--------------------------------------------------------------


--   GENERA I  DATI   ----------------------
Gen_DAT: process ( Ref_CLK_OUT , TX_SYNC_DONE)
   begin	

   if (TX_SYNC_DONE = '0')   then    -- RESET
					                                     GTX_Data_IN <= (others => '0');  K_Comma_IN  <= "00";
																	 Tempo <= (others => '0');
																	 GTXRESET_IN_ovf <= '0';
																	 Assestamento <=  (others => '0');
	 elsif (Ref_CLK_OUT'event and Ref_CLK_OUT = '1') then  -- CLK 
	 
	  if Assestamento < ('1' & X"33" ) THEN Assestamento <= Assestamento +1 ;
	         else  Assestamento <= Assestamento ;   
								Tempo <= Tempo+1;
				
				end if ;
				
				
	            if(Tempo <= X"0000001F") then   GTX_Data_IN <= Tempo (15 downto 0) ; K_Comma_IN  <= "00";
				elsif (Tempo = X"00000020") then   GTX_Data_IN <= IN_K285 & "00000000" ; K_Comma_IN  <= "10";--  KKKKKKK  KKKKK
				elsif (Tempo = X"00000021") then   GTX_Data_IN <= (others => '0');  K_Comma_IN  <= "00";
				elsif (Tempo = X"00000022") then   GTX_Data_IN <= X"0101";  K_Comma_IN  <= "00";
				--elsif (Tempo = X"00000402") then   GTX_Data_IN <= X"0202";  K_Comma_IN  <= "00";
            --elsif (Tempo = X"00000400") then   GTX_Data_IN <= X"0303";  K_Comma_IN  <= "00";
				--elsif (Tempo = X"00000401") then   GTX_Data_IN <= X"0404";  K_Comma_IN  <= "00";
				--elsif (Tempo = X"00000402") then   GTX_Data_IN <= X"0505";  K_Comma_IN  <= "00"; 
				elsif (Tempo > X"00000022") and  (Tempo < X"00000300") then GTX_Data_IN <=  X"3131";  K_Comma_IN  <= "00"; --- Parola invariante 	
            elsif (Tempo = X"00000301") then   GTX_Data_IN <= IN_K285 & "00000000" ; K_Comma_IN  <= "10";--  KKKKKKK  KKKKK	
            elsif (Tempo = X"00000331") then   GTX_Data_IN <= IN_K285 & "00000000" ; K_Comma_IN  <= "10";--  KKKKKKK  KKKKK		
            elsif (Tempo = X"00000361") then   GTX_Data_IN <= IN_K285 & "00000000" ; K_Comma_IN  <= "10";--  KKKKKKK  KKKKK				
				 else   GTX_Data_IN <=  Tempo(15 downto 0) ;  K_Comma_IN  <= "00"; --- Parola invariante 
				end if;
				-- RESET e ripeti 
				if(Tempo = X"000005A0") then  GTXRESET_IN_ovf <= '1';  Conta_RESET <= Conta_RESET+1;
				end if ;
	end if;			
 end process;
 ---------------------------------------------------------------------


  --            GIGA    CLK 
   Giga_period_process :process
   begin
		Gig_clk <= '0';
		wait for Gig_period/2;
		Gig_clk <= '1';
		-- Tempo <= Tempo+1;
		wait for Gig_period/2;
   end process;
------------------------------------	
	
  --              CLK 
   C150Mhz_period_process :process
   begin
		C150Mhz <= '0';
		wait for C150Mhz_period/2;
		C150Mhz <= '1';
		-- Tempo <= Tempo+1;
		wait for C150Mhz_period/2;
   end process;
 

   --      RESET 
   stim_proc: process
   begin		
     GTXRESET_IN_PWUP <='1'; 
			wait for 10 ns;					
	  GTXRESET_IN_PWUP <='0';
      wait; -- INFINITO
   end process;


  ----------   Assegna il reset
GTXRESET_IN <= GTXRESET_IN_PWUP or GTXRESET_IN_ovf;




END;
