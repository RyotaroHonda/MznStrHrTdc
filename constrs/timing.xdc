# Clock definition
#create_clock -period 10.000 -name clk_osc -waveform {0.000 5.000} [get_ports CLKOSC_P]
#set_input_jitter clk_osc 0.030

#create_clock -period 8.000 -name clk_hul -waveform {0.000 4.000} [get_ports CLKHUL_P]
#set_input_jitter clk_hul 0.030

#set_case_analysis 0 [get_pins u_BUFGMUX_inst/S]

#set_clock_groups -name async_input -physically_exclusive -group [get_clocks clk_osc] -group [get_clocks clk_hul]

#create_clock -period 8.000 -name clk_input -waveform {0.000 4.000} [get_pins u_BUFGHUL/O]
#create_clock -period 8.000 -name clk_input -waveform {0.000 4.000} [get_ports CLKHUL_P]
#set_input_jitter clk_input 0.030

create_clock -period 16.000 -name clk_bridge -waveform {0.000 8.000} [get_ports BBS_CLK_P]
set_input_jitter clk_bridge 0.030

# constrains to clocks generated
create_generated_clock -name clk_sys    [get_pins u_clk_tdc/inst/mmcm_adv_inst/CLKOUT0]
create_generated_clock -name clk_tdc    [get_pins u_clk_tdc/inst/mmcm_adv_inst/CLKOUT1]
create_generated_clock -name clk_icap   [get_pins u_clk_tdc/inst/mmcm_adv_inst/CLKOUT2]
create_generated_clock -name clk_idelay [get_pins u_clk_sys/inst/mmcm_adv_inst/CLKOUT0]

#create_generated_clock -name clk_ser  -master_clock clk_input [get_pins u_clk_cbt/inst/mmcm_adv_inst/CLKOUT0]

create_generated_clock -name clk_calib1 [get_pins u_clk_calib1/inst/mmcm_adv_inst/CLKOUT0]
create_generated_clock -name clk_calib2 [get_pins u_clk_calib2/inst/mmcm_adv_inst/CLKOUT0]

set_clock_groups -name async_clk -asynchronous -group {clk_sys clk_tdc} -group {clk_calib1 clk_calib2} -group clk_icap -group clk_bridge -group clk_idelay

set_false_path -through [get_nets u_DCT_Inst/reg_extra_path]

#set_false_path -from [get_pins {u_HRTDC_Inst/u_CStop_Inst/u_Cstop_Inst/u_CDC_Inst/u_tdc2sysFIFO/U0/inst_fifo_gen/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_reg[*]/C}] -to [get_pins u_HRTDC_Inst/u_CStop_Inst/u_Cstop_Inst/u_CDC_Inst/u_tdc2sysFIFO/U0/inst_fifo_gen/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/ram_full_fb_i_reg/D]
#set_false_path -from [get_pins {u_HRTDC_Inst/u_CStop_Inst/u_Cstop_Inst/u_CDC_Inst/u_tdc2sysFIFO/U0/inst_fifo_gen/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1_reg[*]/C}] -to [get_pins u_HRTDC_Inst/u_CStop_Inst/u_Cstop_Inst/u_CDC_Inst/u_tdc2sysFIFO/U0/inst_fifo_gen/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/ram_full_fb_i_reg/D]
#set_false_path -from [get_pins {u_HRTDC_Inst/u_CStop_Inst/u_Cstop_Inst/u_CDC_Inst/u_tdc2sysFIFO/U0/inst_fifo_gen/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_reg[*]/C}] -to [get_pins u_HRTDC_Inst/u_CStop_Inst/u_Cstop_Inst/u_CDC_Inst/u_tdc2sysFIFO/U0/inst_fifo_gen/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/ram_full_i_reg/D]
#set_false_path -from [get_pins {u_HRTDC_Inst/u_CStop_Inst/u_Cstop_Inst/u_CDC_Inst/u_tdc2sysFIFO/U0/inst_fifo_gen/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1_reg[*]/C}] -to [get_pins u_HRTDC_Inst/u_CStop_Inst/u_Cstop_Inst/u_CDC_Inst/u_tdc2sysFIFO/U0/inst_fifo_gen/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/ram_full_i_reg/D]

#set_false_path -from [get_pins {u_HRTDC_Inst/gen_leading_block[*].u_HRTLeading_Inst/gen_timing_unit[*].u_tdc0_Inst/u_CDC_Inst/u_tdc2sysFIFO/U0/inst_fifo_gen/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_reg[*]/C}]    -to [get_pins {u_HRTDC_Inst/gen_leading_block[*].u_HRTLeading_Inst/gen_timing_unit[*].u_tdc0_Inst/u_CDC_Inst/u_tdc2sysFIFO/U0/inst_fifo_gen/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/ram_full_fb_i_reg/D}]
#set_false_path -from [get_pins {u_HRTDC_Inst/gen_leading_block[*].u_HRTLeading_Inst/gen_timing_unit[*].u_tdc0_Inst/u_CDC_Inst/u_tdc2sysFIFO/U0/inst_fifo_gen/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1_reg[*]/C}] -to [get_pins {u_HRTDC_Inst/gen_leading_block[*].u_HRTLeading_Inst/gen_timing_unit[*].u_tdc0_Inst/u_CDC_Inst/u_tdc2sysFIFO/U0/inst_fifo_gen/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/ram_full_fb_i_reg/D}]
#set_false_path -from [get_pins {u_HRTDC_Inst/gen_leading_block[*].u_HRTLeading_Inst/gen_timing_unit[*].u_tdc0_Inst/u_CDC_Inst/u_tdc2sysFIFO/U0/inst_fifo_gen/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_reg[*]/C}]    -to [get_pins {u_HRTDC_Inst/gen_leading_block[*].u_HRTLeading_Inst/gen_timing_unit[*].u_tdc0_Inst/u_CDC_Inst/u_tdc2sysFIFO/U0/inst_fifo_gen/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/ram_full_i_reg/D}]
#set_false_path -from [get_pins {u_HRTDC_Inst/gen_leading_block[*].u_HRTLeading_Inst/gen_timing_unit[*].u_tdc0_Inst/u_CDC_Inst/u_tdc2sysFIFO/U0/inst_fifo_gen/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1_reg[*]/C}] -to [get_pins {u_HRTDC_Inst/gen_leading_block[*].u_HRTLeading_Inst/gen_timing_unit[*].u_tdc0_Inst/u_CDC_Inst/u_tdc2sysFIFO/U0/inst_fifo_gen/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/ram_full_i_reg/D}]
#
#set_false_path -from [get_pins {u_HRTDC_Inst/gen_trailing_block[*].u_HRTTrailing_Inst/gen_timing_unit[*].u_tdc0_Inst/u_CDC_Inst/u_tdc2sysFIFO/U0/inst_fifo_gen/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_reg[*]/C}]    -to [get_pins {u_HRTDC_Inst/gen_trailing_block[*].u_HRTTrailing_Inst/gen_timing_unit[*].u_tdc0_Inst/u_CDC_Inst/u_tdc2sysFIFO/U0/inst_fifo_gen/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/ram_full_fb_i_reg/D}]
#set_false_path -from [get_pins {u_HRTDC_Inst/gen_trailing_block[*].u_HRTTrailing_Inst/gen_timing_unit[*].u_tdc0_Inst/u_CDC_Inst/u_tdc2sysFIFO/U0/inst_fifo_gen/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1_reg[*]/C}] -to [get_pins {u_HRTDC_Inst/gen_trailing_block[*].u_HRTTrailing_Inst/gen_timing_unit[*].u_tdc0_Inst/u_CDC_Inst/u_tdc2sysFIFO/U0/inst_fifo_gen/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/ram_full_fb_i_reg/D}]
#set_false_path -from [get_pins {u_HRTDC_Inst/gen_trailing_block[*].u_HRTTrailing_Inst/gen_timing_unit[*].u_tdc0_Inst/u_CDC_Inst/u_tdc2sysFIFO/U0/inst_fifo_gen/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_reg[*]/C}]    -to [get_pins {u_HRTDC_Inst/gen_trailing_block[*].u_HRTTrailing_Inst/gen_timing_unit[*].u_tdc0_Inst/u_CDC_Inst/u_tdc2sysFIFO/U0/inst_fifo_gen/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/ram_full_i_reg/D}]
#set_false_path -from [get_pins {u_HRTDC_Inst/gen_trailing_block[*].u_HRTTrailing_Inst/gen_timing_unit[*].u_tdc0_Inst/u_CDC_Inst/u_tdc2sysFIFO/U0/inst_fifo_gen/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1_reg[*]/C}] -to [get_pins {u_HRTDC_Inst/gen_trailing_block[*].u_HRTTrailing_Inst/gen_timing_unit[*].u_tdc0_Inst/u_CDC_Inst/u_tdc2sysFIFO/U0/inst_fifo_gen/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/ram_full_i_reg/D}]
#
#set_false_path -from [get_pins {u_HRTDC_Inst/u_CStop_Inst/u_Cstop_Inst/u_CDC_Inst/u_tdc2sysFIFO/U0/inst_fifo_gen/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_reg[*]/C}] -to [get_pins u_HRTDC_Inst/u_CStop_Inst/u_Cstop_Inst/u_CDC_Inst/u_tdc2sysFIFO/U0/inst_fifo_gen/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/ram_full_fb_i_reg/D]
#set_false_path -from [get_pins {u_HRTDC_Inst/u_CStop_Inst/u_Cstop_Inst/u_CDC_Inst/u_tdc2sysFIFO/U0/inst_fifo_gen/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1_reg[*]/C}] -to [get_pins u_HRTDC_Inst/u_CStop_Inst/u_Cstop_Inst/u_CDC_Inst/u_tdc2sysFIFO/U0/inst_fifo_gen/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/ram_full_fb_i_reg/D]
#set_false_path -from [get_pins {u_HRTDC_Inst/u_CStop_Inst/u_Cstop_Inst/u_CDC_Inst/u_tdc2sysFIFO/U0/inst_fifo_gen/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_reg[*]/C}] -to [get_pins u_HRTDC_Inst/u_CStop_Inst/u_Cstop_Inst/u_CDC_Inst/u_tdc2sysFIFO/U0/inst_fifo_gen/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/ram_full_i_reg/D]
#set_false_path -from [get_pins {u_HRTDC_Inst/u_CStop_Inst/u_Cstop_Inst/u_CDC_Inst/u_tdc2sysFIFO/U0/inst_fifo_gen/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1_reg[*]/C}] -to [get_pins u_HRTDC_Inst/u_CStop_Inst/u_Cstop_Inst/u_CDC_Inst/u_tdc2sysFIFO/U0/inst_fifo_gen/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/ram_full_i_reg/D]
#




