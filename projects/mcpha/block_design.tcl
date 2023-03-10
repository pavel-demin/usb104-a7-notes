# Create clk_wiz
cell xilinx.com:ip:clk_wiz pll_0 {
  PRIMITIVE PLL
  PRIM_IN_FREQ.VALUE_SRC USER
  PRIM_IN_FREQ 100
  CLKOUT1_USED true
  CLKOUT1_REQUESTED_OUT_FREQ 100
  JITTER_SEL Min_O_Jitter
  JITTER_OPTIONS PS
  CLKIN1_UI_JITTER 600
  USE_RESET false
} {
  clk_in1 adc_dco_i
}

# Create cdce_iic
cell pavel-demin:user:cdce_iic iic_0 {
  DATA_SIZE 132
  DATA_FILE [pwd]/cfg/cdce_100.mem
} {
  iic cdce_iic_tri_io
  aclk clk_i
}

# Create cdce_gpio
cell pavel-demin:user:cdce_gpio gpio_0 {} {
  gpio cdce_gpio_tri_io
  aclk clk_i
}

# ADC

# Create axis_zmod_adc
cell pavel-demin:user:axis_zmod_adc adc_0 {
  ADC_DATA_WIDTH 14
} {
  aclk pll_0/clk_out1
  adc_data adc_data_i
}

# Create xlconstant
cell xilinx.com:ip:xlconstant const_0

# Create proc_sys_reset
cell xilinx.com:ip:proc_sys_reset rst_0 {} {
  ext_reset_in const_0/dout
  dcm_locked pll_0/locked
  slowest_sync_clk pll_0/clk_out1
}

# USB

# Create axis_usb
cell pavel-demin:user:axis_usb usb_0 {} {
  usb_clk usb_clk_i
  usb_empty usb_rxfn_i
  usb_full usb_txen_i
  usb_rdn usb_rdn_o
  usb_wrn usb_wrn_o
  usb_oen usb_oen_o
  usb_siwun usb_siwun_o
  usb_data usb_data_tri_io
  aclk pll_0/clk_out1
}

# HUB

# Create axis_hub
cell pavel-demin:user:axis_hub hub_0 {
  CFG_DATA_WIDTH 544
  STS_DATA_WIDTH 192
} {
  S_AXIS usb_0/M_AXIS
  M_AXIS usb_0/S_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create port_slicer
cell pavel-demin:user:port_slicer rst_slice_0 {
  DIN_WIDTH 544 DIN_FROM 1 DIN_TO 0
} {
  din hub_0/cfg_data
}

# Create port_slicer
cell pavel-demin:user:port_slicer rst_slice_1 {
  DIN_WIDTH 544 DIN_FROM 3 DIN_TO 2
} {
  din hub_0/cfg_data
}

# Create port_slicer
cell pavel-demin:user:port_slicer rst_slice_2 {
  DIN_WIDTH 544 DIN_FROM 5 DIN_TO 4
} {
  din hub_0/cfg_data
}

# Create port_slicer
cell pavel-demin:user:port_slicer neg_slice_0 {
  DIN_WIDTH 544 DIN_FROM 32 DIN_TO 32
} {
  din hub_0/cfg_data
}

# Create port_slicer
cell pavel-demin:user:port_slicer neg_slice_1 {
  DIN_WIDTH 544 DIN_FROM 33 DIN_TO 33
} {
  din hub_0/cfg_data
}

# rate_0/cfg_data and rate_1/cfg_data

# Create port_slicer
cell pavel-demin:user:port_slicer slice_0 {
  DIN_WIDTH 544 DIN_FROM 79 DIN_TO 64
} {
  din hub_0/cfg_data
}

# Create port_slicer
cell pavel-demin:user:port_slicer cfg_slice_0 {
  DIN_WIDTH 544 DIN_FROM 255 DIN_TO 96
} {
  din hub_0/cfg_data
}

# Create port_slicer
cell pavel-demin:user:port_slicer cfg_slice_1 {
  DIN_WIDTH 544 DIN_FROM 415 DIN_TO 256
} {
  din hub_0/cfg_data
}

# Create port_slicer
cell pavel-demin:user:port_slicer cfg_slice_2 {
  DIN_WIDTH 544 DIN_FROM 543 DIN_TO 416
} {
  din hub_0/cfg_data
}

# Create axis_broadcaster
cell xilinx.com:ip:axis_broadcaster bcast_0 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  M_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 2
  NUM_MI 4
  M00_TDATA_REMAP {tdata[15:0]}
  M01_TDATA_REMAP {tdata[31:16]}
  M02_TDATA_REMAP {16'b0000000000000000}
  M03_TDATA_REMAP {16'b0000000000000000}
} {
  S_AXIS adc_0/M_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

for {set i 0} {$i <= 1} {incr i} {

  # Create axis_negator
  cell pavel-demin:user:axis_negator neg_${i} {
    AXIS_TDATA_WIDTH 16
  } {
    S_AXIS bcast_0/M0${i}_AXIS
    cfg_flag neg_slice_${i}/dout
    aclk pll_0/clk_out1
  }

  # Create axis_variable
  cell pavel-demin:user:axis_variable rate_${i} {
    AXIS_TDATA_WIDTH 16
  } {
    cfg_data slice_0/dout
    aclk pll_0/clk_out1
    aresetn rst_0/peripheral_aresetn
  }

  # Create cic_compiler
  cell xilinx.com:ip:cic_compiler cic_${i} {
    INPUT_DATA_WIDTH.VALUE_SRC USER
    FILTER_TYPE Decimation
    NUMBER_OF_STAGES 6
    SAMPLE_RATE_CHANGES Programmable
    MINIMUM_RATE 4
    MAXIMUM_RATE 8192
    FIXED_OR_INITIAL_RATE 4
    INPUT_SAMPLE_FREQUENCY 100
    CLOCK_FREQUENCY 100
    INPUT_DATA_WIDTH 14
    QUANTIZATION Truncation
    OUTPUT_DATA_WIDTH 16
    USE_XTREME_DSP_SLICE false
    HAS_ARESETN true
  } {
    S_AXIS_DATA neg_${i}/M_AXIS
    S_AXIS_CONFIG rate_${i}/M_AXIS
    aclk pll_0/clk_out1
    aresetn rst_0/peripheral_aresetn
  }

}

# Create axis_combiner
cell  xilinx.com:ip:axis_combiner comb_0 {
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 2
} {
  S00_AXIS cic_0/M_AXIS_DATA
  S01_AXIS cic_1/M_AXIS_DATA
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create fir_compiler
cell xilinx.com:ip:fir_compiler fir_0 {
  DATA_WIDTH.VALUE_SRC USER
  DATA_WIDTH 16
  COEFFICIENTVECTOR {4.1811671868e-06, 2.9962842696e-05, 1.2482197822e-04, 3.4115329109e-04, 7.6531605277e-04, 1.5146861420e-03, 2.7310518774e-03, 4.5689619595e-03, 7.1784709852e-03, 1.0683018711e-02, 1.5154640468e-02, 2.0589984382e-02, 2.6891362735e-02, 3.3857037591e-02, 4.1184036845e-02, 4.8485104800e-02, 5.5319177108e-02, 6.1232429042e-02, 6.5804926185e-02, 6.8696615948e-02, 6.9686119779e-02, 6.8696615948e-02, 6.5804926185e-02, 6.1232429042e-02, 5.5319177108e-02, 4.8485104800e-02, 4.1184036845e-02, 3.3857037591e-02, 2.6891362735e-02, 2.0589984382e-02, 1.5154640468e-02, 1.0683018711e-02, 7.1784709852e-03, 4.5689619595e-03, 2.7310518774e-03, 1.5146861420e-03, 7.6531605277e-04, 3.4115329109e-04, 1.2482197822e-04, 2.9962842696e-05, 4.1811671868e-06}
  COEFFICIENT_WIDTH 16
  QUANTIZATION Quantize_Only
  BESTPRECISION true
  NUMBER_PATHS 2
  SAMPLE_FREQUENCY 25
  CLOCK_FREQUENCY 100
  OUTPUT_ROUNDING_MODE Non_Symmetric_Rounding_Up
  OUTPUT_WIDTH 15
  HAS_ARESETN true
} {
  S_AXIS_DATA comb_0/M_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create axis_broadcaster
cell xilinx.com:ip:axis_broadcaster bcast_1 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  M_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 2
  NUM_MI 6
  M00_TDATA_REMAP {tdata[15:0]}
  M01_TDATA_REMAP {tdata[31:16]}
  M02_TDATA_REMAP {tdata[15:0]}
  M03_TDATA_REMAP {tdata[31:16]}
  M04_TDATA_REMAP {tdata[15:0]}
  M05_TDATA_REMAP {tdata[31:16]}
} {
  S_AXIS fir_0/M_AXIS_DATA
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

module pha_0 {
  source projects/mcpha/pha.tcl
} {
  slice_0/din rst_slice_0/dout
  slice_1/din rst_slice_0/dout
  slice_2/din cfg_slice_0/dout
  slice_3/din cfg_slice_0/dout
  slice_4/din cfg_slice_0/dout
  slice_5/din cfg_slice_0/dout
  slice_6/din cfg_slice_0/dout
  timer_0/S_AXIS bcast_0/M02_AXIS
  pha_0/S_AXIS bcast_1/M00_AXIS
}

module hst_0 {
  source projects/mcpha/hst.tcl
} {
  slice_0/din rst_slice_0/dout
  hst_0/S_AXIS pha_0/vldtr_0/M_AXIS
}

module pha_1 {
  source projects/mcpha/pha.tcl
} {
  slice_0/din rst_slice_1/dout
  slice_1/din rst_slice_1/dout
  slice_2/din cfg_slice_1/dout
  slice_3/din cfg_slice_1/dout
  slice_4/din cfg_slice_1/dout
  slice_5/din cfg_slice_1/dout
  slice_6/din cfg_slice_1/dout
  timer_0/S_AXIS bcast_0/M03_AXIS
  pha_0/S_AXIS bcast_1/M01_AXIS
}

module hst_1 {
  source projects/mcpha/hst.tcl
} {
  slice_0/din rst_slice_1/dout
  hst_0/S_AXIS pha_1/vldtr_0/M_AXIS
}

module osc_0 {
  source projects/mcpha/osc.tcl
} {
  slice_0/din rst_slice_2/dout
  slice_1/din rst_slice_2/dout
  slice_2/din cfg_slice_2/dout
  slice_3/din cfg_slice_2/dout
  slice_4/din cfg_slice_2/dout
  slice_5/din cfg_slice_2/dout
  slice_6/din cfg_slice_2/dout
  slice_7/din cfg_slice_2/dout
  sel_0/S00_AXIS bcast_1/M02_AXIS
  sel_0/S01_AXIS bcast_1/M03_AXIS
  comb_0/S00_AXIS bcast_1/M04_AXIS
  comb_0/S01_AXIS bcast_1/M05_AXIS
}

# Create xlconcat
cell xilinx.com:ip:xlconcat concat_1 {
  NUM_PORTS 4
  IN0_WIDTH 64
  IN1_WIDTH 64
  IN2_WIDTH 32
  IN3_WIDTH 32
} {
  In0 pha_0/timer_0/sts_data
  In1 pha_1/timer_0/sts_data
  In2 osc_0/scope_0/sts_data
  In3 osc_0/writer_0/sts_data
  dout hub_0/sts_data
}

wire hst_0/bram_0/BRAM_PORTA hub_0/B01_BRAM
wire hst_1/bram_0/BRAM_PORTA hub_0/B02_BRAM
wire osc_0/bram_0/BRAM_PORTA hub_0/B03_BRAM

# ADC SPI

# Create axis_fifo
cell pavel-demin:user:axis_fifo fifo_0 {
  S_AXIS_TDATA_WIDTH 32
  M_AXIS_TDATA_WIDTH 32
  WRITE_DEPTH 1024
} {
  S_AXIS hub_0/M00_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create axis_spi
cell pavel-demin:user:axis_spi spi_0 {
  SPI_DATA_WIDTH 24
} {
  S_AXIS fifo_0/M_AXIS
  spi_data adc_spi_o
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}
