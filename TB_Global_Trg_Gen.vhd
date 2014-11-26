--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:36:26 02/10/2012
-- Design Name:   
-- Module Name:   D:/PROGETTI/XILINX/LAVORI/FAZIA/Test_Card/Test_Card_V0/Prova_PllInit_UnGTX/TB_Global_Trg_Gen.vhd
-- Project Name:  Prova_PllInit_UnGTX
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Global_Trg_Gen
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
 
ENTITY TB_Global_Trg_Gen IS
END TB_Global_Trg_Gen;
 
ARCHITECTURE behavior OF TB_Global_Trg_Gen IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Global_Trg_Gen
	  GENERIC ( Tmax          :STD_LOGIC_VECTOR (16 downto 0)   := '1' & X"FFFF" ) ; -- Tempo Monostabile (( Da ridurre in simulazione  )) 
   Port ( clk 				: in  STD_LOGIC; -- 150MHz
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
			  Time_W				: in  STD_LOGIC_VECTOR (7 downto 0);  -- Windows time @ 150MHz
			  
			  LEMO_TRG_IN		: in  STD_LOGIC;
			  LEMO_VETO_IN		: in  STD_LOGIC;
			  LEMO_VETO_OUT	: out  STD_LOGIC;
           LEMO_MAJ_OUT		: out  STD_LOGIC;
			  LEMO_TRG_OUT		: out  STD_LOGIC; 
			  
			  TP_MSB	 			: out  STD_LOGIC;   -- 12° bit del Trig Pattern (Trigger da Downscale)
           Glb_TRG 			: out  STD_LOGIC);
      
    END COMPONENT;
    

   --Inputs
   signal clk 			: std_logic := '0';
   signal rst 			: std_logic := '1';
   signal G_trg_fS 	: std_logic := '0';
   signal GTT_1 		: std_logic := '0';
	signal GTT_2 		: std_logic := '0';
   signal FIFO_half_full : std_logic := '0';
	
   signal bmult_1 	: std_logic_vector(4 downto 0) := (others => '0');
	signal bmult_2 	: std_logic_vector(4 downto 0) := (others => '0');
	signal Bm_Valid_1 : std_logic := '0';
   signal Bm_Valid_2 : std_logic := '1';
   signal en_comp_bmult : std_logic := '0';
   signal ths_bmult 	: std_logic_vector(4 downto 0) := (others => '0');
   signal Scaler 		: std_logic_vector(11 downto 0) := (others => '0');
	signal Time_W		: STD_LOGIC_VECTOR (7 downto 0) := X"07" ;  -- Windows time @ 150MHz
   signal LEMO_TRG_IN : std_logic := '0';
   signal LEMO_VETO_IN : std_logic := '0';

 	--Outputs
   signal LEMO_VETO_OUT : std_logic;
   signal LEMO_MAJ_OUT 	: std_logic;
   signal LEMO_TRG_OUT 	: std_logic;
   signal TP_MSB 			: std_logic;
   signal Glb_TRG 		: std_logic;

   -- Clock period definitions
   constant clk_period : time := 5 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
	uut: Global_Trg_Gen 
			GENERIC MAP (
				Tmax => '0' & x"000f"
				)
			PORT MAP (
          clk 				=> clk,
          rst 				=> rst,
          G_trg_fS 		=> G_trg_fS,
			 GTT_1			=> GTT_1,
			 GTT_2			=> GTT_2,
			 
          FIFO_half_full => FIFO_half_full,
			 
			 bmult_1			=> bmult_1	,	
			 bmult_2			=> bmult_2	,	
			 Bm_Valid_1		=> Bm_Valid_1,
			 Bm_Valid_2		=> Bm_Valid_2,
			 
         -- bmult => bmult,
          en_comp_bmult => en_comp_bmult,
          ths_bmult 		=> ths_bmult,
          Scaler 			=> Scaler,
			 Time_W			=> Time_W,
			 
          LEMO_TRG_IN 	=> LEMO_TRG_IN,
          LEMO_VETO_IN 	=> LEMO_VETO_IN,
          LEMO_VETO_OUT => LEMO_VETO_OUT,
          LEMO_MAJ_OUT 	=> LEMO_MAJ_OUT,
          LEMO_TRG_OUT 	=> LEMO_TRG_OUT,
          TP_MSB 			=> TP_MSB,
          Glb_TRG 		=> Glb_TRG
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
										rst <= '1';
    wait for clk_period*10;	
										rst <=  '0';
    wait for clk_period*10;
										G_trg_fS <= '1';		--TRG da Seriale
	 wait for clk_period*2;
										G_trg_fS <= '0';
	
	 wait for clk_period*3;
										G_trg_fS <= '1';		--2° TRG da Seriale da scartare
	 wait for clk_period;
										G_trg_fS <= '0';
										en_comp_bmult <= '1' ;
										
										
	 wait for clk_period*10;
										scaler <= x"012";
										
	 
	 wait for clk_period*10;
										ths_bmult <= "01010";
	 wait for clk_period*3;
										bmult_1 <= "00100"; bmult_2 <= "00000"; Bm_Valid_1 <= '1'; Bm_Valid_2 <= '1';		--sotto la soglia
	 wait for clk_period*3;
										bmult_1 <= "00000";   bmult_2 <= "00000"; Bm_Valid_1 <= '0'; Bm_Valid_2 <= '0';		--fine
										
	wait for clk_period*3;
										bmult_1 <= "00000"; bmult_2 <= "01010"; Bm_Valid_1 <= '1'; Bm_Valid_2 <= '1';		----sulla soglia
	 wait for clk_period*3;
										bmult_1 <= "00000";   bmult_2 <= "00000"; Bm_Valid_1 <= '0'; Bm_Valid_2 <= '0';		--fine
										
										

										
	 wait for clk_period*12;
										bmult_1 <= "01111"; bmult_2 <= "01010"; Bm_Valid_1 <= '1'; Bm_Valid_2 <= '1';		----sulla soglia
										
	wait for clk_period*3;
										bmult_1 <= "00000";   bmult_2 <= "00000"; Bm_Valid_1 <= '0'; Bm_Valid_2 <= '0';		--fine

--	 wait for clk_period*3;
--										bmult <= "00000";		--sopra la soglia , dovrebbe scattare il TRG
--	
--		 wait for clk_period*5;
--										bmult <= "01111";		--sopra la soglia , dovrebbe scattare il TRG
--										
--	
--	 wait for clk_period*3;
--										bmult <= "00000";		--sopra la soglia , dovrebbe scattare il TRG
--	
--		 wait for clk_period*5;
--										bmult <= "01111";		--sopra la soglia , dovrebbe scattare il TRG
--	
--		 wait for clk_period*10;
--										ths_bmult <= "11111";
--	
--	
--	 wait for clk_period*3;
--										bmult <= "00000";		--sopra la soglia , dovrebbe scattare il TRG
--	
--		 wait for clk_period*12;
--										bmult <= "01111";		--sopra la soglia , dovrebbe scattare il TRG
--										
--
--	 wait for clk_period*3;
--										bmult <= "00000";		--sopra la soglia , dovrebbe scattare il TRG
--	
--		 wait for clk_period*5;
--										bmult <= "01111";		--sopra la soglia , dovrebbe scattare il TRG
--
--	 wait for clk_period*3;
--										bmult <= "00000";		--sopra la soglia , dovrebbe scattare il TRG
--	
--		 wait for clk_period*5;
--										bmult <= "01111";		--sopra la soglia , dovrebbe scattare il TRG
--
--	 wait for clk_period*3;
--										bmult <= "00000";		--sopra la soglia , dovrebbe scattare il TRG
--	
--		 wait for clk_period*5;
--										bmult <= "01111";		--sopra la soglia , dovrebbe scattare il TRG
--
--	 wait for clk_period*3;
--										bmult <= "00000";		--sopra la soglia , dovrebbe scattare il TRG
--	
--		 wait for clk_period*5;
--										bmult <= "01111";		--sopra la soglia , dovrebbe scattare il TRG
--
--	 wait for clk_period*3;
--										bmult <= "00000";		--sopra la soglia , dovrebbe scattare il TRG
--	
--		 wait for clk_period*5;
--										bmult <= "01111";		--sopra la soglia , dovrebbe scattare il TRG
--
--	 wait for clk_period*3;
--										bmult <= "00000";		--sopra la soglia , dovrebbe scattare il TRG
--	
--		 wait for clk_period*5;
--										bmult <= "01111";		--sopra la soglia , dovrebbe scattare il TRG
--
--	 wait for clk_period*3;
--										bmult <= "00000";		--sopra la soglia , dovrebbe scattare il TRG
--	
--		 wait for clk_period*5;
--										bmult <= "01111";		--sopra la soglia , dovrebbe scattare il TRG
--
--	 wait for clk_period*3;
--										bmult <= "00000";		--sopra la soglia , dovrebbe scattare il TRG
--	
--		 wait for clk_period*5;
--										bmult <= "01111";		--sopra la soglia , dovrebbe scattare il TRG
--
--	 wait for clk_period*3;
--										bmult <= "00000";		--sopra la soglia , dovrebbe scattare il TRG
--	
--		 wait for clk_period*5;
--										bmult <= "01111";		--sopra la soglia , dovrebbe scattare il TRG
--
--	 wait for clk_period*3;
--										bmult <= "00000";		--sopra la soglia , dovrebbe scattare il TRG
--	
--		 wait for clk_period*5;
--										bmult <= "01111";		--sopra la soglia , dovrebbe scattare il TRG
--
--	 wait for clk_period*3;
--										bmult <= "00000";		--sopra la soglia , dovrebbe scattare il TRG
--	
--		 wait for clk_period*5;
--										bmult <= "01111";		--sopra la soglia , dovrebbe scattare il TRG
--
--	 wait for clk_period*3;
--										bmult <= "00000";		--sopra la soglia , dovrebbe scattare il TRG
--	
--		 wait for clk_period*5;
--										bmult <= "01111";		--sopra la soglia , dovrebbe scattare il TRG										
	

	 wait for clk_period*32;
									
										FIFO_half_full <= '1' ; 
										
		 wait for clk_period*32;
									
										FIFO_half_full <= '0' ; 	

	 wait for clk_period*32;
									
										GTT_1 <= '1' ; 
										
		 wait for clk_period*32;
									
										GTT_1 <= '0' ; 		

	 wait for clk_period*32;
									
										LEMO_VETO_IN <= '1' ; 
										
		 wait for clk_period*32;
									
										LEMO_VETO_IN <= '0' ; 										
	 
	 
	 	 wait for clk_period*32;
									
									bmult_1 <= "01111"; bmult_2 <= "01010"; Bm_Valid_1 <= '1'; Bm_Valid_2 <= '1';		----sulla soglia
		 wait for clk_period*2;							
									bmult_1 <= "01111"; bmult_2 <= "01010"; Bm_Valid_1 <= '0'; Bm_Valid_2 <= '0';		----sulla soglia
										
		 wait for clk_period*32;
									
										 LEMO_TRG_IN <= '1' ; 	
		 wait for clk_period;
									
										 LEMO_TRG_IN <= '0' ; 								 
	 
      wait;
   end process;

END;
