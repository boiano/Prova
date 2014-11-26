----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:42:09 08/29/2011 
-- Design Name: 
-- Module Name:    Decoder - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity Decoder is
    Port ( clk 				: in  STD_LOGIC; -- 150MHz
           rst 				: in  STD_LOGIC;
			  accepted_word	: in  STD_LOGIC;
			  received_word	: in  STD_LOGIC_VECTOR(7 downto 0);
			  g_trg						: out  STD_LOGIC	; --
			  rst_bc						: out  STD_LOGIC	; --  Reset BLCK CARD
			  rst_ec						: out  STD_LOGIC	; --  Reset Event Counter
			  en_comp_bmult			: out  STD_LOGIC	; -- Enable --
			  en_wrt_fifo				: out  STD_LOGIC	:='0';
			  Serial_USB            : out  STD_LOGIC	:='0';
			  read_fifo           	: out  STD_LOGIC	:='0';
			  EN_pulser 				: out  STD_LOGIC	:='0';
			  ths_bmult        	 : out  STD_LOGIC_VECTOR(4 downto 0);
			  Freq_Pulser 			 : out  STD_LOGIC_VECTOR(11 downto 0); 
			  trg_pattern         : out  STD_LOGIC_VECTOR(11 downto 0); 
			  scaler   				 : out  STD_LOGIC_VECTOR(11 downto 0);
			  Slow_EN_FIFO			 : out  STD_LOGIC_VECTOR(3 downto 0);
			  Time_W					 : out  STD_LOGIC_VECTOR(7 downto 0) 	  );  -- Time Windows	
end Decoder;

architecture Behavioral of Decoder is

type Type_of_word is (idle, Sscaler, Stp, Sthr, Freq, Fifo_EN, S_Time_W );
signal current_state : Type_of_word := idle;

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
constant set_scaler_const     : STD_LOGIC_VECTOR(7 downto 0) := X"6B";--k
constant SER_USB_SET          : STD_LOGIC_VECTOR(7 downto 0) := X"6C";--l
constant SER_USB_RESET        : STD_LOGIC_VECTOR(7 downto 0) := X"6D";--m
constant Pulser_ON_Const      : STD_LOGIC_VECTOR(7 downto 0) := X"6E";--n
constant Pulser_OFF_Const     : STD_LOGIC_VECTOR(7 downto 0) := X"6F";--o
constant Freq_Puls_Const      : STD_LOGIC_VECTOR(7 downto 0) := X"70";--p
constant EN_FIFO_Const      	: STD_LOGIC_VECTOR(7 downto 0) := X"71";--q
constant Time_W_Const			: STD_LOGIC_VECTOR(7 downto 0) := X"72";--r

signal Conta   				: STD_LOGIC_VECTOR(1 downto 0) ;
signal Rec_ASCII 				: STD_LOGIC_VECTOR(3 downto 0) ;
signal int_Slow_EN_FIFO 	: STD_LOGIC_VECTOR(3 downto 0) ;
signal int_en_wrt_fifo		: STD_LOGIC;

begin
-------------   Convertitore ASCII
with received_word select	
	Rec_ASCII 	<=	X"0"  when X"30" ,
						X"1"  when X"31" ,
						X"2"  when X"32" ,
						X"3"  when X"33" ,
						X"4"  when X"34" ,
						X"5"  when X"35" ,
						X"6"  when X"36" ,
						X"7"  when X"37" ,
						X"8"  when X"38" ,
						X"9"  when X"39" ,
						X"A"  when X"61" ,
						X"B"  when X"62" ,
						X"C"  when X"63" ,
						X"D"  when X"64" ,
						X"E"  when X"65" ,
						X"F"  when X"66" ,
	               X"0"  when others;



-------  STATE MACHINE --------------------------
Status_Update: process (clk , rst)
begin
	if rst = '1' then 
		current_state <= idle;
		
		g_trg 				<= '0';
		rst_bc				<= '0';
		rst_ec				<= '0';
		en_comp_bmult     <= '0';
		int_en_wrt_fifo	<= '0';
		read_fifo         <= '0';
		Serial_USB        <= '0'; -- to serial
		EN_pulser			<= '0'; -- ENable Pulser
		ths_bmult    		<= (others => '0') ;
		trg_pattern       <= (others => '0') ;
		scaler   		   <= (others => '0') ;
		Freq_Pulser       <= (others => '0') ;
	   Conta   		      <= (others => '0') ;
		int_Slow_EN_FIFO	<= "1111";
		
		
	elsif rising_edge(clk) then  --  __|--
	
	 case current_state is
	-----------------------------------
	    when idle =>	 
				if accepted_word = '1' THEN 
                           if  received_word = G_trg_const    			THEN  g_trg 			<= '1' ;
	                      elsif received_word = rst_bc_const			 	THEN  rst_bc 			<= '1' ;
								 elsif received_word = rst_ec_const			 	THEN  rst_ec 			<= '1' ;
								 elsif received_word = en_comp_bmult_const	THEN  en_comp_bmult 	<= '1' ;
								 elsif received_word = dis_comp_bmult_const	THEN  en_comp_bmult 	<= '0' ;
								 elsif received_word = en_wrt_fifo_const		THEN  int_en_wrt_fifo	<= '1' ;
								 elsif received_word = dis_wrt_fifo_const	 	THEN  int_en_wrt_fifo	<= '0' ;
								 elsif received_word = read_fifo_const	 	   THEN  read_fifo 		<= '1' ;
								 elsif received_word = SER_USB_SET  	 	   THEN  Serial_USB 		<= '1' ;
								 elsif received_word = SER_USB_RESET  	 	   THEN  Serial_USB 		<= '0' ;
								 elsif received_word = Pulser_ON_Const  	 	THEN  EN_pulser 		<= '1' ;
								 elsif received_word = Pulser_OFF_Const  	 	THEN  EN_pulser 		<= '0' ;
								 elsif received_word = set_ths_const  	 	   THEN  current_state 	<= Sthr ; 
								 elsif received_word = set_trg_pattern_const	THEN  current_state 	<= Stp  ;
								 elsif received_word = set_scaler_const	   THEN  current_state 	<= Sscaler  ;
								 elsif received_word = Freq_Puls_Const	   	THEN  current_state 	<= Freq    ;
								 elsif received_word = EN_FIFO_Const	   	THEN  current_state 	<= Fifo_EN    ;
								 elsif received_word = Time_W_Const	   		THEN  current_state 	<= S_Time_W   ;
								 
								 end if;
				else   
                   g_trg 				<= '0';				
                   rst_bc				<= '0';
                   rst_ec				<= '0';
	                read_fifo        <= '0';
						 current_state 	<= current_state ;
						 Conta   		   <= (others => '0') ;
				end if;
	------------------                                              		            
	     when Sthr =>	 
				if accepted_word = '1' THEN    ths_bmult <=  '0' & Rec_ASCII ;              
                                           current_state <= idle;
				  else 
							  current_state 	<= current_state ;
                end if;							  
	------------
       when Stp =>	-- trigger Pattern  
				if accepted_word = '1' THEN   Conta <= Conta + 1;
				                 if Conta = "00" THEN  trg_pattern (11 downto 8 ) <= Rec_ASCII ;
								  elsif Conta = "01" THEN  trg_pattern (7 downto 4 )  <= Rec_ASCII ;
								  elsif Conta = "10" THEN  trg_pattern (3 downto 0 )  <= Rec_ASCII ; current_state <= idle;
								  else  current_state <= idle;
								    end if;
                                     
				  else 
							  current_state 	<= current_state ;
                end if;


------------
       when Sscaler =>	--  Divisore 
				if accepted_word = '1' THEN   Conta <= Conta + 1;
				                 if Conta = "00" THEN  scaler (11 downto 8 ) <= Rec_ASCII ;
								  elsif Conta = "01" THEN  scaler (7 downto 4 )  <= Rec_ASCII ;
								  elsif Conta = "10" THEN  scaler (3 downto 0 )  <= Rec_ASCII ; current_state <= idle;
								  else  current_state <= idle;
								    end if;
                                     
				  else 
							  current_state 	<= current_state ;
                end if;


------------
       when Freq =>	--  Frequenza Pulser
				if accepted_word = '1' THEN   Conta <= Conta + 1;
				                 if Conta = "00" THEN  Freq_Pulser (11 downto 8 ) <= Rec_ASCII ;
								  elsif Conta = "01" THEN  Freq_Pulser (7 downto 4 )  <= Rec_ASCII ;
								  elsif Conta = "10" THEN  Freq_Pulser (3 downto 0 )  <= Rec_ASCII ; current_state <= idle;
								  else  current_state <= idle;
								    end if;
                                     
				  else 
							  current_state 	<= current_state ;
                end if;	
---------------    
		  when Fifo_EN =>	 
				if accepted_word = '1' THEN    int_Slow_EN_FIFO <=   Rec_ASCII ;              
                                           current_state <= idle;
				  else 
							  current_state 	<= current_state ;
                end if;
	
	
	         

 when S_Time_W =>	--  Time Windows
				if accepted_word = '1' THEN   Conta <= Conta + 1;
								     if Conta = "00" THEN  	Time_W (7 downto 4 )  <= Rec_ASCII ;
								  elsif Conta = "01" THEN     Time_W (3 downto 0 )  <= Rec_ASCII ; current_state <= idle;
								  else  current_state <= idle;
								    end if;	
					else 
							 current_state 	<= current_state ;
                end if;
					 
									 
     when others => current_state <= idle;    									 
 end case;
	
end if;
end process;	

   Slow_EN_FIFO <= int_Slow_EN_FIFO  and int_en_wrt_fifo & "111"	 ; 

   en_wrt_fifo	 <= int_en_wrt_fifo	;
	
end Behavioral;