----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:18:31 04/17/2009 
-- Design Name: 
-- Module Name:    aligner - Behavioral 
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
--library UNISIM;
--use UNISIM.VComponents.all;
--------------------------------------------------------------------------------
entity pulsegenerator is                           --   ENTITY --------------
    Port ( clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           start : in  STD_LOGIC;
           nofpulses : in  STD_LOGIC_VECTOR (4 downto 0);
			  done : out std_logic;
           pulse_out : out  STD_LOGIC);
end pulsegenerator;
 ----------------------------------------------------------------------------
                                                      --   SEGNALI ----------
architecture Behavioral of pulsegenerator is

signal countwait : std_logic_vector(1 downto 0);
signal countpulse : std_logic_vector(4 downto 0);
signal i_nofpulses : std_logic_vector(4 downto 0);
signal countwaiten : std_logic;
signal Busy     : std_logic_vector(7 downto 0);

------------------------------------------------------------------------------
begin

	-- Two linked counters generate a number of pulses equal to nofpulses 
	pulsegen_proc: process (Clock, Reset) 
	begin
		if Reset='1' then 

			countwait <= (others => '0');
			countpulse <= (others => '0');
			i_nofpulses <= (others => '0');
			countwaiten <= '0';	
		   pulse_out <= '0';
			done <= '1';
			Busy <= (others => '0');
			
		elsif clock='1' and clock'event then
			
			pulse_out <= '0';
			
			
			-- incrementa il conteggio per attendere tra un 
			-- impulso ed il successivo
			if countwaiten = '1' then
				countwait <= countwait+1;
         end if;
			
			-- strobe che avvia la sequenza di generazione
			-- viene accettata solo se la precedente generazione 
			-- di impulsi era sta completata 
			if start = '1' and countwaiten = '0' then 
				
				done <= '0';
				countwait <= (others => '0');
				countwaiten <= '1';
				i_nofpulses <= nofpulses;
			   countpulse <= (others => '0');
				Busy <= (others => '0');
				
			-- ad ogni passaggio di countwait per 3	
			elsif countwait  =  X"3" then
			   
				countwait <= (others => '0');
				
				-- Se ha generato tutti gli impulsi, 
				-- disabilita il contatore wait
				if countpulse = i_nofpulses then
				
				  if Busy = X"FF" then --  Mette un ritardo
					countwaiten <= '0';
					done <= '1';
					else
				   Busy <=  Busy +1 ;
					end if;
				  
				else 
					-- altrimenti genera un nuovo impulso	
					countpulse <= countpulse+1;
					pulse_out <= '1';
				end if;
				
			end if;
			
		end if;
	end process;

	

end Behavioral;


