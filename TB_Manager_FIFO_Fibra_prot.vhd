--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:10:11 12/19/2012
-- Design Name:   
-- Module Name:   C:/Xilinx/LAVORI/FAZIA/Test_Card_USB_16bit_V2/TB_Manager_FIFO_Fibra_prot.vhd
-- Project Name:  USB_16Bit_V2
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Manager_FIFO
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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;
 
ENTITY TB_Manager_FIFO_Fibra_prot IS
END TB_Manager_FIFO_Fibra_prot;
 
ARCHITECTURE behavior OF TB_Manager_FIFO_Fibra_prot IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Manager_FIFO
    PORT(
         rd_clk 			: IN  std_logic;
         wr_clk 			: IN  std_logic;
         rst 				: IN  std_logic;
         req_read_fifo 	: IN  std_logic;
         busy_Tx 			: IN  std_logic;
         Data_to_Serial : OUT  std_logic_vector(7 downto 0);
         Send_Data 		: OUT  std_logic;
         Data_to_USB 	: OUT  std_logic_vector(15 downto 0);
         USB_CLK 			: IN  std_logic;
         FIFO_nEmpty 	: OUT  std_logic;
         PK_ACK 			: IN  std_logic;
         en_wrt_fifo 	: IN  std_logic;
         almost_full 	: OUT  std_logic;
         Serial_USB 		: IN  std_logic;
         Data_to_FIFO 	: IN  std_logic_vector(15 downto 0);
         Kin 				: IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal rd_clk : std_logic := '0';
   signal wr_clk : std_logic := '0';
   signal rst : std_logic := '1';
   signal req_read_fifo : std_logic := '0';
   signal busy_Tx : std_logic := '0';
   signal USB_CLK : std_logic := '0';
   signal PK_ACK : std_logic := '0';
   signal en_wrt_fifo : std_logic := '0';
   signal Serial_USB : std_logic := '0';
   signal Data_to_FIFO : std_logic_vector(15 downto 0) := (others => '0');
   signal Kin : std_logic := '0';

 	--Outputs
   signal Data_to_Serial : std_logic_vector(7 downto 0);
   signal Send_Data : std_logic;
   signal Data_to_USB : std_logic_vector(15 downto 0);
   signal FIFO_nEmpty : std_logic;
   signal almost_full : std_logic;

   -- Clock period definitions
   constant rd_clk_period : time := 10 ns;
   constant wr_clk_period : time := 10 ns;
   constant USB_CLK_period : time := 10 ns;
	
	
	
	--   Miei Segnali
	signal Conta150M 			: std_logic_vector(15 downto 0) := (others => '0');
	signal Conta_pacchetti 	: std_logic_vector(11 downto 0) := (others => '0');
	
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Manager_FIFO PORT MAP (
          rd_clk 			=> rd_clk,
          wr_clk 			=> wr_clk,
          rst 				=> rst,
          req_read_fifo => req_read_fifo,
          busy_Tx 		=> busy_Tx,
          Data_to_Serial => Data_to_Serial,
          Send_Data 		=> Send_Data,
          Data_to_USB 	=> Data_to_USB,
          USB_CLK 		=> USB_CLK,
          FIFO_nEmpty 	=> FIFO_nEmpty,
          PK_ACK 			=> PK_ACK,
          en_wrt_fifo 	=> en_wrt_fifo,
          almost_full 	=> almost_full,
          Serial_USB 	=> Serial_USB,
          Data_to_FIFO 	=> Data_to_FIFO,
          Kin 				=> Kin
        );

   -- Clock process definitions
   rd_clk_process :process
   begin
		rd_clk <= '0';
		wait for rd_clk_period/2;
		rd_clk <= '1';
		wait for rd_clk_period/2;
   end process;
 
   wr_clk_process :process
   begin
		wr_clk <= '0';
		wait for wr_clk_period/2;
		wr_clk <= '1';

		wait for wr_clk_period/2;
   end process;
 
   USB_CLK_process :process
   begin
		USB_CLK <= '0';
		wait for USB_CLK_period/2;
		USB_CLK <= '1';
		wait for USB_CLK_period/2;
   end process;
 

   -- RESET
   stim_proc: process
   begin		
     rst <= '1' ;
      wait for 100 ns;	
     rst <= '0' ;
      wait for rd_clk_period*10;

      en_wrt_fifo <= '1' ;

      wait;
   end process;
	
	
	-----------------------------------------------------------------
	
	MAIN_process :process ( wr_clk  )  -- MAIN
   begin
	
	if(wr_clk'event and wr_clk='1') then

   Conta150M <= Conta150M +1 ;


   CASE Conta150M IS
	             WHEN  X"0000"  =>  Kin <= '0' ;  Data_to_FIFO <= X"1010"; 
                WHEN  X"0001"  =>  Kin <= '0' ;  Data_to_FIFO <= X"1212"; 
                WHEN  X"0002"  =>  Kin <= '1' ;  Data_to_FIFO <= X"00F0"; 
					 WHEN  X"0003"  =>  Kin <= '0' ;  Data_to_FIFO <= X"121F"; 
					 WHEN  X"0004"  =>  Kin <= '0' ;  Data_to_FIFO <= X"9990"; 
					 WHEN  X"0005"  =>  Kin <= '0' ;  Data_to_FIFO <= X"0000"; 
					 WHEN  X"0006"  =>  Kin <= '0' ;  Data_to_FIFO <= X"0000"; 
					 WHEN  X"0007"  =>  Kin <= '0' ;  Data_to_FIFO <= X"0000"; 
					 WHEN  X"0008"  =>  Kin <= '1' ;  Data_to_FIFO <= X"0010"; 
					 WHEN  X"0009"  =>  Kin <= '0' ;  Data_to_FIFO <= X"122F"; 
					 WHEN  X"000a"  =>  Kin <= '0' ;  Data_to_FIFO <= X"1000"; 
					 WHEN  X"000b"  =>  Kin <= '0' ;  Data_to_FIFO <= X"0000"; 
					 WHEN  X"000c"  =>  Kin <= '0' ;  Data_to_FIFO <= X"0000"; 
					 WHEN  X"000d"  =>  Kin <= '0' ;  Data_to_FIFO <= X"0000"; 
					 WHEN  X"000e"  =>  Kin <= '1' ;  Data_to_FIFO <= X"0020"; 
					 WHEN  X"000f"  =>  Kin <= '0' ;  Data_to_FIFO <= X"0000"; 
					 WHEN  X"0010"  =>  Kin <= '0' ;  Data_to_FIFO <= X"0000"; 
					 WHEN  X"0011"  =>  Kin <= '0' ;  Data_to_FIFO <= X"0000"; 
					 WHEN  X"0012"  =>  Kin <= '0' ;  Data_to_FIFO <= X"0000"; 
					 WHEN  X"0013"  =>  Kin <= '0' ;  Data_to_FIFO <= X"0000"; 
					 WHEN  X"0014"  =>  Kin <= '1' ;  Data_to_FIFO <= X"0040"; 
					 WHEN  X"0015"  =>  Kin <= '0' ;  Data_to_FIFO <= X"0000"; 
					 WHEN  X"0016"  =>  Kin <= '0' ;  Data_to_FIFO <= X"9990"; 
					 WHEN  X"0017"  =>  Kin <= '0' ;  Data_to_FIFO <= X"0000"; 
					 WHEN  X"0018"  =>  Kin <= '0' ;  Data_to_FIFO <= X"0000"; 
					 WHEN  X"0019"  =>  Kin <= '0' ;  Data_to_FIFO <= X"0000"; 
					 WHEN  X"001a"  =>  Kin <= '1' ;  Data_to_FIFO <= X"0010"; 
					 WHEN  X"001b"  =>  Kin <= '0' ;  Data_to_FIFO <= X"122F"; 
					 WHEN  X"001c"  =>  Kin <= '0' ;  Data_to_FIFO <= X"1000"; 
					 WHEN  X"001d"  =>  Kin <= '0' ;  Data_to_FIFO <= X"0000"; 
					 WHEN  X"001e"  =>  Kin <= '0' ;  Data_to_FIFO <= X"0000"; 
					 WHEN  X"001f"  =>  Kin <= '0' ;  Data_to_FIFO <= X"0000"; 
					-- 	WHEN  X"0020"  =>  Kin <= '0' ;  Data_to_FIFO <= X"0020";  -- Errore mancanza K
							WHEN  X"0020"  =>  Kin <= '1' ;  Data_to_FIFO <= X"0020";  --  OK
					 WHEN  X"0021"  =>  Kin <= '0' ;  Data_to_FIFO <= X"0000"; 
					 WHEN  X"0022"  =>  Kin <= '0' ;  Data_to_FIFO <= X"0000"; 
					 WHEN  X"0023"  =>  Kin <= '0' ;  Data_to_FIFO <= X"0000"; 
					 WHEN  X"0024"  =>  Kin <= '0' ;  Data_to_FIFO <= X"0000"; 
				--	 WHEN  X"0025"  =>  Kin <= '0' ;  Data_to_FIFO <= X"0000"; 
									--		Continua l'ultima sequenza di pacchtti
                  WHEN OTHERS =>   Kin <= '0' ;  			Data_to_FIFO <= X"aaaa";     
											Conta150M <= X"0014"; 	Conta_pacchetti <= Conta_pacchetti +1 ;  -- FINE
      END CASE;              
	
	   if Conta_pacchetti = X"300" then
		                    Conta_pacchetti <= X"000";
	                       Conta150M       <= X"0000";
		end if ;
	
	end if ;
end process;
	
	
	
	
	
	
	
	
	

END;
