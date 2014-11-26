----------------------------------------------------------------------------------
-- Company:   INFN
-- Engineer: Alfonso
library IEEE;
library UNISIM;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use UNISIM.VComponents.all;


entity Global_Trg_Gen is
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
			  Time_W				: in  STD_LOGIC_VECTOR (7 downto 0);  -- Time Windows
			  
			  LEMO_TRG_IN		: in  STD_LOGIC;
			  LEMO_VETO_IN		: in  STD_LOGIC;
			  LEMO_VETO_OUT	: out  STD_LOGIC;
           LEMO_MAJ_OUT		: out  STD_LOGIC;
			  LEMO_TRG_OUT		: out  STD_LOGIC; 
			  
			  TP_MSB	 			: out  STD_LOGIC;   -- 12° bit del Trig Pattern (Trigger da Downscale)
           Glb_TRG 			: out  STD_LOGIC);
end Global_Trg_Gen;

architecture Behavioral of Global_Trg_Gen is

COMPONENT Dual_P_Ram
  PORT (
    clka 	: IN STD_LOGIC;
    wea 		: IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra 	: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    dina 	: IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    clkb 	: IN STD_LOGIC;
	 rstb 	: IN STD_LOGIC;
    addrb 	: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    doutb 	: OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
  );
END COMPONENT;


signal Bm_Valid1r 	: STD_LOGIC;
signal Bm_Valid1rr 	: STD_LOGIC;
signal Bm_Valid2r 	: STD_LOGIC;
signal Bm_Valid2rr   : STD_LOGIC;
signal bmult1XSum		: std_logic_vector(4 downto 0); -- Dura un clk
signal bmult2XSum		: std_logic_vector(4 downto 0); -- Dura un clk

signal Bmult_tot		: std_logic_vector(5 downto 0);
signal Bmult_tot_del	: std_logic_vector(5 downto 0);
signal Accumulatore	: STD_LOGIC_VECTOR (14 downto 0);

signal addr_w			: std_logic_vector(7 downto 0);
signal addr_r			: std_logic_vector(7 downto 0);
signal GTT				: STD_LOGIC;
signal conta_zeri		: std_logic_vector(7 downto 0);

signal Maj_N			: STD_LOGIC;
signal M_OR          : STD_LOGIC;
signal OR_down_scale : STD_LOGIC;
signal Conta_scaler  : STD_LOGIC_VECTOR (13 downto 0);
signal Counter_busy	: STD_LOGIC_VECTOR (16 downto 0);
signal Master_GLTRG  : STD_LOGIC;
signal Busy_Trg      : STD_LOGIC;
signal r_VETO_in		: STD_LOGIC;
signal r_TRG_IN      : STD_LOGIC;
signal Veto_OUT      : STD_LOGIC;
signal Stored        : STD_LOGIC;

begin

---------------------------------------------

---------------------------------------------
ram_Time_Wind : Dual_P_Ram
  PORT MAP (
    clka 	=> clk,
    wea 		=> "1",
    addra 	=> ADDR_W,
    dina 	=> Bmult_tot ,
    clkb 	=> clk,
	 rstb 	=> rst , 
    addrb 	=> ADDR_R,
    doutb 	=> Bmult_tot_del
  );
  
GTT <= GTT_1 or GTT_2;	

------------------------------------


-- 			Processo Bmult Sincronizzatore 
Sincro_Bmult: process(clk, rst)
 begin
	if(rst='1')then
		
		Bm_Valid1r 		<= '0';
		Bm_Valid1rr 	<= '0';
		Bm_Valid2r 		<= '0';
		Bm_Valid2rr 	<= '0';

		bmult1XSum <= (others => '0');
		bmult2XSum <= (others => '0');
		
		Bmult_tot <= (others => '0');
	
	elsif(clk'event and clk='1')then -- __|--
	
	Bm_Valid1rr <= Bm_Valid1r; Bm_Valid1r <= Bm_Valid_1; -- Registra
	Bm_Valid2rr <= Bm_Valid2r; Bm_Valid2r <= Bm_Valid_2; -- Registra
 
   if (Bm_Valid1rr ='0') and (Bm_Valid1r ='1')  then		-- Registr in bmult1XSum solo 1 colpo di CLK
			 bmult1XSum	 <= bmult_1;
		else
		    bmult1XSum <= (others => '0');
	end if;
	
   if (Bm_Valid2rr ='0') and (Bm_Valid2r ='1')  then		-- Registr in bmult1XSum solo 1 colpo di CLK
			 bmult2XSum	 <= bmult_2;
		else
		    bmult2XSum <= (others => '0');
	end if;	
	
	
 Bmult_tot <= ('0' & bmult1XSum) + ('0' & bmult2XSum) ;
	
	
end if;
end process ;
----------------------------------------------------------------------------

-- 			Processo Accumulatore 
Accumulatore_Bmult: process(clk, rst)
 begin
	if(rst='1')then
		
		Accumulatore 	<= (others => '0');
		Conta_Zeri		<= (others => '0');
		ADDR_W			<= (others => '0');
		ADDR_R			<= (others => '0');
	
	elsif(clk'event and clk='1')then -- __|--
	--   Addr 
	ADDR_R <= ADDR_R + 1;
	
	if ADDR_R = X"00" then
			ADDR_W  <= Time_W ;
		else
			ADDR_W  <= ADDR_W + 1;
		end if;

	-- Azzeratore per eliminare eventuali errori in accumulatore

	if (bmult1XSum = "00000") and  (bmult2XSum = "00000") then
	      if   Conta_Zeri /= X"FF" then
	          Conta_Zeri <=  Conta_Zeri + 1;
			end if;
		else
	    Conta_Zeri		<= (others => '0');
		end if;
	
	--   Accumulatore ---
	if Conta_Zeri = X"FF" then
	    Accumulatore	<= (others => '0');
	  else
	    Accumulatore <= Accumulatore  + ("000000000" & Bmult_tot) - ("000000000" & Bmult_tot_del) ;
	  end if;	
	
end if;
end process ;
----------------------------------------------------------------------------

-----------------------------  COMPARATORE  -------------------------------

comp_bmult: process(clk, rst)
 begin
	if(rst='1')then
		Maj_N  <= '0';
		M_OR   <= '0';
		OR_down_scale <= '0';
		Conta_scaler <=  (others => '0');
		Counter_busy <= '0' & x"0000";
      Master_GLTRG <='0';
		Busy_Trg <= '0'; 
		r_VETO_in  <= '0'; 
		r_TRG_IN <= '0';
		Veto_OUT <='0';
		Stored <= '0';
	
	elsif(clk'event and clk='1')then -- __|--
	
		r_VETO_in <= LEMO_VETO_IN ;
		r_TRG_IN  <= LEMO_TRG_IN	;
	             
		if (Accumulatore /= ("000" & X"000")) and en_comp_bmult = '1' then     -- OR 
					 M_OR <= '1' ;
			else M_OR <= '0' ;
		     end if;

		if (Accumulatore  >= "0000000000" & ths_bmult) and en_comp_bmult = '1' then     -- MaJ
			   Maj_N <= '1' ;
		  else Maj_N <= '0' ;
		 end if;

	
--  SCALER x OR    Restituisce    "OR_down_scale"   ----------  
	
	if  M_OR	=  '1' and  Stored = '0' THEN 
		 Stored <= '1' ;
		
		if ( Conta_scaler >= "00" & Scaler   ) and Conta_scaler(13) ='0'  then 
		           Conta_scaler <= Conta_scaler - ("00" & Scaler) + Accumulatore(13 downto 0) ;
		            OR_down_scale <= '1';
						
    	elsif Conta_scaler(13) ='1'  then 
		            Conta_scaler <= Conta_scaler - ("00" & Scaler)  ;
		            OR_down_scale <= '1';						
		else
						Conta_scaler <= Conta_scaler  + Accumulatore(13 downto 0) ;	
                  OR_down_scale <= '0';						
		end if;

	elsif  M_OR	=  '0'  THEN 	
	       Stored <= '0' ;
			 OR_down_scale <= '0';
			 Conta_scaler <= Conta_scaler ;
	end if;
	
--   BLINDING   Accecamento  	
	if Master_GLTRG = '1'        then  
							Counter_busy <= Tmax;
	                  Busy_Trg <= '1';
	elsif(Counter_busy /= '0' & x"0000") then 
							Counter_busy <= Counter_busy - 1;
		               Busy_Trg <= '1';
	else
							Busy_Trg <= '0';
							Counter_busy <= Counter_busy ;
	end if;			
	
--               VETO
	Veto_OUT  <=  Busy_Trg or r_VETO_in or  GTT 	or  FIFO_half_full ; 		
--   GLTRG                               TRG                                 not               VETO 	                                      
	Master_GLTRG <= ( r_TRG_IN or  (OR_down_scale and  M_OR ) or  Maj_N or G_trg_fS ) and  not (Busy_Trg or r_VETO_in or GTT 	or  FIFO_half_full) ;


end if;
end process comp_bmult;
----------------------------------------------------------------------------

 --  assegna le uscite
 LEMO_VETO_OUT  <=  Veto_OUT;
 LEMO_MAJ_OUT	 <=  Maj_N ;
 LEMO_TRG_OUT	 <=  Master_GLTRG;
 TP_MSB	 		 <=  OR_down_scale and  M_OR and  Master_GLTRG ; -- Dura 1 clk !!!!!!!!!!!
 Glb_TRG 	    <=  Master_GLTRG ;
 
end Behavioral;

