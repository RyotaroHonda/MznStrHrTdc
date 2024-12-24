library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_MISC.ALL;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

Library xpm;
use xpm.vcomponents.all;

library mylib;
use mylib.defCDCM.all;
use mylib.defMikumari.all;
use mylib.defLaccp.all;
use mylib.defMikumariUtil.all;

use mylib.defStrHRTDC.all;
use mylib.defDataBusAbst.all;
use mylib.defDelimiter.all;
use mylib.defTDC.all;

use mylib.defHeartBeatUnit.all;
use mylib.defFreeRunScaler.all;

use mylib.defBCT.all;
use mylib.defBusAddressMap.all;
use mylib.defSiTCP.all;
use mylib.defRBCP.all;
use mylib.defDDRTransmitter.all;
use mylib.defMIF.all;
use mylib.defBctBridge.all;

entity toplevel is
  Port
    (
      -- System --------------------------------------------------------------
      CLKOSC_P     : in std_logic; -- 100 MHz
      CLKOSC_N     : in std_logic; -- 100 MHz
      DIP          : in  std_logic_vector(3 downto 0);
      ENFIN        : out std_logic;
      PROG_B_ON    : out std_logic;
      VP           : in std_logic;
      VN           : in std_logic;

      -- Signal input --------------------------------------------------------
      SIGIN_P      : in std_logic_vector(31 downto 0);
      SIGIN_N      : in std_logic_vector(31 downto 0);

      -- Mezzanine base connector --------------------------------------------
      -- System --
      FRST_P       : in std_logic;
      FRST_N       : in std_logic;
      CLKHUL_P     : in std_logic;
      CLKHUL_N     : in std_logic;
      SLOT_POS_P   : in std_logic;
      SLOT_POS_N   : in std_logic;

      -- Status --
      STATUS_MZN_P  : out std_logic_vector(kWidthStatusMzn-1 downto 0);
      STATUS_MZN_N  : out std_logic_vector(kWidthStatusMzn-1 downto 0);
      STATUS_BASE_P : in std_logic_vector(kWidthStatusBase-1 downto 0);
      STATUS_BASE_N : in std_logic_vector(kWidthStatusBase-1 downto 0);

      -- MIKUMARI --
      CDCM_TXP     : out std_logic;
      CDCM_TXN     : out std_logic;
      CDCM_RXP     : in std_logic;
      CDCM_RXN     : in std_logic;

      -- BCT  bus bridge --
      BBS_PRI_ACTIVE_P  : in std_logic;
      BBS_PRI_ACTIVE_N  : in std_logic;
      BBS_SCN_REQ_P     : out std_logic;
      BBS_SCN_REQ_N     : out std_logic;
      BBS_CLK_P         : in std_logic;
      BBS_CLK_N         : in std_logic;
      BBS_POSI_P        : in std_logic;
      BBS_POSI_N        : in std_logic;
      BBS_PISO_P        : out std_logic;
      BBS_PISO_N        : out std_logic;


      -- DDR data transmitter --
      CLKDDR_P     : out std_logic;
      CLKDDR_N     : out std_logic;
      DDRD_P       : out std_logic_vector(kNumDDR-1 downto 0);
      DDRD_N       : out std_logic_vector(kNumDDR-1 downto 0)

    );
end toplevel;

architecture Behavioral of toplevel is
  attribute mark_debug  : string;
  attribute keep        : string;
  constant kEnDebugTop  : string:= "false";

  -- System ------------------------------------------------------------------
  -- Mezzanine specification
  constant kNumBitDIP   : integer:= 4;

  signal system_reset : std_logic;
  signal pwr_on_reset : std_logic;
  signal user_reset   : std_logic;
  signal rst_from_bus : std_logic;
  signal force_reset  : std_logic;
  signal hbu_reset    : std_logic;
  signal slot_pos     : std_logic;

  signal status_mzn   : std_logic_vector(kWidthStatusMzn-1 downto 0);
  signal status_base  : std_logic_vector(kWidthStatusBase-1 downto 0);

  signal prog_full_bmgr, sync_prog_full_bmgr    : std_logic;
  signal hbfnum_mismatch, sync_lhbfnum_mismatch  : std_logic;
  signal tcp_is_active      : std_logic;
  signal output_throttling_on : std_logic;

  signal frame_flag_out   : std_logic_vector(kWidthFrameFlag-1 downto 0);

  -- Hit Input definition --
  constant kNumInput    : integer:= 32;

  -- DIP ---------------------------------------------------------------------
  signal dip_sw       : std_logic_vector(DIP'range);
  subtype DipID is integer range 0 to 3;
  type regLeaf is record
    Index : DipID;
  end record;
  constant kNC1     : regLeaf := (Index => 0);
  constant kNC2     : regLeaf := (Index => 1);
  constant kNC3     : regLeaf := (Index => 2);
  constant kNC4     : regLeaf := (Index => 3);

  -- MIKUMARI -----------------------------------------------------------------------------
  constant kNumMikumari       : integer:= 1;
  constant kIdMikuSec         : integer:= 0;

  subtype MikuScalarPort is std_logic_vector(kNumMikumari-1 downto 0);

  -- CDCM --
  signal power_on_init        : std_logic;

  signal cbt_lane_up          : MikuScalarPort;
  signal pattern_error        : MikuScalarPort;
  signal watchdog_error       : MikuScalarPort;

  signal mod_clk, gmod_clk    : std_logic;

  --type TapValueArray  is array(kNumMikumari-1 downto 0) of std_logic_vector(kWidthTap-1 downto 0);
  --type SerdesOffsetArray is array(kNumMikumari-1 downto 0) of signed(kWidthSerdesOffset-1 downto 0);
  signal tap_value_out        : TapArrayType(kNumMikumari-1 downto 0);
  signal bitslip_num_out      : BitslipArrayType(kNumMikumari-1 downto 0);
  signal serdes_offset        : SerdesOfsArrayType(kNumMikumari-1 downto 0);

  attribute mark_debug of pattern_error : signal is kEnDebugTop;


  -- Mikumari --
  type MikuDataArray is array(kNumMikumari-1 downto 0) of std_logic_vector(7 downto 0);
  type MikuPulseTypeArray is array(kNumMikumari-1 downto 0) of MikumariPulseType;

  signal miku_tx_ack        : MikuScalarPort;
  signal miku_data_tx       : MikuDataArray;
  signal miku_valid_tx      : MikuScalarPort;
  signal miku_last_tx       : MikuScalarPort;
  signal busy_pulse_tx      : MikuScalarPort;

  signal mikumari_link_up   : MikuScalarPort;
  signal miku_data_rx       : MikuDataArray;
  signal miku_valid_rx      : MikuScalarPort;
  signal miku_last_rx       : MikuScalarPort;
  signal checksum_err       : MikuScalarPort;
  signal frame_broken       : MikuScalarPort;
  signal recv_terminated    : MikuScalarPort;

  signal pulse_tx, pulse_rx : MikuScalarPort;
  signal pulse_type_tx, pulse_type_rx  : MikuPulseTypeArray;

  attribute mark_debug of checksum_err    : signal is kEnDebugTop;
  attribute mark_debug of frame_broken    : signal is kEnDebugTop;
  attribute mark_debug of recv_terminated : signal is kEnDebugTop;

 -- LACCP --
  signal laccp_reset        : MikuScalarPort;
  signal laccp_pulse_out    : std_logic_vector(kNumLaccpPulse-1 downto 0);

  signal is_ready_for_daq   : MikuScalarPort;
  signal sync_pulse_out     : std_logic;

  signal is_ready_laccp_intra   : std_logic_vector(kNumExtIntraPort-1 downto 0);
  signal valid_laccp_intra_in   : std_logic_vector(kNumExtIntraPort-1 downto 0);
  signal valid_laccp_intra_out  : std_logic_vector(kNumExtIntraPort-1 downto 0);
  signal data_laccp_intra_in    : ExtIntraType;
  signal data_laccp_intra_out   : ExtIntraType;

  -- RLIGP --
  --type LinkAddrArray is array(kNumMikumari-1 downto 0) of std_logic_vector(kPosRegister'range);
  signal link_addr_partter  : IpAddrArrayType(kNumMikumari-1 downto 0);
  signal valid_link_addr    : MikuScalarPort;

  -- RCAP --
--  signal idelay_tap_in      : unsigned(tap_value_out'range);

  signal valid_hbc_offset   : std_logic;
  signal hbc_offset         : std_logic_vector(kWidthHbCount-1 downto 0);
  signal laccp_fine_offset  : signed(kWidthLaccpFineOffset-1 downto 0);
  signal local_fine_offset  : signed(kWidthLaccpFineOffset-1 downto 0);

  -- Heartbeat --
  signal hbu_is_synchronized  : std_logic;
  signal heartbeat_signal   : std_logic;
  signal heartbeat_count    : std_logic_vector(kWidthHbCount-1 downto 0);
  signal hbf_number         : std_logic_vector(kWidthHbfNum-1 downto 0);
  signal hbf_state          : HbfStateType;
  signal frame_ctrl_gate    : std_logic;
  signal hbf_num_mismatch   : std_logic;

  attribute mark_debug of valid_hbc_offset   : signal is kEnDebugTop;
  attribute mark_debug of is_ready_for_daq   : signal is kEnDebugTop;
  attribute mark_debug of hbu_is_synchronized : signal is kEnDebugTop;
  attribute mark_debug of sync_pulse_out     : signal is kEnDebugTop;
  attribute mark_debug of laccp_fine_offset  : signal is kEnDebugTop;
  attribute mark_debug of local_fine_offset  : signal is kEnDebugTop;

  -- Mikumari Util ------------------------------------------------------------
  signal cbt_init_from_mutil   : MikuScalarPort;

  -- Scaler -------------------------------------------------------------------
  constant kMsbScr      : integer:= kNumSysInput+kNumInput-1;
  signal scr_en_in      : std_logic_vector(kMsbScr downto 0):= (others => '0');
  signal scr_gate       : std_logic_vector(kNumScrGate-1 downto 0);

  -- MZN connector -----------------------------------------------------------
  -- DDR transmitter --

  -- BBS --
  signal addr_bct               : BctBridgeAddrType;
  signal rxd_bct                : LocalBusInType;
  signal txd_bct                : LocalBusOutType;
  signal re_bct, we_bct         : std_logic;
  signal ack_bct                : std_logic;

  signal bbs_prim_active        : std_logic;
  signal bbs_scnd_req           : std_logic;
  signal bbs_clk                : std_logic;
  signal bbs_posi, bbs_piso     : std_logic;

  -- DCT ---------------------------------------------------------------------
  signal ddr_test_mode_lbus     : std_logic;
  signal ddr_test_mode          : std_logic;
  signal test_mode              : std_logic;
  signal extra_path             : std_logic;

  -- StrTDC ------------------------------------------------------------------
  -- Scaler --
  constant kNumScrThr   : integer:= 5;
  signal hit_out        : std_logic_vector(kNumInput-1 downto 0):= (others => '0');
  signal scr_thr_on     : std_logic_vector(kNumScrThr-1 downto 0);
  signal daq_is_runnig  : std_logic;

  signal strtdc_trigger_in  : std_logic;

  signal sig_in                 : std_logic_vector(kNumInput-1 downto 0);
  signal detector_in            : std_logic_vector(kNumInput-1 downto 0);
  signal strtdc_dout            : std_logic_vector(kWidthData-1 downto 0);
  signal strtdc_rden            : std_logic;
  signal strtdc_empty           : std_logic;
  signal strtdc_rdvalid         : std_logic;

  signal input_throttling_t2_on         : std_logic;
  signal global_hbf_num_mismatch : std_logic;
  signal daq_run_state          : std_logic;

  attribute mark_debug of strtdc_rden           : signal is kEnDebugTop;
  attribute mark_debug of strtdc_rdvalid        : signal is kEnDebugTop;
  attribute mark_debug of strtdc_dout           : signal is kEnDebugTop;
  attribute mark_debug of sync_prog_full_bmgr   : signal is kEnDebugTop;

  -- VitalBlock output --
  signal vital_rden         : std_logic;
  signal vital_dout         : std_logic_vector(kWidthData-1 downto 0);
  signal vital_valid        : std_logic;

  -- Link buffer --
  signal pfull_link_buf     : std_logic;
  signal empty_link_buf     : std_logic;

  component mergerBackFifo is
    PORT(
      clk         : in  STD_LOGIC;
      srst        : in  STD_LOGIC;

      wr_en       : in  STD_LOGIC;
      din         : in  STD_LOGIC_VECTOR (kWidthData-1 DOWNTO 0);
      full        : out STD_LOGIC;
      almost_full : out STD_LOGIC;

      rd_en       : in  STD_LOGIC;
      dout        : out STD_LOGIC_VECTOR (kWidthData-1 DOWNTO 0);
      empty       : out STD_LOGIC;
      almost_empty: out STD_LOGIC;
      valid       : out STD_LOGIC;

      prog_full   : out STD_LOGIC
    );
    end component;


  -- SDS --------------------------------------------------------------------
  signal uncorrectable_flag     : std_logic;

  -- BCT --------------------------------------------------------------------
  signal addr_ext_bus : std_logic_vector(kWidthAddrRBCP-1 downto 0);
  signal wd_ext_bus   : std_logic_vector(kWidthDataRBCP-1 downto 0);
  signal rd_ext_bus   : std_logic_vector(kWidthDataRBCP-1 downto 0);
  signal re_ext_bus   : std_logic;
  signal we_ext_bus   : std_logic;
  signal ack_ext_bus  : std_logic;

  signal addr_LocalBus          : LocalAddressType;
  signal data_LocalBusIn        : LocalBusInType;
  signal data_LocalBusOut       : DataArray;
  signal re_LocalBus            : ControlRegArray;
  signal we_LocalBus            : ControlRegArray;
  signal ready_LocalBus         : ControlRegArray;

  -- Clock -----------------------------------------------------------------
--  attribute IODELAY_GROUP : string;
--  attribute IODELAY_GROUP of u_FastDelay       : label is "idelay_clk";
--  attribute IODELAY_GROUP of u_IDELAYCTRL_inst : label is "idelay_clk";

  signal idelay_reset           : std_logic;
  signal idelayctrl_ready       : std_logic;

  signal clk_hul, clk_input    : std_logic;
--  signal clk_ser                        : std_logic;
  signal clk_sys                        : std_logic;
  signal clk_tdc                        : std_logic;
  signal clk_icap, clk_icap_ce          : std_logic;
  signal clk_idelayref                  : std_logic;

  signal clk_512, clk_26214             : std_logic;
  signal clk_calib                      : std_logic;

  signal clk_miku_locked                : std_logic_vector(2 downto 0);
  signal clk_sys_locked                 : std_logic;
  signal ready_clk                      : std_logic;

  component clk_wiz_tdc
    port
      (-- Clock out ports
        clk_sys           : out std_logic;
        clk_tdc           : out std_logic;
        clk_icap          : out std_logic;
        -- Status and control signals
        reset             : in  std_logic;
        locked            : out std_logic;
--        clk_in1           : in  std_logic
        clk_in1_p         : in  std_logic;
        clk_in1_n         : in  std_logic
        );
  end component;

  component clk_wiz_sys
    port
     (-- Clock in ports
      -- Clock out ports
      clk_idelayref          : out    std_logic;
      -- Status and control signals
      reset             : in     std_logic;
      locked            : out    std_logic;
      clk_in1_p         : in     std_logic;
      clk_in1_n         : in     std_logic
     );
    end component;


  component clk_wiz_calib1
    port
      (-- Clock out ports
        clk_calib1        : out std_logic;
        -- Status and control signals
        reset             : in  std_logic;
        locked            : out std_logic;
        clk_in1           : in  std_logic
        );
  end component;


  component clk_wiz_calib2
    port
      (-- Clock out ports
        clk_calib2        : out std_logic;
        -- Status and control signals
        reset             : in  std_logic;
        locked            : out std_logic;
        clk_in1           : in  std_logic
        );
  end component;

-- debug --

begin
  -- =========================================================================
  -- body
  -- =========================================================================

  -- Connection --------------------------------------------------------------



  dip_sw(0)   <= NOT DIP(0);
  dip_sw(1)   <= NOT DIP(1);
  dip_sw(2)   <= NOT DIP(2);
  dip_sw(3)   <= NOT DIP(3);

  ENFIN       <= '1';

  -- System ------------------------------------------------------------------
  --ready_clk     <= and_reduce(clk_miku_locked);
  ready_clk     <= clk_miku_locked(0);
  system_reset  <= (NOT ready_clk) or force_reset;
  pwr_on_reset  <= (NOT clk_sys_locked) or force_reset;
  user_reset    <= system_reset OR rst_from_bus;

  status_mzn(kIdMznInThrottlingT2)    <= '0';
  prog_full_bmgr                      <= status_base(kIdBaseProgFullBMgr);
  hbfnum_mismatch                     <= status_base(kIdBaseHbfNumMismatch);
  tcp_is_active                       <= status_base(kIdBaseTcpActive);
  --empty_link_buf                      <= status_base(kIdBaseEmptyLinkBuf);
  --output_throttling_on                <= status_base(kIdBaseOutThrottling);

  -- MIKUMARI ----------------------------------------------------------------
  u_KeepInit : process(system_reset, clk_sys)
    variable counter   : integer:= 0;
  begin
    if(system_reset = '1') then
      power_on_init   <= '1';
      counter         := 16#0FFFFFFF#;
    elsif(clk_sys'event and clk_sys = '1') then
      if(counter = 0) then
        power_on_init   <= '0';
      else
        counter   := counter -1;
      end if;
    end if;
  end process;

  gen_mikumari : for i in 0 to kNumMikumari-1 generate
    laccp_reset(i) <= system_reset or (not mikumari_link_up(i));

    u_Miku_Inst : entity mylib.MikumariBlock
      generic map(
        -- CBT generic -------------------------------------------------------------
        -- CDCM-Mod-Pattern --
        kCdcmModWidth    => 8,
        -- CDCM-TX --
        kIoStandardTx    => "LVDS",
        kTxPolarity      => FALSE,
        -- CDCM-RX --
        genIDELAYCTRL    => TRUE,
        kDiffTerm        => TRUE,
        kIoStandardRx    => "LVDS",
        kRxPolarity      => FALSE,
        kIoDelayGroup    => "idelay_1",
        kFixIdelayTap    => FALSE,
        kFreqFastClk     => 500.0,
        kFreqRefClk      => 200.0,
        -- Encoder/Decoder
        kNumEncodeBits   => 1,
        -- Master/Slave
        kCbtMode         => "Slave",
        -- DEBUG --
        enDebugCBT       => FALSE,

        -- MIKUMARI generic --------------------------------------------------------
        enScrambler      => TRUE,
        kHighPrecision   => FALSE,
        -- DEBUG --
        enDebugMikumari  => FALSE
      )
      port map(
        -- System ports -----------------------------------------------------------
        rst           => system_reset,
        pwrOnRst      => pwr_on_reset,
        clkSer        => clk_tdc,
        clkPar        => clk_sys,
        clkIndep      => clk_idelayref,
        clkIdctrl     => clk_idelayref,
        initIn        => power_on_init or cbt_init_from_mutil(kIdMikuSec),

        TXP           => CDCM_TXP,
        TXN           => CDCM_TXN,
        RXP           => CDCM_RXP,
        RXN           => CDCM_RXN,
        modClk        => mod_clk,
        tapValueIn    => (others => '0'),
        txBeat        => open,

        -- CBT ports ------------------------------------------------------------
        laneUp        => cbt_lane_up(i),
        idelayErr     => open,
        bitslipErr    => open,
        pattErr       => pattern_error(i),
        watchDogErr   => watchdog_error(i),

        tapValueOut   => tap_value_out(i),
        bitslipNum    => bitslip_num_out(i),
        serdesOffset  => serdes_offset(i),
        firstBitPatt  => open,

        -- Mikumari ports -------------------------------------------------------
        linkUp        => mikumari_link_up(i),

        -- TX port --
        -- Data I/F --
        dataInTx      => miku_data_tx(i),
        validInTx     => miku_valid_tx(i),
        frameLastInTx => miku_last_tx(i),
        txAck         => miku_tx_ack(i),

        pulseIn       => pulse_tx(i),
        pulseTypeTx   => pulse_type_tx(i),
        pulseRegTx    => "0000",
        busyPulseTx   => busy_pulse_tx(i),

        -- RX port --
        -- Data I/F --
        dataOutRx   => miku_data_rx(i),
        validOutRx  => miku_valid_rx(i),
        frameLastRx => miku_last_rx(i),
        checksumErr => checksum_err(i),
        frameBroken => frame_broken(i),
        recvTermnd  => recv_terminated(i),

        pulseOut    => pulse_rx(i),
        pulseTypeRx => pulse_type_rx(i),
        pulseRegRx  => open

      );

    --
    --idelay_tap_in   <= unsigned(tap_value_out);

    u_LACCP : entity mylib.LaccpMainBlock
      generic map
        (
          kPrimaryMode      => false,
          kNumInterconnect  => 1,
          enDebug           => false
        )
      port map
        (
          -- System --------------------------------------------------------
          rst               => laccp_reset(i),
          clk               => clk_sys,

          -- User Interface ------------------------------------------------
          isReadyForDaq     => is_ready_for_daq(i),
          laccpPulsesIn     => (others => '0'),
          laccpPulsesOut    => laccp_pulse_out,
          pulseInRejected   => open,

          -- RLIGP --
          addrMyLink        => X"01020304",
          validMyLink       => '1',
          addrPartnerLink   => link_addr_partter(i),
          validPartnerLink  => valid_link_addr(i),

          -- RCAP --
          idelayTapIn       => unsigned(tap_value_out(i)),
          serdesLantencyIn  => serdes_offset(i),
          idelayTapOut      => open,
          serdesLantencyOut => open,

          hbuIsSyncedIn     => hbu_is_synchronized,
          syncPulseIn       => '0',
          syncPulseOut      => sync_pulse_out,

          upstreamOffset    => (others => '0'),
          validOffset       => valid_hbc_offset,
          hbcOffset         => hbc_offset,
          fineOffset        => laccp_fine_offset,
          fineOffsetLocal   => local_fine_offset,

          -- LACCP Bus Port ------------------------------------------------
          -- Intra-port--
          isReadyIntraIn    => is_ready_laccp_intra,
          dataIntraIn       => data_laccp_intra_in,
          validIntraIn      => valid_laccp_intra_in,
          dataIntraOut      => data_laccp_intra_out,
          validIntraOut     => valid_laccp_intra_out,

          -- Interconnect --
          isReadyInterIn    => (others => '0'),
          existInterOut     => open,
          dataInterIn       => (others => (others => '0')),
          validInterIn      => (others => '0'),
          dataInterOut      => open,
          validInterOut     => open,

          -- MIKUMARI-Link -------------------------------------------------
          mikuLinkUpIn      => mikumari_link_up(i),

          -- TX port --
          dataTx            => miku_data_tx(i),
          validTx           => miku_valid_tx(i),
          frameLastTx       => miku_last_tx(i),
          txAck             => miku_tx_ack(i),

          pulseTx           => pulse_tx(i),
          pulseTypeTx       => pulse_type_tx(i),
          busyPulseTx       => busy_pulse_tx(i),

          -- RX port --
          dataRx            => miku_data_rx(i),
          validRx           => miku_valid_rx(i),
          frameLastRx       => miku_last_rx(i),
          checkSumErrRx     => checksum_err(i),
          frameBrokenRx     => frame_broken(i),
          recvTermndRx      => recv_terminated(i),

          pulseRx           => pulse_rx(i),
          pulseTypeRx       => pulse_type_rx(i)

        );
  end generate;

  --
  frame_ctrl_gate <= '0';
  hbu_reset       <= laccp_reset(0);

  u_HBU : entity mylib.HeartBeatUnit
    generic map
      (
        enDebug           => false
      )
    port map
      (
        -- System --
        rst               => hbu_reset,
        clk               => clk_sys,
        enStandAlone      => '0',
        keepLocalHbfNum   => '1',

        -- Sync I/F --
        syncPulseIn       => sync_pulse_out,
        hbcOffsetIn       => hbc_offset,
        validOffsetIn     => valid_hbc_offset,
        isSynchronized    => hbu_is_synchronized,

        -- HeartBeat I/F --
        heartbeatOut      => heartbeat_signal,
        heartbeatCount    => heartbeat_count,
        hbfNumber         => hbf_number,
        hbfNumMismatch    => hbf_num_mismatch,

        -- DAQ I/F --
        hbfCtrlGateIn     => frame_ctrl_gate,
        forceOn           => '1',
        frameState        => hbf_state,

        hbfFlagsIn        => (others => '0'),
        frameFlags        => frame_flag_out,

        -- LACCP Bus --
        dataBusIn         => data_laccp_intra_out(GetExtIntraIndex(kPortHBU)),
        validBusIn        => valid_laccp_intra_out(GetExtIntraIndex(kPortHBU)),
        dataBusOut        => data_laccp_intra_in(GetExtIntraIndex(kPortHBU)),
        validBusOut       => valid_laccp_intra_in(GetExtIntraIndex(kPortHBU)),
        isReadyOut        => is_ready_laccp_intra(GetExtIntraIndex(kPortHBU))

      );

  -- MIKUMARI utility ---------------------------------------------------------------------
  u_MUTIL : entity mylib.MikumariUtil
    generic map(
      kNumMikumari => kNumMikumari,
      kSecondaryId => kIdMikuSec
    )
    port map(
      -- System ----------------------------------------------------
      rst               => user_reset,
      clk               => clk_sys,

      clockRootMode     => '0',

      -- CBT status ports --
      cbtLaneUp           => cbt_lane_up,
      tapValueIn          => tap_value_out,
      bitslipNumIn        => bitslip_num_out,
      cbtInitOut          => cbt_init_from_mutil,
      tapValueOut         => open,
      rstOverMikuOut      => open,

      -- MIKUMARI Link ports --
      mikuLinkUp          => mikumari_link_up,

      -- LACCP ports --
      laccpUp             => is_ready_for_daq,
      partnerIpAddr       => link_addr_partter,
      hbcOffset           => hbc_offset,
      localFineOffset     => std_logic_vector(local_fine_offset),
      laccpFineOffset     => std_logic_vector(laccp_fine_offset),
      hbfState            => open,

      -- Local bus --
      addrLocalBus        => addr_LocalBus,
      dataLocalBusIn      => data_LocalBusIn,
      dataLocalBusOut     => data_LocalBusOut(kMUTIL.ID),
      reLocalBus          => re_LocalBus(kMUTIL.ID),
      weLocalBus          => we_LocalBus(kMUTIL.ID),
      readyLocalBus       => ready_LocalBus(kMUTIL.ID)
    );

  -- Scaler -------------------------------------------------------------------------------
  scr_en_in(kMsbScr - kIndexRealTime)       <= heartbeat_signal;
  scr_en_in(kMsbScr - kIndexDaqRunTime)     <= heartbeat_signal when(daq_is_runnig = '1') else '0';
  scr_en_in(kMsbScr - kIndexTotalThrotTime) <= scr_thr_on(0);
  scr_en_in(kMsbScr - kIndexInThrot1Time)   <= scr_thr_on(1);
  scr_en_in(kMsbScr - kIndexInThrot2Time)   <= scr_thr_on(2);
  scr_en_in(kMsbScr - kIndexOutThrotTime)   <= scr_thr_on(3);
  scr_en_in(kMsbScr - kIndexHbfThrotTime)   <= scr_thr_on(4);
  scr_en_in(kMsbScr - kIndexMikuError)      <= (pattern_error(kIdMikuSec) or checksum_err(kIdMikuSec) or frame_broken(kIdMikuSec) or recv_terminated(kIdMikuSec)) and is_ready_for_daq(kIdMikuSec);

  scr_en_in(kMsbScr - kIndexTrgReq)         <= '0';
  scr_en_in(kMsbScr - kIndexTrgRejected)    <= '0';

  scr_en_in(kMsbScr - kIndexGate1Time)      <= heartbeat_signal and scr_gate(1);
  scr_en_in(kMsbScr - kIndexGate2Time)      <= heartbeat_signal and scr_gate(2);

  scr_en_in(kNumInput-1 downto 0)           <= swap_vect(hit_out);

  scr_gate(0)   <= '1';
  process(clk_sys)
  begin
    if(clk_sys'event and clk_sys = '1') then
      if(user_reset = '1') then
        scr_gate(kNumScrGate-1 downto 1)  <= (others => '0');
      elsif(heartbeat_signal = '1') then
        scr_gate(1)   <= frame_flag_out(0);
        scr_gate(2)   <= frame_flag_out(1);
      end if;
    end if;
  end process;


  u_SCR: entity mylib.FreeRunScaler
    generic map(
      kNumHitInput        => kNumInput
    )
    port map(
      rst	                => system_reset,
      cntRst              => laccp_pulse_out(kDownPulseCntRst),
      clk	                => clk_sys,
      scrRstOut           => open,

      -- Module Input --
      hbCount             => (heartbeat_count'range => heartbeat_count, others => '0'),
      hbfNum              => (hbf_number'range => hbf_number, others => '0'),
      scrEnIn             => scr_en_in,

      scrGates            => scr_gate,

      -- Local bus --
      addrLocalBus        => addr_LocalBus,
      dataLocalBusIn      => data_LocalBusIn,
      dataLocalBusOut     => data_LocalBusOut(kSCR.ID),
      reLocalBus          => re_LocalBus(kSCR.ID),
      weLocalBus          => we_LocalBus(kSCR.ID),
      readyLocalBus       => ready_LocalBus(kSCR.ID)
      );


  -- Streaming TDC -----------------------------------------------------------
  gen_sigin : for i in 0 to kNumInput-1 generate
    u_IDS_inst : IBUFDS
      generic map (
        DIFF_TERM   => TRUE, IBUF_LOW_PWR => FALSE, IOSTANDARD => "LVDS")
      port map (
        O => detector_in(i),
        I => SIGIN_P(i), IB => SIGIN_N(i)
      );
  end generate;

  sig_in  <= detector_in;

  u_SyncHbfMismatch : entity mylib.synchronizer
    port map(clk_sys, hbfnum_mismatch, sync_lhbfnum_mismatch );

  strtdc_trigger_in <= laccp_pulse_out(kDownPulseTrigger);

  u_StrHrTdc : entity mylib.StrHrTdc
    generic map(
      kNumInput         => kNumInput,
      kDivisionRatio    => 4,
      enDEBUG           => false
    )
    port map(
      -- System ----------------------------------------------------
      genChOffset       => slot_pos,

      rst               => system_reset,
      rstUser           => user_reset,
      clk               => clk_sys,
      tdcClk            => clk_tdc,

      radiationURE      => uncorrectable_flag,
      daqOn             => daq_is_runnig,
      scrThrEn          => scr_thr_on,

      testModeIn        => extra_path,

      -- Data Link --------------------------------------------------
      linkActive        => tcp_is_active,

      -- DAQ status ------------------------------------------------
      lHbfNumMismatch   => sync_lhbfnum_mismatch,

      -- LACCP ------------------------------------------------------
      heartbeatIn       => heartbeat_signal,
      hbCount           => heartbeat_count,
      hbfNumber         => hbf_number,
      ghbfNumMismatchIn => hbf_num_mismatch,
      hbfState          => hbf_state,

      LaccpFineOffset   => laccp_fine_offset,

      frameFlagsIn      => frame_flag_out,

      -- Streaming TDC interface ------------------------------------
      sigIn             => sig_in,
      calibIn           => clk_calib,
      triggerIn         => strtdc_trigger_in,
      hitOut            => hit_out,

      dataRdEn          => vital_rden,
      dataOut           => vital_dout,
--      dataEmpty         => strtdc_empty,
      dataRdValid       => vital_valid,

      -- LinkBuffer interface ---------------------------------------
      pfullLinkBufIn    => pfull_link_buf,
      emptyLinkInBufIn  => empty_link_buf,

      -- Local bus --
      addrLocalBus      => addr_LocalBus,
      dataLocalBusIn    => data_LocalBusIn,
      dataLocalBusOut   => data_LocalBusOut(kTDC.ID),
      reLocalBus        => re_LocalBus(kTDC.ID),
      weLocalBus        => we_LocalBus(kTDC.ID),
      readyLocalBus     => ready_LocalBus(kTDC.ID)
    );

  vital_rden  <= not pfull_link_buf;

  u_SyncPFull : entity mylib.synchronizer
    port map(clk_sys, prog_full_bmgr, sync_prog_full_bmgr );
  strtdc_rden   <= not (sync_prog_full_bmgr) ;

  u_link_buf : mergerBackFifo
    port map(
    clk         => clk_sys,
    srst        => user_reset or (not tcp_is_active),

    wr_en       => vital_valid,
    din         => vital_dout,
    full        => open,
    almost_full => open,

    rd_en       => strtdc_rden,
    dout        => strtdc_dout,
    empty       => empty_link_buf,
    almost_empty=> open,
    valid       => strtdc_rdvalid,

    prog_full   => pfull_link_buf
  );


  -- MZN connector -----------------------------------------------------------
  u_MIF : entity mylib.MznInterfaceS
    port map
      (
        -- toplevel ports -----------------------------------------------
        -- System ports --
        FRST_P            => FRST_P,
        FRST_N            => FRST_N,
        --CLKHUL_P          => CLKHUL_P,
        --CLKHUL_N          => CLKHUL_N,
        SLOT_POS_P        => SLOT_POS_P,
        SLOT_POS_N        => SLOT_POS_N,

        -- Bct Bus Bridge --
        BBS_PRI_ACTIVE_P  => BBS_PRI_ACTIVE_P,
        BBS_PRI_ACTIVE_N  => BBS_PRI_ACTIVE_N,
        BBS_SCN_REQ_P     => BBS_SCN_REQ_P,
        BBS_SCN_REQ_N     => BBS_SCN_REQ_N,
        BBS_CLK_P         => BBS_CLK_P,
        BBS_CLK_N         => BBS_CLK_N,
        BBS_POSI_P        => BBS_POSI_P,
        BBS_POSI_N        => BBS_POSI_N,
        BBS_PISO_P        => BBS_PISO_P,
        BBS_PISO_N        => BBS_PISO_N,

        -- status --
        STATUS_MZN_P          => STATUS_MZN_P,
        STATUS_MZN_N          => STATUS_MZN_N,
        STATUS_BASE_P         => STATUS_BASE_P,
        STATUS_BASE_N         => STATUS_BASE_N,

        -- Internal signals ---------------------------------------------
        -- System ports --
        forceReset        => force_reset,
        --clkHul            => clk_hul,
        slotPosition      => slot_pos,

        -- Bct Bus Bridge --
        bbsPrimActive     => bbs_prim_active,
        bbsScndReq        => bbs_scnd_req,
        bbsClk            => bbs_clk,
        bbsPosi           => bbs_posi,
        bbsPiSo           => bbs_piso,

        -- Status ports --
        statusMzn         => status_mzn,
        statusBase        => status_base

  );


  -- Data transmitter --
  u_DDRTrans_Inst : entity mylib.DataTransmitter
    port map
    (
      -- clk_reset
      rstClk    => system_reset,
      testMode  => ddr_test_mode,

      -- Data In --
      clkSer    => clk_tdc,
      clkPar    => clk_sys,
      dIn       => strtdc_dout,
      weIn      => strtdc_rdvalid,

      -- DDR Out --
      clkDDRp   => CLKDDR_P,
      clkDDRn   => CLKDDR_N,

      dOutDDRDp => DDRD_P,
      dOutDDRDn => DDRD_N
      );

  -- Bct Bus Bridge --
  addr_ext_bus  <= addr_bct & X"0000";
  wd_ext_bus    <= rxd_bct;
  rd_ext_bus    <= txd_bct;
  re_ext_bus    <= re_bct;
  we_ext_bus    <= we_bct;
  ack_ext_bus   <= ack_bct;

  u_BBS_Inst : entity mylib.BctBridgeSecondary
    generic map(
      enDebug             => false
    )
    port map(
      rst	                => system_reset,
      clk	                => clk_sys,

      -- BCT I/F --
      addrBct     	      => addr_bct,
      rxdOut         	    => rxd_bct,
      txdIn         	    => txd_bct,
      reBct	     	        => re_bct,
      weBct     		      => we_bct,
      ackBct      	      => ack_bct,

      -- Bus Bridge I/F --
      primIsActive        => bbs_prim_active,
      scndReq             => bbs_scnd_req,
      clkBridge           => bbs_clk,
      posi                => bbs_posi,
      piso                => bbs_piso
    );


  -- DCT ---------------------------------------------------------------------
  u_DCT_Inst : entity mylib.DAQController
    port map(
      RST               => user_reset,
      CLK               => clk_sys,

      -- Module Output --
      regTestMode       => ddr_test_mode,
      regExtraPath      => test_mode,

      -- Local bus --
      addrLocalBus      => addr_LocalBus,
      dataLocalBusIn    => data_LocalBusIn,
      dataLocalBusOut   => data_LocalBusOut(kDCT.ID),
      reLocalBus        => re_LocalBus(kDCT.ID),
      weLocalBus        => we_LocalBus(kDCT.ID),
      readyLocalBus     => ready_LocalBus(kDCT.ID)
      );

  -- SDS --------------------------------------------------------------------
  u_SDS_Inst : entity mylib.SelfDiagnosisSystem
    port map(
      rst               => user_reset,
      clk               => clk_sys,
      clkIcap           => clk_icap,

      -- Module input  --
      VP                => VP,
      VN                => VN,

      -- Module output --
      shutdownOverTemp    => open,
      uncorrectableAlarm  => uncorrectable_flag,

      -- Local bus --
      addrLocalBus      => addr_LocalBus,
      dataLocalBusIn    => data_LocalBusIn,
      dataLocalBusOut   => data_LocalBusOut(kSDS.ID),
      reLocalBus        => re_LocalBus(kSDS.ID),
      weLocalBus        => we_LocalBus(kSDS.ID),
      readyLocalBus     => ready_LocalBus(kSDS.ID)
      );

  -- BCT --------------------------------------------------------------------
  u_BCT : entity mylib.BusController
    port map(
      rstSys              => system_reset,
      rstFromBus          => rst_from_bus,
      reConfig            => PROG_B_ON,
      clk                 => clk_sys,
      -- Local Bus --
      addrLocalBus        => addr_LocalBus,
      dataFromUserModules => data_LocalBusOut,
      dataToUserModules   => data_LocalBusIn,
      reLocalBus          => re_LocalBus,
      weLocalBus          => we_LocalBus,
      readyLocalBus       => ready_LocalBus,
      -- RBCP Bus --
      addrRBCP            => addr_ext_bus,
      wdRBCP              => wd_ext_bus,
      weRBCP              => we_ext_bus,
      reRBCP              => re_ext_bus,
      ackRBCP	            => ack_ext_bus,
      rdRBCP              => rd_ext_bus

      );

  -- Clocking ---------------------------------------------------------------
--  u_BUFGHUL : BUFG
--    port map( O => clk_input, I => clk_hul);
--  u_BUFGHUL : BUFG
--    port map( O => gmod_clk, I => mod_clk);

  u_clk_tdc : clk_wiz_tdc
    port map(
      clk_sys         => clk_sys,
      clk_tdc         => clk_tdc,
      clk_icap        => clk_icap,
      reset           => '0',
      locked          => clk_miku_locked(0),
      clk_in1_p       => CLKHUL_P,
      clk_in1_n       => CLKHUL_N
      );

  u_clk_sys : clk_wiz_sys
    port map(
      clk_idelayref   => clk_idelayref,
      reset           => '0',
      locked          => clk_sys_locked,
      clk_in1_p       => CLKOSC_P,
      clk_in1_n       => CLKOSC_N
      );


  u_clk_calib1 : clk_wiz_calib1
    port map(
      clk_calib1      => clk_512,
      reset           => (not test_mode),
      locked          => clk_miku_locked(1),
      clk_in1         => clk_idelayref
      );

  u_clk_calib2 : clk_wiz_calib2
    port map(
      clk_calib2      => clk_26214,
--      clk_calib2      => clk_calib,
      reset           => (not test_mode),
      locked          => clk_miku_locked(2),
      clk_in1         => clk_512
      );

--    clk_calib   <= clk_26214;
   extra_path <= clk_miku_locked(1) and clk_miku_locked(2);

   u_div3_1 : entity mylib.ClkDivision3
--   u_div3_1 : entity mylib.Division10
     port map(
       RST       => (not extra_path),
       CLK       => clk_26214,
       Q         => clk_calib
       );

end Behavioral;
