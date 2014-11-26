----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    16:30:48 04/17/2009
-- Design Name:
-- Module Name:    commadetector - Behavioral
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

-- K28.2 plus  001111 0101
--       minus 110000 1010
-- K28.5 plus  001111 1010
--			minus 110000 0101
entity commadetector is

    generic ( --pcomma : std_logic_vector(9 downto 0) := "0011111010";
	           pcomma : std_logic_vector(9 downto 0) := "1001110100";
	           mcomma : std_logic_vector(9 downto 0) := "0110001011");
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
			  datain : in  STD_LOGIC_VECTOR (19 downto 0);
           found : out  STD_LOGIC;
           bitoffset : out  STD_LOGIC_VECTOR (4 downto 0));
end commadetector;

architecture RTL of commadetector is


signal swapped_datain :  STD_LOGIC_VECTOR (19 downto 0);
signal word :  STD_LOGIC_VECTOR (28 downto 0);  --- Parola Lunga
signal i_found : STD_LOGIC_VECTOR(19 downto 0);


begin

-- reverses bit-ordering
swapgen:  for i in 0 to 19 generate
begin
         swapped_datain(i) <=  datain(19-i);  -- Inverte
end generate;
---------------------------------



process (clk, rst)   ---        PROCESSO   ------
variable tmp : std_logic ;
begin
	if rst='1' then
		word <= (others => '0');
		i_found <= (others => '0');
		found <= '0';
		bitoffset <= (others => '0');
		
	elsif rising_edge(clk) then
      word <=   word(8 downto 0)  &  swapped_datain ;     -- Parte Mancante della parola al clk successivo
		-- found è l'or dei i_found   --------------------------------------------
		tmp := '0';
		for i in 0 to 19 loop
			tmp := tmp or i_found(i);
			
			if i_found(0) = '1' then 
			       bitoffset <= conv_std_logic_vector(0,5);
			else if (i_found(i) = '1') and (not i_found(0) = '1') then
			       bitoffset <= conv_std_logic_vector(20-i,5);				
	      end if;	
		--overwrite the zero offset
		  -- if i_found(0) = '1' then 
			--    bitoffset <= conv_std_logic_vector(0,4);
		   end if;	
			
		end loop;
--------------------------------------------------------------------------------


		found <= tmp;  --  Assegna l'uscita 
	
----------------------------------------------------------------------------
		for i in 0 to 19 loop        -- Looks for comma
			-- this synthetizes in a 10 bit function (2 levels of LUTs)
			if word(9+i downto i)=pcomma or word(9+i downto i)=mcomma then
				 i_found(i) <= '1';
			     else
			        i_found(i) <= '0';
			end if;
			-- i_found is  a onehot coded 10-bit word
         -- the position of the one indicates the offset of the comma
		end loop;
-------------------------------------------------------------------------------

	end if;

end process;


end RTL;
