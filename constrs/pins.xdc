# =============================================================================
# Pin assignments
# =============================================================================
# System -----------------------------------------------------------
set_property PACKAGE_PIN Y23 [get_ports CLKOSC_P]
set_property PACKAGE_PIN AA24 [get_ports CLKOSC_N]

set_property PACKAGE_PIN AF25 [get_ports {DIP[0]}]
set_property PACKAGE_PIN AF24 [get_ports {DIP[1]}]
set_property PACKAGE_PIN AF23 [get_ports {DIP[2]}]
set_property PACKAGE_PIN AF22 [get_ports {DIP[3]}]

set_property PACKAGE_PIN AD24 [get_ports ENFIN]

set_property PACKAGE_PIN A24 [get_ports PROG_B_ON]

set_property PACKAGE_PIN N12 [get_ports VP]
set_property PACKAGE_PIN P11 [get_ports VN]

# Signal Input -----------------------------------------------------
set_property PACKAGE_PIN AF19 [get_ports {SIGIN_P[0]}]
set_property PACKAGE_PIN AF20 [get_ports {SIGIN_N[0]}]
set_property PACKAGE_PIN AD20 [get_ports {SIGIN_P[16]}]
set_property PACKAGE_PIN AE20 [get_ports {SIGIN_N[16]}]
set_property PACKAGE_PIN AE18 [get_ports {SIGIN_P[1]}]
set_property PACKAGE_PIN AF18 [get_ports {SIGIN_N[1]}]
set_property PACKAGE_PIN AC18 [get_ports {SIGIN_P[17]}]
set_property PACKAGE_PIN AD18 [get_ports {SIGIN_N[17]}]
set_property PACKAGE_PIN AE17 [get_ports {SIGIN_P[2]}]
set_property PACKAGE_PIN AF17 [get_ports {SIGIN_N[2]}]
set_property PACKAGE_PIN AB17 [get_ports {SIGIN_P[18]}]
set_property PACKAGE_PIN AC17 [get_ports {SIGIN_N[18]}]
set_property PACKAGE_PIN AF14 [get_ports {SIGIN_P[3]}]
set_property PACKAGE_PIN AF15 [get_ports {SIGIN_N[3]}]
set_property PACKAGE_PIN AD15 [get_ports {SIGIN_P[19]}]
set_property PACKAGE_PIN AE15 [get_ports {SIGIN_N[19]}]
set_property PACKAGE_PIN AE13 [get_ports {SIGIN_P[4]}]
set_property PACKAGE_PIN AF13 [get_ports {SIGIN_N[4]}]
set_property PACKAGE_PIN AC13 [get_ports {SIGIN_P[20]}]
set_property PACKAGE_PIN AD13 [get_ports {SIGIN_N[20]}]
set_property PACKAGE_PIN AE12 [get_ports {SIGIN_P[5]}]
set_property PACKAGE_PIN AF12 [get_ports {SIGIN_N[5]}]
set_property PACKAGE_PIN AD10 [get_ports {SIGIN_P[21]}]
set_property PACKAGE_PIN AE10 [get_ports {SIGIN_N[21]}]
set_property PACKAGE_PIN AE8 [get_ports {SIGIN_P[6]}]
set_property PACKAGE_PIN AF8 [get_ports {SIGIN_N[6]}]
set_property PACKAGE_PIN AF10 [get_ports {SIGIN_P[22]}]
set_property PACKAGE_PIN AF9 [get_ports {SIGIN_N[22]}]
set_property PACKAGE_PIN AE7 [get_ports {SIGIN_P[7]}]
set_property PACKAGE_PIN AF7 [get_ports {SIGIN_N[7]}]
set_property PACKAGE_PIN AB7 [get_ports {SIGIN_P[23]}]
set_property PACKAGE_PIN AC7 [get_ports {SIGIN_N[23]}]
set_property PACKAGE_PIN AF3 [get_ports {SIGIN_P[8]}]
set_property PACKAGE_PIN AF2 [get_ports {SIGIN_N[8]}]
set_property PACKAGE_PIN AE3 [get_ports {SIGIN_P[24]}]
set_property PACKAGE_PIN AE2 [get_ports {SIGIN_N[24]}]
set_property PACKAGE_PIN AD1 [get_ports {SIGIN_P[9]}]
set_property PACKAGE_PIN AE1 [get_ports {SIGIN_N[9]}]
set_property PACKAGE_PIN AD4 [get_ports {SIGIN_P[25]}]
set_property PACKAGE_PIN AD3 [get_ports {SIGIN_N[25]}]
set_property PACKAGE_PIN AB1 [get_ports {SIGIN_P[10]}]
set_property PACKAGE_PIN AC1 [get_ports {SIGIN_N[10]}]
set_property PACKAGE_PIN AC4 [get_ports {SIGIN_P[26]}]
set_property PACKAGE_PIN AC3 [get_ports {SIGIN_N[26]}]
set_property PACKAGE_PIN AB2 [get_ports {SIGIN_P[11]}]
set_property PACKAGE_PIN AC2 [get_ports {SIGIN_N[11]}]
set_property PACKAGE_PIN AA4 [get_ports {SIGIN_P[27]}]
set_property PACKAGE_PIN AB4 [get_ports {SIGIN_N[27]}]
set_property PACKAGE_PIN AA3 [get_ports {SIGIN_P[12]}]
set_property PACKAGE_PIN AA2 [get_ports {SIGIN_N[12]}]
set_property PACKAGE_PIN Y3 [get_ports {SIGIN_P[28]}]
set_property PACKAGE_PIN Y2 [get_ports {SIGIN_N[28]}]
set_property PACKAGE_PIN W1 [get_ports {SIGIN_P[13]}]
set_property PACKAGE_PIN Y1 [get_ports {SIGIN_N[13]}]
set_property PACKAGE_PIN W6 [get_ports {SIGIN_P[29]}]
set_property PACKAGE_PIN W5 [get_ports {SIGIN_N[29]}]
set_property PACKAGE_PIN V2 [get_ports {SIGIN_P[14]}]
set_property PACKAGE_PIN V1 [get_ports {SIGIN_N[14]}]
set_property PACKAGE_PIN V3 [get_ports {SIGIN_P[30]}]
set_property PACKAGE_PIN W3 [get_ports {SIGIN_N[30]}]
set_property PACKAGE_PIN U2 [get_ports {SIGIN_P[15]}]
set_property PACKAGE_PIN U1 [get_ports {SIGIN_N[15]}]
set_property PACKAGE_PIN U6 [get_ports {SIGIN_P[31]}]
set_property PACKAGE_PIN U5 [get_ports {SIGIN_N[31]}]

# MZN connector --------------------------------------------------
set_property PACKAGE_PIN C19 [get_ports FRST_P]
set_property PACKAGE_PIN B19 [get_ports FRST_N]
set_property PACKAGE_PIN C14 [get_ports SLOT_POS_P]
set_property PACKAGE_PIN C13 [get_ports SLOT_POS_N]

set_property PACKAGE_PIN K25 [get_ports {STATUS_MZN_P[0]}]
set_property PACKAGE_PIN K26 [get_ports {STATUS_MZN_N[0]}]

set_property PACKAGE_PIN B17 [get_ports {STATUS_BASE_P[0]}]
set_property PACKAGE_PIN A17 [get_ports {STATUS_BASE_N[0]}]
set_property PACKAGE_PIN A18 [get_ports {STATUS_BASE_P[1]}]
set_property PACKAGE_PIN A19 [get_ports {STATUS_BASE_N[1]}]
set_property PACKAGE_PIN D9  [get_ports {STATUS_BASE_P[2]}]
set_property PACKAGE_PIN D8  [get_ports {STATUS_BASE_N[2]}]
set_property PACKAGE_PIN C9  [get_ports {STATUS_BASE_P[3]}]
set_property PACKAGE_PIN B9  [get_ports {STATUS_BASE_N[3]}]
set_property PACKAGE_PIN M25 [get_ports {STATUS_BASE_P[4]}]
set_property PACKAGE_PIN L25 [get_ports {STATUS_BASE_N[4]}]

set_property PACKAGE_PIN B10 [get_ports CDCM_TXP]
set_property PACKAGE_PIN A10 [get_ports CDCM_TXN]
set_property PACKAGE_PIN B12 [get_ports CDCM_RXP]
set_property PACKAGE_PIN B11 [get_ports CDCM_RXN]


set_property PACKAGE_PIN P24 [get_ports BBS_PRI_ACTIVE_P]
set_property PACKAGE_PIN N24 [get_ports BBS_PRI_ACTIVE_N]
set_property PACKAGE_PIN D19 [get_ports BBS_SCN_REQ_P]
set_property PACKAGE_PIN D20 [get_ports BBS_SCN_REQ_N]
set_property PACKAGE_PIN M24 [get_ports BBS_POSI_P]
set_property PACKAGE_PIN L24 [get_ports BBS_POSI_N]
set_property PACKAGE_PIN R26 [get_ports BBS_PISO_P]
set_property PACKAGE_PIN P26 [get_ports BBS_PISO_N]
set_property PACKAGE_PIN C12 [get_ports BBS_CLK_P]
set_property PACKAGE_PIN C11 [get_ports BBS_CLK_N]

set_property PACKAGE_PIN U26 [get_ports {DDRD_P[4]}]
set_property PACKAGE_PIN V26 [get_ports {DDRD_N[4]}]
set_property PACKAGE_PIN AD25 [get_ports {DDRD_P[3]}]
set_property PACKAGE_PIN AE25 [get_ports {DDRD_N[3]}]
set_property PACKAGE_PIN AC23 [get_ports {DDRD_P[2]}]
set_property PACKAGE_PIN AC24 [get_ports {DDRD_N[2]}]
set_property PACKAGE_PIN N21 [get_ports CLKHUL_P]
set_property PACKAGE_PIN N22 [get_ports CLKHUL_N]
set_property PACKAGE_PIN AA25 [get_ports {DDRD_P[1]}]
set_property PACKAGE_PIN AB25 [get_ports {DDRD_N[1]}]
set_property PACKAGE_PIN V23 [get_ports CLKDDR_P]
set_property PACKAGE_PIN V24 [get_ports CLKDDR_N]
set_property PACKAGE_PIN U24 [get_ports {DDRD_P[0]}]
set_property PACKAGE_PIN U25 [get_ports {DDRD_N[0]}]
set_property PACKAGE_PIN Y25 [get_ports {DDRD_P[6]}]
set_property PACKAGE_PIN Y26 [get_ports {DDRD_N[6]}]
set_property PACKAGE_PIN W25 [get_ports {DDRD_P[5]}]
set_property PACKAGE_PIN W26 [get_ports {DDRD_N[5]}]
set_property PACKAGE_PIN AD26 [get_ports {DDRD_P[8]}]
set_property PACKAGE_PIN AE26 [get_ports {DDRD_N[8]}]
set_property PACKAGE_PIN AB26 [get_ports {DDRD_P[7]}]
set_property PACKAGE_PIN AC26 [get_ports {DDRD_N[7]}]

# =============================================================================
# I/O standard
# =============================================================================
# Sytem ----------------------------------------------------------
set_property IOSTANDARD LVDS_25 [get_ports CLKOSC_P]
set_property DIFF_TERM TRUE [get_ports CLKOSC_P]
set_property DIFF_TERM TRUE [get_ports CLKOSC_N]

set_property IOSTANDARD LVCMOS25 [get_ports {DIP[*]}]
set_property IOSTANDARD LVCMOS25 [get_ports ENFIN]
set_property IOSTANDARD LVCMOS18 [get_ports PROG_B_ON]

# Signal input ----------------------------------------------------
set_property IOSTANDARD LVDS [get_ports {SIGIN_P[*]}]
set_property DIFF_TERM true [get_ports {SIGIN_P[*]}]

# MZN connector ---------------------------------------------------
set_property IOSTANDARD LVDS_25 [get_ports CLKHUL_P]
set_property DIFF_TERM TRUE [get_ports CLKHUL_P]

set_property IOSTANDARD LVDS_25 [get_ports CDCM_TXP]
set_property IOSTANDARD LVDS_25 [get_ports CDCM_TXN]
set_property IOSTANDARD LVDS_25 [get_ports CDCM_RXP]
set_property IOSTANDARD LVDS_25 [get_ports CDCM_RXN]
set_property DIFF_TERM TRUE [get_ports CDCM_RXP]

set_property IOSTANDARD LVDS_25 [get_ports BBS_PRI_ACTIVE_P]
set_property DIFF_TERM TRUE [get_ports BBS_PRI_ACTIVE_P]
set_property IOB TRUE [get_ports BBS_PRI_ACTIVE_P]

set_property IOSTANDARD LVDS_25 [get_ports BBS_SCN_REQ_P]
set_property IOB TRUE [get_ports BBS_SCN_REQ_P]

set_property IOSTANDARD LVDS_25 [get_ports BBS_POSI_P]
set_property DIFF_TERM TRUE [get_ports BBS_POSI_P]
set_property IOB TRUE [get_ports BBS_POSI_P]

set_property IOSTANDARD LVDS_25 [get_ports BBS_PISO_P]
set_property IOB TRUE [get_ports BBS_PISO_P]

set_property IOSTANDARD LVDS_25 [get_ports BBS_CLK_P]
set_property DIFF_TERM TRUE [get_ports BBS_CLK_P]


set_property IOSTANDARD LVDS_25 [get_ports {STATUS_MZN_P[*]}]
set_property IOSTANDARD LVDS_25 [get_ports {STATUS_BASE_P[*]}]

set_property IOSTANDARD LVDS_25 [get_ports CLKDDR_P]
set_property IOSTANDARD LVDS_25 [get_ports {DDRD_P[*]}]







