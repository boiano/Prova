----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:46:18 08/26/2011 
-- Design Name: 
-- Module Name:    Serial_Receiver - Behavioral 
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

entity Serial_Receiver is
	Port (  clk 				: in  STD_LOGIC;
           rst 				: in  STD_LOGIC;
			  Serial_rx			: in  STD_LOGIC;
			  Cadence_rx		: in	STD_LOGIC;
			  busy_rx			: in	STD_LOGIC;
			  accepted_word		: out	STD_LOGIC;
			  received_word		: out STD_LOGIC_VECTOR(0 to 7));
end Serial_Receiver;

architecture Behavioral of Serial_Receiver is

signal rst_ShReg, end_lecture						:STD_LOGIC;
signal xend_lecture, xxend_lecture				:STD_LOGIC;
signal accept_data, reg_ok, r_reg_ok			:STD_LOGIC;
signal receive_stream								:STD_LOGIC_VECTOR(10 downto 0);

begin

----------------------- Syncornize Input -----------------------------
--
--syncronize_Rx:process(clk, rst)
--	begin
--		if rst='1' then
--			xserial_rx <= '0';
--			Serial_Rx <= '0';
--		else if(clk'event and clk = '1')then
--					Serial_Rx <= xserial_rx;
--					xserial_rx <= Serial_rx_async;
--				end if;
--		end if;
--end process syncronize_Rx;

----------------------------------------------------------------------
------------------ RICEZIONE E REGISTRAZIONE PAROLA ------------------
 
shift_register:process(clk, rst_ShReg)			-- ricezione seriale
	begin
		if rst_ShReg='1' then
			receive_stream <= (others=>'0');
		else if(clk'event and clk = '1')then
					if(cadence_rx='1')then
						for i in 1 to 10 loop
							receive_stream(i) <= receive_stream(i-1);
						end loop;
						receive_stream(0) <= Serial_Rx;
					end if;
				end if;
		end if;
end process shift_register;

------------------------------------- REGISTRAZIONE

accept_data <= receive_stream(10) and not receive_stream(1) and not receive_stream(0);

reg_accept_world:process(clk, rst)				-- Seriale -> Parallelo
	begin
		if rst='1' then
			received_word <= (others=>'0');
		else if(clk'event and clk = '1')then
					if(accept_data='1')then
						received_word(0 to 7) <= not receive_stream(9 downto 2);
					end if;
				end if;
		end if;
end process reg_accept_world;	

-------------------------------------

word_registred:process(clk, rst)				-- Reset Schift Register di ricezione x accettaizone parola
	begin
		if rst='1' then
			reg_ok 	<= '0';
			r_reg_ok <= '0';
		else if(clk'event and clk = '1')then
					reg_ok 	<= accept_data;
					r_reg_ok <= reg_ok;
				end if;
		end if;
end process word_registred;

rst_shift_register:process(clk, rst)				-- Reset Schift Register di ricezione x fine lettura
	begin
		if rst='1' then
			xend_lecture 	<= '0';
			xxend_lecture 	<= '0';
		else if(clk'event and clk = '1')then
					xend_lecture 	<= busy_rx;
					xxend_lecture 	<= xend_lecture;
				end if;
		end if;
end process rst_shift_register;

end_lecture <= xxend_lecture and not xend_lecture;

rst_ShReg <= rst or r_reg_ok or end_lecture;
-------------------------------------
accepted_word <= r_reg_ok;

end Behavioral;