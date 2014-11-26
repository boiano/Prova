----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:50:21 04/29/2011 
-- Design Name: 
-- Module Name:    READ_FILE_Fibra_Format - Behavioral 
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
use work.all;
use std.textio.all;


entity READ_FILE_Fibra_Format is

generic ( in_data_path  : string := "DATAFIFO/LOC_FIFO_0.TXT"  );	
	port (
		clk		: in std_logic;
		rst		: in std_logic; 
		RD_EN		: in std_logic;
		data	   : out std_logic_vector (15 downto 0 );
		Kout		: out std_logic_vector (1 downto 0 )
	);
	
end READ_FILE_Fibra_Format;

architecture Behavioral of READ_FILE_Fibra_Format is
------------------------------------------------------------------

 

-- FUNZIONE
function string_to_slv(s : string) return std_logic_vector  is
variable ret_slv : std_ulogic_vector(15 downto 0) := (others => 'X');
variable quattro : std_logic_vector(3 downto 0);
variable Primo : std_logic_vector(3 downto 0)  := (others => 'X');
variable Secondo : std_logic_vector(3 downto 0):= (others => 'X');
variable Terzo : std_logic_vector(3 downto 0)  := (others => 'X');
variable Quarto : std_logic_vector(3 downto 0) := (others => 'X');

begin

 for i in 1 to 4 loop
case s(i) is
    when '0'  => quattro := X"0";
	 when '1'  => quattro := X"1";
	 when '2'  => quattro := X"2";
	 when '3'  => quattro := X"3";
	 when '4'  => quattro := X"4";
	 when '5'  => quattro := X"5";
	 when '6'  => quattro := X"6";
	 when '7'  => quattro := X"7";
	 when '8'  => quattro := X"8";
	 when '9'  => quattro := X"9";
    when 'A'  => quattro := X"A";
	 when 'B'  => quattro := X"B";
	 when 'C'  => quattro := X"C";
	 when 'D'  => quattro := X"D";
	 when 'E'  => quattro := X"E";
	 when 'F'  => quattro := X"F";
	 when 'a'  => quattro := X"A";
	 when 'b'  => quattro := X"B";
	 when 'c'  => quattro := X"C";
	 when 'd'  => quattro := X"D";
	 when 'e'  => quattro := X"E";
	 when 'f'  => quattro := X"F";
	 when others =>   quattro := "XXXX";
	 
	 end case ;
   
	if    i = 1 then Primo :=  quattro ;
	elsif i = 2 then Secondo :=  quattro ;
	elsif i = 3 then Terzo :=  quattro ;
       else         Quarto :=  quattro ;
	end if;
	
	end loop;
	
return quarto  & Terzo & Secondo  & Primo ;                
end function;

------------------------------------------------------------------------------
--  Variabile


FILE in_file	:	text  IS IN in_data_path ;

constant VUOTO 	: std_logic_vector (15 downto 0 ) := X"8080" ;
signal Intdata 	: std_logic_vector (15 downto 0) :=  VUOTO;

signal noK 			: std_logic := '0' ;
signal noKr			: std_logic := '0' ;
signal conta_sei 	: std_logic_vector (2 downto 0) := "000";

begin
-------------------------------------------------------------------------------
--  Processi ------

main : process (clk, rst)
	variable	n 	 :  string (4 downto 1);
	--variable	n 	 : std_logic_vector (15 downto 0 ) ;
	variable	in_line : line;
	variable good: boolean;   -- Status of the read operations
	variable RET_VAL :  std_logic_vector (15 downto 0 ) ;
	
	
	begin
	   if rst = '1' then
	   Intdata <= VUOTO ;
			
		elsif (clk='1' and clk'event)  then -- 
				if 	 RD_EN  = '1'  and noK = '1' THEN		 
						if(not(endfile(in_file))) then
								readline(in_file,in_line);
								-- HREAD(in_line, n ,good ); -- ???? PERCHE non FUNZIONA ???
								READ(in_line, n , good ); 
								assert good
								report "Text I/O read error"
								severity ERROR;
				         RET_VAL := string_to_slv (n);  -- Chiama la funzione e restituisce il valore
						 Intdata <= RET_VAL;
				      else 
			          Intdata <= VUOTO ;
			        end if;
			   else Intdata <= VUOTO ;  -- Se non RD_EN DATA = VUOTO 
		      end if;
	end if;
 end process main;

---------------------------------------

-- Processo per generare i K della fibra
Proc_K : process (clk,rst)
 begin
   if rst = '1' then
	  conta_sei <= (others => '0');
	   noK <= '0';
	elsif (clk='1' and clk'event)  then --
	  noKr <= noK;
		 if conta_sei < 5 then
		    conta_sei <= conta_sei + 1;
			 noK <= '1';
		 else 
		    conta_sei <= "000";
			  noK <= '0';
		 end if;
			 
end if;
end process Proc_K;
 
--    Processo combinatoriale per WREN della fifo
Comb_Proc : process ( noKr,Intdata  )
begin
if  noKr = '0'  then
					DATA <= X"2222" ;
					Kout <= "10";
				else
              DATA <= Intdata ;
				  Kout <= "00";
						end if;

end process ;
-----------------------------

end Behavioral;

