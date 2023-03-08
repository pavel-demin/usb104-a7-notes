# PLL

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

# CDCE IIC

# Create cdce_iic
cell pavel-demin:user:cdce_iic iic_0 {
  DATA_SIZE 132
  DATA_FILE [pwd]/cfg/cdce_100.mem
} {
  iic cdce_iic_tri_io
  aclk clk_i
}

# CDCE GPIO

# Create cdce_gpio
cell pavel-demin:user:cdce_gpio gpio_0 {} {
  gpio cdce_gpio_tri_io
  aclk clk_i
}

# RESET

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
  CFG_DATA_WIDTH 32
  STS_DATA_WIDTH 32
} {
  S_AXIS usb_0/M_AXIS
  M_AXIS usb_0/S_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_0 {
  DIN_WIDTH 32 DIN_FROM 0 DIN_TO 0
} {
  din hub_0/cfg_data
}

# ADC

# Create axis_zmod_adc
cell pavel-demin:user:axis_zmod_adc adc_0 {
  ADC_DATA_WIDTH 14
} {
  aclk pll_0/clk_out1
  adc_data adc_data_i
}

# FIFO

# Create axis_fifo
cell pavel-demin:user:axis_fifo fifo_0 {
  S_AXIS_TDATA_WIDTH 32
  M_AXIS_TDATA_WIDTH 32
  WRITE_DEPTH 131072
} {
  S_AXIS adc_0/M_AXIS
  M_AXIS hub_0/S00_AXIS
  read_count hub_0/sts_data
  aclk pll_0/clk_out1
  aresetn slice_0/dout
}

# ADC SPI

# Create axis_fifo
cell pavel-demin:user:axis_fifo fifo_1 {
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
  S_AXIS fifo_1/M_AXIS
  spi_data adc_spi_o
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}
