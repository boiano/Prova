--
-- Modificato da  Alfonso boiano
-- Prima prova Fixed Latency
---------------------------------------------
----------------------------------------------
---------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;


--***********************************Entity Declaration************************

entity GTX_FISSO_TOP is
generic
(
    EXAMPLE_CONFIG_INDEPENDENT_LANES        : integer   := 1;
    EXAMPLE_LANE_WITH_START_CHAR            : integer   := 0;
    EXAMPLE_WORDS_IN_BRAM                   : integer   := 512;
    EXAMPLE_SIM_MODE                        : string    := "FAST";
    EXAMPLE_SIM_GTXRESET_SPEEDUP            : integer   := 1;
    EXAMPLE_SIM_PLL_PERDIV2                 : bit_vector:= x"14d";
    EXAMPLE_USE_CHIPSCOPE                   : integer   := 0     -- Set to 1 to use Chipscope to drive resets
);


port
(
   -- TILE0_REFCLK_PAD_N_IN                   : in   std_logic;   -- REF CLK
  --  TILE0_REFCLK_PAD_P_IN                   : in   std_logic;   -- REF CLK
	 tile0_refclk_i								  : in   std_logic;   -- REF CLK

     --     Sezione RESET
    RESET_DONE_OUT                          : out  std_logic;   -- RESET DONE
    GTXRESET_IN                             : in   std_logic;   -- RESET --------  RESET
    TILE0_PLLLKDET_OUT                      : out  std_logic;   --  PLL LOCHED -----

        -- Sezione TX
    GTX_Data_IN                             : in   std_logic_vector(15 downto 0);     -- DATA IN
    K_Comma_IN                              : in   std_logic_vector( 1 downto 0);     -- K_COMMA IN
    Ref_CLK_OUT                             : out   std_logic;   --                      REF CLK     dal pin d'ingresso
    TX_SYNC_DONE                            : out  std_logic;    --                      TX SYNC DONE Sincronizzazione del TX eseguita
    LockFailed_OUT 								  : out  std_logic;    --        LOCK FAILED  

        -- Sezione RX
    GTX_Data_OUT                            : out  std_logic_vector(15 downto 0);     -- DATA OUT
    K_Comma_OUT                             : out   std_logic_vector( 1 downto 0);     -- K_COMMA OUT
    RX_REC_CLK_OUT                          : out   std_logic;    --                     RX  RECOVERED & Buffered  CLK
    RX_ALLINEATO_OUT                        : out   std_logic;    --                   RX _ ALLINEATO

     --   3Gbit RX e TX    ----
    RXN_IN                                  : in   std_logic;       --
    RXP_IN                                  : in   std_logic;
    TXN_OUT                                 : out  std_logic;
    TXP_OUT                                 : out  std_logic
);


    attribute X_CORE_INFO : string;
    attribute X_CORE_INFO of GTX_FISSO_TOP : entity is "gtxwizard_v1_6, Coregen v11.2";

end GTX_FISSO_TOP;

architecture RTL of GTX_FISSO_TOP is

--**************************Component Declarations*****************************


component GTX_FISSO
generic
(
    -- Simulation attributes
    WRAPPER_SIM_MODE                : string    := "FAST"; -- Set to Fast Functional Simulation Model
    WRAPPER_SIM_GTXRESET_SPEEDUP    : integer   := 0; -- Set to 1 to speed up sim reset
    WRAPPER_SIM_PLL_PERDIV2         : bit_vector:= x"14d" -- Set to the VCO Unit Interval time
);
port
(

    --_________________________________________________________________________
    --_________________________________________________________________________
    --TILE0  (Location)

    ------------------------ Loopback and Powerdown Ports ----------------------
    TILE0_LOOPBACK0_IN                      : in   std_logic_vector(2 downto 0);
    TILE0_LOOPBACK1_IN                      : in   std_logic_vector(2 downto 0);
    --------------- Receive Ports - Comma Detection and Alignment --------------
    TILE0_RXENMCOMMAALIGN0_IN               : in   std_logic;
    TILE0_RXENMCOMMAALIGN1_IN               : in   std_logic;
    TILE0_RXENPCOMMAALIGN0_IN               : in   std_logic;
    TILE0_RXENPCOMMAALIGN1_IN               : in   std_logic;
    TILE0_RXSLIDE0_IN                       : in   std_logic;
    TILE0_RXSLIDE1_IN                       : in   std_logic;
    ------------------- Receive Ports - RX Data Path interface -----------------
    TILE0_RXDATA0_OUT                       : out  std_logic_vector(19 downto 0);
    TILE0_RXDATA1_OUT                       : out  std_logic_vector(19 downto 0);
    TILE0_RXRECCLK0_OUT                     : out  std_logic;
    TILE0_RXRECCLK1_OUT                     : out  std_logic;
    TILE0_RXUSRCLK0_IN                      : in   std_logic;
    TILE0_RXUSRCLK1_IN                      : in   std_logic;
    TILE0_RXUSRCLK20_IN                     : in   std_logic;
    TILE0_RXUSRCLK21_IN                     : in   std_logic;
    ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    TILE0_RXN0_IN                           : in   std_logic;
    TILE0_RXN1_IN                           : in   std_logic;
    TILE0_RXP0_IN                           : in   std_logic;
    TILE0_RXP1_IN                           : in   std_logic;
    -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    TILE0_RXBUFSTATUS0_OUT                  : out  std_logic_vector(2 downto 0);
    TILE0_RXBUFSTATUS1_OUT                  : out  std_logic_vector(2 downto 0);
    --------------------- Shared Ports - Tile and PLL Ports --------------------
    TILE0_CLKIN_IN                          : in   std_logic;
    TILE0_GTXRESET_IN                       : in   std_logic;
    TILE0_PLLLKDET_OUT                      : out  std_logic;    -- PLL LOCKED OUT
    TILE0_REFCLKOUT_OUT                     : out  std_logic;
    TILE0_RESETDONE0_OUT                    : out  std_logic;
    TILE0_RESETDONE1_OUT                    : out  std_logic;
    ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    TILE0_TXCHARISK0_IN                     : in   std_logic_vector(1 downto 0);
    TILE0_TXCHARISK1_IN                     : in   std_logic_vector(1 downto 0);
    ------------------ Transmit Ports - TX Data Path interface -----------------
    TILE0_TXDATA0_IN                        : in   std_logic_vector(15 downto 0);
    TILE0_TXDATA1_IN                        : in   std_logic_vector(15 downto 0);
    TILE0_TXUSRCLK0_IN                      : in   std_logic;
    TILE0_TXUSRCLK1_IN                      : in   std_logic;
    TILE0_TXUSRCLK20_IN                     : in   std_logic;
    TILE0_TXUSRCLK21_IN                     : in   std_logic;
    --------------- Transmit Ports - TX Driver and OOB signalling --------------
    TILE0_TXN0_OUT                          : out  std_logic;
    TILE0_TXN1_OUT                          : out  std_logic;
    TILE0_TXP0_OUT                          : out  std_logic;
    TILE0_TXP1_OUT                          : out  std_logic;
    -------- Transmit Ports - TX Elastic Buffer and Phase Alignment Ports ------
    TILE0_TXENPMAPHASEALIGN0_IN             : in   std_logic;
    TILE0_TXENPMAPHASEALIGN1_IN             : in   std_logic;
    TILE0_TXPMASETPHASE0_IN                 : in   std_logic;
    TILE0_TXPMASETPHASE1_IN                 : in   std_logic


);
end component;
-------------------------------------------------------      COMPONENTI   ALFO  ------------

 COMPONENT D16b_OUT_20b_IN_8b10b      							 --    D16b_OUT_20b_IN_8b10b ----
    PORT(
         RESET : IN  std_logic;
         RBCLK : IN  std_logic;
         Data_IN : IN  std_logic_vector(19 downto 0);
         Data_OUT : OUT  std_logic_vector(15 downto 0);
         KCom_OUT : OUT  std_logic_vector(1 downto 0)
        );
    END COMPONENT;

   COMPONENT Aligner_noRes                                      --    ALIGNER -------------
    PORT ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           DATAIN : in  STD_LOGIC_VECTOR (19 downto 0);
			  Tx_Sync_done : in  STD_LOGIC;
           Aligned : out  STD_LOGIC;
			  LockFailed : out STD_LOGIC; 
           RXSLIDE : out  STD_LOGIC );
    END COMPONENT;


  COMPONENT  RESETTATORE_ALLINEA                          --   RESETTATORE   ----
    Port ( CLK_TX 		: in  STD_LOGIC;
	        CLK_RX 		: in  STD_LOGIC;
           RST 			: in  STD_LOGIC;
           FAIL			: in  STD_LOGIC;
		TX_SYNC_DONE_in   : in  STD_LOGIC;
			  Align_OFF 	: out  STD_LOGIC;
           OUT_RES   	: out  STD_LOGIC);
    END  COMPONENT;

component MGT_USRCLK_SOURCE                              --- MGT_USRCLK_SOURCE  ------
generic
(
    FREQUENCY_MODE   : string   := "LOW";
    PERFORMANCE_MODE : string   := "MAX_SPEED"
);
port
(
    DIV1_OUT                : out std_logic;
    DIV2_OUT                : out std_logic;
    DCM_LOCKED_OUT          : out std_logic;
    CLK_IN                  : in  std_logic;
    DCM_RESET_IN            : in  std_logic

);
end component;



component MGT_USRCLK_SOURCE_PLL                        --  MGT_USRCLK_SOURCE_PLL ------
generic
(
    MULT                 : integer          := 2;
    DIVIDE               : integer          := 2;
    CLK_PERIOD           : real             := 6.67;
    OUT0_DIVIDE          : integer          := 2;
    OUT1_DIVIDE          : integer          := 2;
    OUT2_DIVIDE          : integer          := 2;
    OUT3_DIVIDE          : integer          := 2;
    SIMULATION_P         : integer          := 1;
    LOCK_WAIT_COUNT      : std_logic_vector := "1000001000110101"
);
port
(
    CLK0_OUT                : out std_logic;
    CLK1_OUT                : out std_logic;
    CLK2_OUT                : out std_logic;
    CLK3_OUT                : out std_logic;
    CLK_IN                  : in  std_logic;
    PLL_LOCKED_OUT          : out std_logic;
    PLL_RESET_IN            : in  std_logic
);
end component;


component TX_SYNC                                        --   TX_SYNC ----------------------
generic
(
    PLL_DIVSEL_OUT       : integer := 1
);
port
(
    TXENPMAPHASEALIGN       : out std_logic;
    TXPMASETPHASE           : out std_logic;
    SYNC_DONE               : out std_logic;
    USER_CLK                : in  std_logic;
    RESET                   : in  std_logic
);
end component;
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

  --***********************************Parameter Declarations********************

    constant DLY : time := 1 ns;


--************************** Register Declarations ****************************      SEGNALI -----

    signal   tile0_tx_resetdone0_r           : std_logic;
    signal   tile0_tx_resetdone0_r2          : std_logic;
    --signal   tile0_rx_resetdone0_r           : std_logic;
    --signal   tile0_rx_resetdone0_r2          : std_logic;
    --signal   tile0_tx_resetdone1_r           : std_logic;
    --signal   tile0_tx_resetdone1_r2          : std_logic;
    --signal   tile0_rx_resetdone1_r           : std_logic;
    --signal   tile0_rx_resetdone1_r2          : std_logic;


    --signal    track_data_out_i                : std_logic;

--**************************** Wire Declarations ******************************

    -------------------------- MGT Wrapper Wires ------------------------------

    --________________________________________________________________________
    --________________________________________________________________________
    --TILE0   (X0Y2)

    ------------------------ Loopback and Powerdown Ports ----------------------
    --signal  tile0_loopback0_i               : std_logic_vector(2 downto 0);
    --signal  tile0_loopback1_i               : std_logic_vector(2 downto 0);
    --------------- Receive Ports - Comma Detection and Alignment --------------
    --signal  tile0_rxenmcommaalign0_i        : std_logic;
   --signal  tile0_rxenmcommaalign1_i        : std_logic;
    --signal  tile0_rxenpcommaalign0_i        : std_logic;
    --signal  tile0_rxenpcommaalign1_i        : std_logic;
    signal  tile0_rxslide0_i                : std_logic;
    --signal  tile0_rxslide1_i                : std_logic;
    ------------------- Receive Ports - RX Data Path interface -----------------
    signal  tile0_rxdata0_i                 : std_logic_vector(19 downto 0);
    --signal  tile0_rxdata1_i                 : std_logic_vector(19 downto 0);
    signal  tile0_rxrecclk0_i               : std_logic;
   -- signal  tile0_rxrecclk1_i               : std_logic;
    -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
  --  signal  tile0_rxbufstatus0_i            : std_logic_vector(2 downto 0);
  --signal  tile0_rxbufstatus1_i            : std_logic_vector(2 downto 0);
    --------------------- Shared Ports - Tile and PLL Ports --------------------
    signal  tile0_gtxreset_i                : std_logic;
    signal  tile0_plllkdet_i                : std_logic;
    signal  tile0_refclkout_i               : std_logic;
    signal  tile0_resetdone0_i              : std_logic;
    --signal  tile0_resetdone1_i              : std_logic;
    ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    signal  tile0_txcharisk0_i              : std_logic_vector(1 downto 0);
    -- signal  tile0_txcharisk1_i              : std_logic_vector(1 downto 0);
    ------------------ Transmit Ports - TX Data Path interface -----------------
    signal  tile0_txdata0_i                 : std_logic_vector(15 downto 0);
    --signal  tile0_txdata1_i                 : std_logic_vector(15 downto 0);
    -------- Transmit Ports - TX Elastic Buffer and Phase Alignment Ports ------
    signal  tile0_txenpmaphasealign0_i      : std_logic;
    --signal  tile0_txenpmaphasealign1_i      : std_logic;
    signal  tile0_txpmasetphase0_i          : std_logic;
    --signal  tile0_txpmasetphase1_i          : std_logic;


    ------------------------------- Global Signals -----------------------------
    --signal  tile0_tx_system_reset0_c        : std_logic;
    --signal  tile0_rx_system_reset0_c        : std_logic;
    --signal  tile0_tx_system_reset1_c        : std_logic;
    --signal  tile0_rx_system_reset1_c        : std_logic;
    signal  tied_to_ground_i                : std_logic;
    signal  tied_to_ground_vec_i            : std_logic_vector(15 downto 0);
    signal  tied_to_vcc_i                   : std_logic;
    signal  tied_to_vcc_vec_i               : std_logic_vector(7 downto 0);
   -- signal  drp_clk_in_i                    : std_logic;

    --signal  tile0_refclkout_bufg_i          : std_logic;
	 
	 


    ----------------------------- User Clocks ---------------------------------
    signal  tile0_txusrclk0_i               : std_logic;
    signal  tile0_rxusrclk0_i               : std_logic;
   -- signal  tile0_rxusrclk1_i               : std_logic;


    ----------------------- Frame check/gen Module Signals --------------------
   -- signal  tile0_refclk_i                  : std_logic;       --  CLOCK in al GTX dopo il ricevitore diff
    --signal  tile0_matchn0_i                 : std_logic;

    --signal  tile0_txcharisk0_float_i        : std_logic_vector(1 downto 0);
    --signal  tile0_txdata0_float_i           : std_logic_vector(23 downto 0);


    --signal  tile0_block_sync0_i             : std_logic;
    --signal  tile0_track_data0_i             : std_logic;
    --signal  tile0_error_count0_i            : std_logic_vector(7 downto 0);
    --signal  tile0_frame_check0_reset_i      : std_logic;
    --signal  tile0_inc_in0_i                 : std_logic;
    --signal  tile0_inc_out0_i                : std_logic;
    --signal  tile0_unscrambled_data0_i       : std_logic_vector(19 downto 0);
    --signal  tile0_matchn1_i                 : std_logic;

    --signal  tile0_txcharisk1_float_i        : std_logic_vector(1 downto 0);
    --signal  tile0_txdata1_float_i           : std_logic_vector(23 downto 0);


    --signal  tile0_block_sync1_i             : std_logic;
    --signal  tile0_track_data1_i             : std_logic;
    --signal  tile0_error_count1_i            : std_logic_vector(7 downto 0);
    --signal  tile0_frame_check1_reset_i      : std_logic;
    --signal  tile0_inc_in1_i                 : std_logic;
    --signal  tile0_inc_out1_i                : std_logic;
    --signal  tile0_unscrambled_data1_i       : std_logic_vector(19 downto 0);

    --signal  reset_on_data_error_i           : std_logic;

    ------------------------- Sync Module Signals -----------------------------


    signal  tile0_tx_sync_done0_i           : std_logic;
    signal  tile0_reset_txsync0_c           : std_logic;
   -- signal  tile0_tx_sync_done1_i           : std_logic;
   -- signal  tile0_reset_txsync1_c           : std_logic;

    signal  Wire_RX_LockFailed              : std_logic; -- segnale di aggancio fallito
	 signal  Wire_RX_ALLINEATO               : std_logic; -- segnale di aggancio Riuscito
	 
 --------------------   ALFO   ---- Monostabile RESET allineatore
	
	 signal  FAIL                            : std_logic;
	 
	 signal NON_USATO                         : std_logic_vector(29 downto 0);


--**************************** Main Body of Code *******************************
begin

    --  Static signal Assigments
    tied_to_ground_i                        <= '0';
    tied_to_ground_vec_i                    <= x"0000";
    tied_to_vcc_i                           <= '1';
    tied_to_vcc_vec_i                       <= x"ff";





    -----------------------Dedicated GTX Reference Clock Inputs ---------------
    -- The dedicated reference clock inputs you selected in the GUI are implemented using
    -- IBUFDS instances.
    --
    -- In the UCF file for this example design, you will see that each of
    -- these IBUFDS instances has been LOCed to a particular set of pins. By LOCing to these
    -- locations, we tell the tools to use the dedicated input buffers to the GTX reference
    -- clock network, rather than general purpose IOs. To select other pins, consult the
    -- Implementation chapter of UG196, or rerun the wizard.
    --
    -- This network is the highest performace (lowest jitter) option for providing clocks
    -- to the GTX transceivers.

--    tile0_refclk_ibufds_i : IBUFDS
--    port map
--    (
--        O                               =>      tile0_refclk_i,
--        I                               =>      TILE0_REFCLK_PAD_P_IN,
--        IB                              =>      TILE0_REFCLK_PAD_N_IN
--    );


    ----------------------------------- User Clocks ---------------------------

    -- The clock resources in this section were added based on userclk source selections on
    -- the Latency, Buffering, and Clocking page of the GUI. A few notes about user clocks:
    -- * The userclk and userclk2 for each GTX datapath (TX and RX) must be phase aligned to
    --   avoid data errors in the fabric interface whenever the datapath is wider than 10 bits
    -- * To minimize clock resources, you can share clocks between GTXs. GTXs using the same frequency
    --   or multiples of the same frequency can be accomadated using DCMs and PLLs. Use caution when
    --   using RXRECCLK as a clock source, however - these clocks can typically only be shared if all
    --   the channels using the clock are receiving data from TX channels that share a reference clock
    --   source with each other.

    refclkout_bufg0_i : BUFG
    port map
    (
        I                               =>      tile0_refclkout_i,
        O                               =>      tile0_txusrclk0_i
    );


    rxrecclk_bufg1_i : BUFG
    port map
    (
        I                               =>      tile0_rxrecclk0_i,     -- Proveniente da RXRECCLK
        O                               =>      tile0_rxusrclk0_i      --  USATO x dati  ed inviato a RXUSRCLK & RXUSRCLK2
    );





    ----------------------------- The GTX Wrapper -----------------------------

    -- Use the instantiation template in the project directory to add the GTX wrapper to your design.
    -- In this example, the wrapper is wired up for basic operation with a frame generator and frame
    -- checker. The GTXs will reset, then attempt to align and transmit data. If channel bonding is
    -- enabled, bonding should occur after alignment.


    -- Wire all PLLLKDET signals to the top level as output ports
    TILE0_PLLLKDET_OUT        <= tile0_plllkdet_i;



    gtx_fisso_i : GTX_FISSO
    generic map
    (
        WRAPPER_SIM_MODE                =>      EXAMPLE_SIM_MODE,
        WRAPPER_SIM_GTXRESET_SPEEDUP    =>      EXAMPLE_SIM_GTXRESET_SPEEDUP,
        WRAPPER_SIM_PLL_PERDIV2         =>      EXAMPLE_SIM_PLL_PERDIV2
    )
    port map
    (

        --_____________________________________________________________________
        --_____________________________________________________________________
        --TILE0  (X0Y2)

        ------------------------ Loopback and Powerdown Ports ----------------------
       TILE0_LOOPBACK0_IN              =>      tied_to_ground_vec_i(2 downto 0) ,     -- OFF
       TILE0_LOOPBACK1_IN              =>      tied_to_ground_vec_i(2 downto 0) ,     -- OFF
        --------------- Receive Ports - Comma Detection and Alignment --------------
       TILE0_RXENMCOMMAALIGN0_IN       =>      '0',
       TILE0_RXENMCOMMAALIGN1_IN       =>      '0',
       TILE0_RXENPCOMMAALIGN0_IN       =>      '0',
       TILE0_RXENPCOMMAALIGN1_IN       =>      '0',
       TILE0_RXSLIDE0_IN               =>      tile0_rxslide0_i,       -- RX SLIDE  x allineare sulla COMMA
       TILE0_RXSLIDE1_IN               =>      '0',
        ------------------- Receive Ports - RX Data Path interface -----------------
       TILE0_RXDATA0_OUT               =>      tile0_rxdata0_i,         -- DATI  OUT dall RX 20bit
       TILE0_RXDATA1_OUT               =>      NON_USATO(19 downto 0) ,
       TILE0_RXRECCLK0_OUT             =>      tile0_rxrecclk0_i,      --  RX CLOCK RECOVERED   OUT  |> -
       TILE0_RXRECCLK1_OUT             =>      NON_USATO(20) ,                  --                                |
       TILE0_RXUSRCLK0_IN              =>      tile0_rxusrclk0_i,      --  RX CLOCK USER   IN        ----|
       TILE0_RXUSRCLK1_IN              =>      '0',                    --    |
       TILE0_RXUSRCLK20_IN             =>      tile0_rxusrclk0_i,      --  __|
       TILE0_RXUSRCLK21_IN             =>      '0',
        ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
       TILE0_RXN0_IN                   =>      RXN_IN,              --  SER 3Gbit IN
       TILE0_RXN1_IN                   =>     '0',
       TILE0_RXP0_IN                   =>      RXP_IN,              --  SER 3Gbit IN
       TILE0_RXP1_IN                   =>     '1',
        -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
       TILE0_RXBUFSTATUS0_OUT          =>      NON_USATO(23 downto 21) , -- tile0_rxbufstatus0_i,   -- Indica lo stato del BUFFER di RICEZIONE   [2:0] ----- NON USATO ----- !!!!!!!
       TILE0_RXBUFSTATUS1_OUT          =>      NON_USATO(26 downto 24),
        --------------------- Shared Ports - Tile and PLL Ports --------------------
       TILE0_CLKIN_IN                  =>      tile0_refclk_i,        -- CLK in GTX dopo il ricevitore DIFF
       TILE0_GTXRESET_IN               =>      tile0_gtxreset_i,      -- PIN d'ingresso di RESET     GTXRESET_IN
       TILE0_PLLLKDET_OUT              =>      tile0_plllkdet_i,      --  PLL LOCKED
       TILE0_REFCLKOUT_OUT             =>      tile0_refclkout_i,     --  Uguale a CLKIN
       TILE0_RESETDONE0_OUT            =>      tile0_resetdone0_i,    -- GTX RESET Eseguito
       TILE0_RESETDONE1_OUT            =>      NON_USATO(27) ,
        ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
       TILE0_TXCHARISK0_IN             =>      tile0_txcharisk0_i,  --  vett[3:0] Invia K character  [0]=TXdata[7:0] [1]=TXdata[15:8] [2]=TXdata[23:16] [2]=TXdata[31:24]
       TILE0_TXCHARISK1_IN             =>      tied_to_ground_vec_i(1 downto 0), -- tile0_txcharisk1_i,
        ------------------ Transmit Ports - TX Data Path interface -----------------
       TILE0_TXDATA0_IN                =>      tile0_txdata0_i,
       TILE0_TXDATA1_IN                =>      tied_to_ground_vec_i(15 downto 0),
       TILE0_TXUSRCLK0_IN              =>      tile0_txusrclk0_i,
       TILE0_TXUSRCLK1_IN              =>      '0',
       TILE0_TXUSRCLK20_IN             =>      tile0_txusrclk0_i,
       TILE0_TXUSRCLK21_IN             =>      '0',
        --------------- Transmit Ports - TX Driver and OOB signalling --------------
       TILE0_TXN0_OUT                  =>      TXN_OUT,
       TILE0_TXN1_OUT                  =>      NON_USATO(28)  ,
       TILE0_TXP0_OUT                  =>      TXP_OUT,
       TILE0_TXP1_OUT                  =>      NON_USATO(29),
        -------- Transmit Ports - TX Elastic Buffer and Phase Alignment Ports ------
       TILE0_TXENPMAPHASEALIGN0_IN     =>      tile0_txenpmaphasealign0_i,
       TILE0_TXENPMAPHASEALIGN1_IN     =>      '0',
       TILE0_TXPMASETPHASE0_IN         =>      tile0_txpmasetphase0_i,
       TILE0_TXPMASETPHASE1_IN         =>      '0'


    );




    ------------------------------ TXSYNC module ------------------------------
    -- The TXSYNC module performs phase synchronization for all the active TX datapaths. It
    -- waits for the user clocks to be stable, then drives the phase align signals on each
    -- GTX. When phase synchronization is complete, it asserts SYNC_DONE

    -- Include the TX_SYNC module in your own design to perform phase synchronization if
    -- your protocol bypasses the TX Buffers


    tile0_reset_txsync0_c  <=  not tile0_tx_resetdone0_r2;

    tile0_txsync0_i : TX_SYNC
    generic map
    (
        PLL_DIVSEL_OUT                  =>      1
    )
    port map
    (
        TXENPMAPHASEALIGN               =>      tile0_txenpmaphasealign0_i,
        TXPMASETPHASE                   =>      tile0_txpmasetphase0_i,
        SYNC_DONE                       =>      tile0_tx_sync_done0_i,
        USER_CLK                        =>      tile0_txusrclk0_i,
        RESET                           =>      tile0_reset_txsync0_c
    );



   -- tile0_reset_txsync1_c  <=  not tile0_tx_resetdone1_r2;

   -- tile0_txsync1_i : TX_SYNC
   -- generic map
   -- (
   --     PLL_DIVSEL_OUT                  =>      1
   -- )
   -- port map
   -- (
   --     TXENPMAPHASEALIGN               =>      tile0_txenpmaphasealign1_i,
   --     TXPMASETPHASE                   =>      tile0_txpmasetphase1_i,
   --     SYNC_DONE                       =>      tile0_tx_sync_done1_i,
   --     USER_CLK                        =>      tile0_txusrclk0_i,
   --     RESET                           =>      tile0_reset_txsync1_c
   -- );





    -------------------------- User Module Resets -----------------------------
    -- All the User Modules i.e. FRAME_GEN, FRAME_CHECK and the sync modules
    -- are held in reset till the RESETDONE goes high.
    -- The RESETDONE is registered a couple of times on USRCLK2 and connected
    -- to the reset of the modules

 --   process( tile0_rxusrclk0_i,tile0_resetdone0_i)
 --   begin
 --       if(tile0_resetdone0_i = '0') then
 --           tile0_rx_resetdone0_r  <= '0'   after DLY;
 --           tile0_rx_resetdone0_r2 <= '0'   after DLY;
 --       elsif(tile0_rxusrclk0_i'event and tile0_rxusrclk0_i = '1') then
 --           tile0_rx_resetdone0_r  <= tile0_resetdone0_i   after DLY;
 --           tile0_rx_resetdone0_r2 <= tile0_rx_resetdone0_r   after DLY;
 --       end if;
 --   end process;
	 
    process( tile0_txusrclk0_i,tile0_resetdone0_i)
    begin
        if(tile0_resetdone0_i = '0') then
            tile0_tx_resetdone0_r  <= '0'   after DLY;
            tile0_tx_resetdone0_r2 <= '0'   after DLY;
        elsif(tile0_txusrclk0_i'event and tile0_txusrclk0_i = '1') then
            tile0_tx_resetdone0_r  <= tile0_resetdone0_i   after DLY;
            tile0_tx_resetdone0_r2 <= tile0_tx_resetdone0_r   after DLY;
        end if;
    end process;




    ---------------------------------- Frame Checkers -------------------------
    -- The example design uses Block RAM based frame checkers to verify incoming
    -- data. By default the frame generators are loaded with a data sequence that
    -- matches the outgoing sequence of the frame generators for the TX ports.

    -- You can modify the expected data sequence by changing the INIT values of the frame
    -- checkers in this file. Pay careful attention to bit order and the spacing
    -- of your control and alignment characters.

    -- When the frame checker receives data, it attempts to synchronise to the
    -- incoming pattern by looking for the first sequence in the pattern. Once it
    -- finds the first sequence, it increments through the sequence, and indicates an
    -- error whenever the next value received does not match the expected value.

    --tile0_frame_check0_reset_i              <= reset_on_data_error_i when (EXAMPLE_CONFIG_INDEPENDENT_LANES=0) else tile0_matchn0_i;

    -- tile0_frame_check0 is always connected to the lane with the start of char
    -- and this lane starts off the data checking on all the other lanes. The INC_IN port is tied off
    --tile0_inc_in0_i                         <= '0';


    --tile0_frame_check1_reset_i              <= reset_on_data_error_i when (EXAMPLE_CONFIG_INDEPENDENT_LANES=0) else tile0_matchn1_i;

    -- tile0_frame_check0 is always connected to the lane with the start of char
    -- and this lane starts off the data checking on all the other lanes. The INC_IN port is tied off
    --tile0_inc_in1_i                         <= '0';




 Ist_D16b_O_20b_in:   D16b_OUT_20b_IN_8b10b  PORT MAP(
					RESET => tile0_gtxreset_i,
					RBCLK => tile0_rxusrclk0_i,
					Data_IN => tile0_rxdata0_i, -- Dati 19..0 di RX row
					Data_OUT => GTX_Data_OUT, 
					KCom_OUT => K_Comma_OUT  );


	
ist_Aligner_noRes :  Aligner_noRes       PORT MAP(                               
				clk  => tile0_rxusrclk0_i,
				rst =>  tile0_gtxreset_i ,
				DATAIN => tile0_rxdata0_i,  -- Dati 19..0 di RX row
				Tx_Sync_done  => tile0_tx_sync_done0_i,
				Aligned =>  Wire_RX_ALLINEATO ,
				LockFailed => FAIL,
				RXSLIDE =>  tile0_rxslide0_i    );
	
	
ist_Resettatore : RESETTATORE_ALLINEA  PORT MAP (
     CLK_TX 			=>  tile0_txusrclk0_i,	
     CLK_RX	         =>  tile0_rxusrclk0_i,
     RST 			  	=>  GTXRESET_IN,
     FAIL				=>  FAIL,
	TX_SYNC_DONE_in   =>  tile0_tx_sync_done0_i,
	  Align_OFF 	   =>  open,
     OUT_RES   		=>  Wire_RX_LockFailed      );
		


 LockFailed_OUT      <=  FAIL; -- LOCK FAILED Con Monostabile


 --   TRACK_DATA_OUT      <= track_data_out_i;

  --  track_data_out_i    <=   tile0_track_data0_i and  tile0_track_data1_i ;

    tile0_gtxreset_i    <= GTXRESET_IN  or  Wire_RX_LockFailed;
	 
	 RX_ALLINEATO_OUT    <= Wire_RX_ALLINEATO ;

 -- tile0_tx_system_reset0_c                <= not tile0_tx_sync_done0_i;
 -- tile0_tx_system_reset1_c                <= not tile0_tx_sync_done1_i;

 -- tile0_rx_system_reset0_c                <= not tile0_rx_resetdone0_r2; 
 -- tile0_rx_system_reset1_c                <= not tile0_rx_resetdone1_r2;
 -- 
 
--------------------------------------------------------------------
--                                            ALFO
--   CONNESSIONI con le Uscite  ------------------------------------

RX_REC_CLK_OUT		 	<= 	tile0_rxusrclk0_i;

TILE0_PLLLKDET_OUT  	<=    tile0_plllkdet_i;

tile0_txcharisk0_i   <=    K_Comma_IN   	; -- TX  COMMA 

tile0_txdata0_i      <= GTX_Data_IN ;  -- Dati da Trasmettere 15--0 
 
TX_SYNC_DONE         <=  tile0_tx_sync_done0_i; -- Il trasmettitore è allineato

RESET_DONE_OUT       <=  tile0_tx_resetdone0_r2 ; -- 

Ref_CLK_OUT          <=   tile0_txusrclk0_i ; -- REF CLK dal Quarzo 

--  NOTA !!!!  Manca RX_RESET dal GTX e quindi non si resetta il ricevitore con il segnale di PLLdet
--tile0_rxreset0_i    	<= 	not tile0_plllkdet_i;  -- Hold the RX in reset till the RX user clocks are stable
	 


--------------------------------------------------------------------
end RTL;
