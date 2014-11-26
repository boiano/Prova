--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:53:04 09/15/2011
-- Design Name:   
-- Module Name:   D:/Prog_ise/seriale/TB_Decoder.vhd
-- Project Name:  TX_RX_Seriale
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Decoder
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY TB_Decoder IS
END TB_Decoder;
 
ARCHITECTURE behavior OF TB_Decoder IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Decoder
    PORT( clk 				: in  STD_LOGIC; -- 150MHz
           rst 				: in  STD_LOGIC;
			  accepted_word	: in  STD_LOGIC;
			  received_word	: in  STD_LOGIC_VECTOR(7 downto 0);
			  g_trg						: out  STD_LOGIC	; --
			  rst_bc						: out  STD_LOGIC	; --  Reset BLCK CARD
			  rst_ec						: out  STD_LOGIC	; --  Reset Event Counter
			  en_comp_bmult			: out  STD_LOGIC	; -- Enable --
			  en_wrt_fifo				: out  STD_LOGIC	:='0';
			  read_fifo           	: out  STD_LOGIC	:='0';
			  EN_pulser 				: out  STD_LOGIC	:='0';
			  ths_bmult        	 : out  STD_LOGIC_VECTOR(4 downto 0);
			  Freq_Pulser 		    : out  STD_LOGIC_VECTOR(11 downto 0); 
			  trg_pattern         : out  STD_LOGIC_VECTOR(11 downto 0) ;
           scaler 			    : out  STD_LOGIC_VECTOR(11 downto 0);
			  Slow_EN_FIFO			 : out  STD_LOGIC_VECTOR(3 downto 0) 	  );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '1';
   signal accepted_word : std_logic := '0';
   signal received_word : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal g_trg : std_logic;
   signal rst_bc : std_logic;
   signal rst_ec : std_logic;
   signal en_comp_bmult : std_logic;
   signal en_wrt_fifo 	: std_logic;
   signal read_fifo 		: std_logic;
	signal EN_pulser		: std_logic;
   signal ths_bmult     			: std_logic_vector(4 downto 0);
	signal Freq_Pulser				: std_logic_vector(11 downto 0);
   signal trg_pattern   			: std_logic_vector(11 downto 0);
	signal scaler                 : std_logic_vector(11 downto 0);
	signal Slow_EN_FIFO				: std_logic_vector(3 downto 0);
	
	constant G_trg_const				: STD_LOGIC_VECTOR(7 downto 0) := X"61";--a
	constant rst_bc_const			: STD_LOGIC_VECTOR(7 downto 0) := X"62";--b
	constant rst_ec_const			: STD_LOGIC_VECTOR(7 downto 0) := X"63";--c
	constant en_comp_bmult_const	: STD_LOGIC_VECTOR(7 downto 0) := X"64";--d
	constant dis_comp_bmult_const	: STD_LOGIC_VECTOR(7 downto 0) := X"65";--e
	constant en_wrt_fifo_const		: STD_LOGIC_VECTOR(7 downto 0) := X"66";--f
	constant dis_wrt_fifo_const	: STD_LOGIC_VECTOR(7 downto 0) := X"67";--g
	constant read_fifo_const		: STD_LOGIC_VECTOR(7 downto 0) := X"68";--h
	constant set_ths_const			: STD_LOGIC_VECTOR(7 downto 0) := X"69";--i
	constant set_trg_pattern_const: STD_LOGIC_VECTOR(7 downto 0) := X"6A";--j
	constant set_scaler_const     : STD_LOGIC_VECTOR(7 downto 0) := X"6B";--K
	constant SER_USB_SET          : STD_LOGIC_VECTOR(7 downto 0) := X"6C";--l
	constant SER_USB_RESET        : STD_LOGIC_VECTOR(7 downto 0) := X"6D";--m
	constant Pulser_ON_Const      : STD_LOGIC_VECTOR(7 downto 0) := X"6E";--n
	constant Pulser_OFF_Const     : STD_LOGIC_VECTOR(7 downto 0) := X"6F";--o
	constant Freq_Puls_Const      : STD_LOGIC_VECTOR(7 downto 0) := X"70";--p
	constant EN_FIFO_Const      	: STD_LOGIC_VECTOR(7 downto 0) := X"71";--q

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Decoder PORT MAP (
          clk => clk,
          rst => rst,
          accepted_word 	=> accepted_word,
          received_word 	=> received_word,
          g_trg 				=> g_trg,
          rst_bc 				=> rst_bc,
          rst_ec 				=> rst_ec,
          en_comp_bmult 	=> en_comp_bmult,
          en_wrt_fifo 		=> en_wrt_fifo,
          read_fifo 			=> read_fifo,
			 EN_pulser			=> EN_pulser,
          ths_bmult   		=> ths_bmult,
			 Freq_Pulser		=> Freq_Pulser,
          trg_pattern		=> trg_pattern,
			 scaler     		=>    scaler,
			 Slow_EN_FIFO		=> Slow_EN_FIFO
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      wait for 105 ns;
			rst <= '0';
		wait for 400 ns;	
			received_word <= G_trg_const;	-- G_Trg
      wait for clk_period;
			accepted_word <= '1';
      wait for clk_period;
			accepted_word <= '0';
			
				wait for 200 ns;
			received_word <= rst_bc_const;  -- rst_bc
      wait for clk_period;
			accepted_word <= '1';
      wait for clk_period;
			accepted_word <= '0';
			
				wait for 200 ns;
			received_word <= rst_ec_const;  -- rst_ec
      wait for clk_period;
			accepted_word <= '1';
      wait for clk_period;
			accepted_word <= '0';
			
				wait for 200 ns;
			received_word <= en_comp_bmult_const;  -- en_comp_bmult
      wait for clk_period;
			accepted_word <= '1';
      wait for clk_period;
			accepted_word <= '0';
			
		wait for 200 ns;
			received_word <= dis_comp_bmult_const;  -- dis_comp_bmult
      wait for clk_period;
			accepted_word <= '1';
      wait for clk_period;
			accepted_word <= '0';
			
		wait for 200 ns;
			received_word <= en_wrt_fifo_const;  -- en_wrt_fifo
      wait for clk_period;
			accepted_word <= '1';
      wait for clk_period;
			accepted_word <= '0';			

		wait for 200 ns;
			received_word <= dis_wrt_fifo_const;  -- dis_wrt_fifo
      wait for clk_period;
			accepted_word <= '1';
      wait for clk_period;
			accepted_word <= '0';			

		wait for 200 ns;
			received_word <= read_fifo_const;  -- read_fifo_const
      wait for clk_period;
			accepted_word <= '1';
      wait for clk_period;
			accepted_word <= '0';		


		wait for 200 ns;
			received_word <= set_ths_const;  -- set_ths_const
      wait for clk_period;
			accepted_word <= '1';
      wait for clk_period;
			accepted_word <= '0';	
		wait for clk_period*5;
			received_word <=  X"63" ;	--  DATO di Soglia Mult
      wait for clk_period;
			accepted_word <= '1';
      wait for clk_period;
			accepted_word <= '0';			
			

		wait for 200 ns;
			received_word <= set_trg_pattern_const;  --Trg_Pattern
      wait for clk_period;
			accepted_word <= '1';
      wait for clk_period;
			accepted_word <= '0';
		wait for clk_period*5;
			received_word <= x"61";	  -- Prima parola
      wait for clk_period;
			accepted_word <= '1';
      wait for clk_period;
			accepted_word <= '0';
		wait for clk_period*10;
			received_word <= x"32";		-- Seconda parola
      wait for clk_period;
			accepted_word <= '1';
      wait for clk_period;
			accepted_word <= '0';
			
				wait for clk_period*10;
			received_word <= x"33";		-- Terza parola
      wait for clk_period;
			accepted_word <= '1';
      wait for clk_period;
			accepted_word <= '0';
			
			
	wait for 400 ns;	
			received_word <= G_trg_const;	-- G_Trg
      wait for clk_period;
			accepted_word <= '1';
      wait for clk_period;
			accepted_word <= '0';
			
			
			
			wait for 200 ns;
			received_word <= set_scaler_const;  --scaler
      wait for clk_period;
			accepted_word <= '1';
      wait for clk_period;
			accepted_word <= '0';
		wait for clk_period*5;
			received_word <= x"33";	  -- Prima parola
      wait for clk_period;
			accepted_word <= '1';
      wait for clk_period;
			accepted_word <= '0';
		wait for clk_period*10;
			received_word <= x"32";		-- Seconda parola
      wait for clk_period;
			accepted_word <= '1';
      wait for clk_period;
			accepted_word <= '0';			
		wait for clk_period*10;
			received_word <= x"36";		-- Terza parola
      wait for clk_period;
			accepted_word <= '1';
      wait for clk_period;
			accepted_word <= '0';


	wait for 400 ns;	
			received_word <= G_trg_const;	-- G_Trg
      wait for clk_period;
			accepted_word <= '1';
      wait for clk_period;
			accepted_word <= '0';
			
	
	wait for 300 ns;	
			received_word <= SER_USB_SET;	--  USB EN
      wait for clk_period;
			accepted_word <= '1';
      wait for clk_period;
			accepted_word <= '0';	
	wait for 200 ns;	
			received_word <= SER_USB_RESET;	-- USB Disable
      wait for clk_period;
			accepted_word <= '1';
      wait for clk_period;
			accepted_word <= '0';			
			
	wait for 300 ns;	
			received_word <= Pulser_ON_Const;	--  Pulser ON
      wait for clk_period;
			accepted_word <= '1';
      wait for clk_period;
			accepted_word <= '0';	
	wait for 200 ns;	
			received_word <= Pulser_OFF_Const;	-- Pulser OFF
      wait for clk_period;
			accepted_word <= '1';
      wait for clk_period;
			accepted_word <= '0';			
			
	
    			wait for 400 ns;
			received_word <= Freq_Puls_Const;  -- Setta la Freq dell pulser
      wait for clk_period;
			accepted_word <= '1';
      wait for clk_period;
			accepted_word <= '0';
		wait for clk_period*5;
			received_word <= x"37";	  -- Prima parola
      wait for clk_period;
			accepted_word <= '1';
      wait for clk_period;
			accepted_word <= '0';
		wait for clk_period*10;
			received_word <= x"38";		-- Seconda parola
      wait for clk_period;
			accepted_word <= '1';
      wait for clk_period;
			accepted_word <= '0';			
		wait for clk_period*10;
			received_word <= x"39";		-- Terza parola
      wait for clk_period;
			accepted_word <= '1';
      wait for clk_period;
			accepted_word <= '0';
 
 	wait for 400 ns;	
			received_word <= EN_FIFO_Const;	-- Slow_EN_FIFO
       wait for clk_period;
			accepted_word <= '1';
      wait for clk_period;
			accepted_word <= '0';	
		wait for clk_period*5;
			received_word <=  X"61" ;	--  DATO EN Fifo  A
      wait for clk_period;
			accepted_word <= '1';
      wait for clk_period;
			accepted_word <= '0';

      wait;
   end process;

END;
