----------------------------------------------------------------------------------
-- Company:         INFN  NA
-- Engineer:         Alfonso
--
-- Create Date:
-- Design Name:
-- Module Name:    16b_OUT 20b_IN  codifica 8b10b
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

-----------------------------------------------------------------------------
 --         ENTITY
----------------------------------------------------------------------------
entity D16b_OUT_20b_IN_8b10b  is
    PORT(
            RESET   : IN  std_logic;
            RBCLK   : IN  std_logic;
            Data_IN : IN  std_logic_vector(19 downto 0);
            Data_OUT: OUT std_logic_vector(15 downto 0);
            KCom_OUT: OUT std_logic_vector( 1 downto 0)
        );
 END D16b_OUT_20b_IN_8b10b ;

architecture rtl of D16b_OUT_20b_IN_8b10b is
----------------------------------------------------------------------------
 --         COMPONENTI
----------------------------------------------------------------------------
COMPONENT dec_8b10b
    PORT(
        RESET : IN std_logic;
        RBYTECLK : IN std_logic;
        AI : IN std_logic;
        BI : IN std_logic;
        CI : IN std_logic;
        DI : IN std_logic;
        EI : IN std_logic;
        II : IN std_logic;
        FI : IN std_logic;
        GI : IN std_logic;
        HI : IN std_logic;
        JI : IN std_logic;
        KO : OUT std_logic;
        HO : OUT std_logic;
        GO : OUT std_logic;
        FO : OUT std_logic;
        EO : OUT std_logic;
        DO : OUT std_logic;
        CO : OUT std_logic;
        BO : OUT std_logic;
        AO : OUT std_logic
        );
    END COMPONENT;

----------------------------------------------------------------------------
 --         SEGNALI
----------------------------------------------------------------------------
--signal RESET   : IN  std_logic;
--signal RBCLK   : IN  std_logic;
--signal Data_IN : IN  std_logic_vector(19 downto 0);
--signal Data_OUT: OUT std_logic_vector(15 downto 0);
--signal KCom_OUT: OUT std_logic_vector( 1 downto 0);


begin

----------------------------------------------------------------------------
 --         ISTANZIA
----------------------------------------------------------------------------

--  ISTANZIA    8b/10b .......................... LOW ...............................
Inst_L_dec_8b10b: dec_8b10b PORT MAP(
        RESET => RESET,
        RBYTECLK => RBCLK,
        AI =>  Data_IN(0),
        BI =>  Data_IN(1),
        CI =>  Data_IN(2),
        DI =>  Data_IN(3),
        EI =>  Data_IN(4),
        II =>  Data_IN(5),
        FI =>  Data_IN(6),
        GI =>  Data_IN(7),
        HI =>  Data_IN(8),
        JI =>  Data_IN(9), -- j è il bit più significativo

        KO => KCom_OUT(0),  --       K COMMA    LOW ------

        HO => Data_OUT(7),
        GO => Data_OUT(6),
        FO => Data_OUT(5),
        EO => Data_OUT(4),
        DO => Data_OUT(3),
        CO => Data_OUT(2),
        BO => Data_OUT(1),
        AO => Data_OUT(0)
    );
--  ISTANZIA    8b/10b .......................... HIGH ...............................
Inst_H_dec_8b10b: dec_8b10b   PORT MAP(
        RESET => RESET,
        RBYTECLK => RBCLK,
        AI =>  Data_IN(10),
        BI =>  Data_IN(11),
        CI =>  Data_IN(12),
        DI =>  Data_IN(13),
        EI =>  Data_IN(14),
        II =>  Data_IN(15),
        FI =>  Data_IN(16),
        GI =>  Data_IN(17),
        HI =>  Data_IN(18),
        JI =>  Data_IN(19), -- j è il bit più significativo

        KO => KCom_OUT(1),  --       K COMMA    HIGH  ------

        HO => Data_OUT(15),
        GO => Data_OUT(14),
        FO => Data_OUT(13),
        EO => Data_OUT(12),
        DO => Data_OUT(11),
        CO => Data_OUT(10),
        BO => Data_OUT(9),
        AO => Data_OUT(8)
    );

 -------------------------------------------------------------------------



end rtl;
