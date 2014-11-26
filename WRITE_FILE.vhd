----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:44:57 05/03/2011 
-- Design Name: 
-- Module Name:    WRITE_FILE - Behavioral 
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

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity WRITE_FILE is
generic ( out_data_path  : string := "DATAFIFO/OUT_GLOBAL_FIFO.TXT"  );	
   Port ( CLK 		   : in  STD_LOGIC;
          WR_EN 		: in  STD_LOGIC;
          DATA_IN 	: in  STD_LOGIC_VECTOR (15 downto 0));
end WRITE_FILE;

architecture Behavioral of WRITE_FILE is
---------------------------------------------------------------------------------------

-- FUNZIONE
function STD_to_STR (Din :std_logic_vector(15 downto 0) )  return  string  is

variable STR_OUT   : string(1 to 4 ); 
variable quad: std_logic_vector(0 to 3);
--variable Secondo : string ; 
--variable Terzo   : string ; 
--variable Quarto  : string ; 

begin

for i in 0 to 3 loop
			quad := To_X01Z(Din((4*(3-i))+3 downto 4*(3-i) ));
			case quad is
				when x"0" => STR_OUT(i+1) := '0';
				when x"1" => STR_OUT(i+1) := '1';
				when x"2" => STR_OUT(i+1) := '2';
				when x"3" => STR_OUT(i+1) := '3';
				when x"4" => STR_OUT(i+1) := '4';
				when x"5" => STR_OUT(i+1) := '5';
				when x"6" => STR_OUT(i+1) := '6';
				when x"7" => STR_OUT(i+1) := '7';
				when x"8" => STR_OUT(i+1) := '8';
				when x"9" => STR_OUT(i+1) := '9';
				when x"A" => STR_OUT(i+1) := 'A';
				when x"B" => STR_OUT(i+1) := 'B';
				when x"C" => STR_OUT(i+1) := 'C';
				when x"D" => STR_OUT(i+1) := 'D';
				when x"E" => STR_OUT(i+1) := 'E';
				when x"F" => STR_OUT(i+1) := 'F';
				when others =>  
					if (quad = "ZZZZ") then
					  STR_OUT(i+1) := 'Z';
					else
					  STR_OUT(i+1) := 'X';
					end if;
			end case;
end loop;
	
return STR_OUT ;                
end function;

------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
--  Variabile


FILE OUT_file	:	text  IS OUT out_data_path ;



begin
----------------------------------------------------------------------------------------
--   PROCESSI
MAIN_WR : PROCESS (CLK)

variable  out_line :line;
variable  val      :integer; 
variable s : string ( 1 to 4 );

begin
  
if (clk='1' and clk'event)  then -- 
				if 	 WR_EN  = '1' THEN		
            s := STD_to_STR(DATA_IN) ;
				WRITE (out_line,s);
            WRITELINE(OUT_file,out_line);
				end if;

end if;
END PROCESS MAIN_WR;
--------------------------------------------------------------


end Behavioral;

