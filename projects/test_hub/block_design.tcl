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
  DATA_FILE cdce_100.mem
} {
  iic cdce_iic_tri_io
  aclk clk_i
}

# Create cdce_gpio
cell pavel-demin:user:cdce_gpio gpio_0 {} {
  gpio cdce_gpio_tri_io
  aclk clk_i
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
  CFG_DATA_WIDTH 32
  STS_DATA_WIDTH 32
} {
  S_AXIS usb_0/M_AXIS
  M_AXIS usb_0/S_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# LED

# Create port_slicer
cell pavel-demin:user:port_slicer slice_0 {
  DIN_WIDTH 32 DIN_FROM 2 DIN_TO 0
} {
  din hub_0/cfg_data
}

# Create c_counter_binary
cell xilinx.com:ip:c_counter_binary cntr_0 {
  OUTPUT_WIDTH 32
} {
  CLK usb_clk_i
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_1 {
  DIN_WIDTH 32 DIN_FROM 25 DIN_TO 25
} {
  din cntr_0/Q
}

# Create xlconcat
cell xilinx.com:ip:xlconcat concat_0 {
  NUM_PORTS 2
  IN0_WIDTH 3
  IN1_WIDTH 1
} {
  In0 slice_0/dout
  In1 slice_1/dout
  dout led_o
}

# COUNTER

# Create axis_counter
cell pavel-demin:user:axis_counter cntr_1 {
  AXIS_TDATA_WIDTH 32
} {
  M_AXIS hub_0/S00_AXIS
  aclk pll_0/clk_out1
}

# FIFO

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

# PMOD A

# Delete input/output port
delete_bd_objs [get_bd_ports pmod_a_tri_io]

# Create output port
create_bd_port -dir O -from 2 -to 0 pmod_a_tri_io

# SPI

# Create axis_spi
cell pavel-demin:user:axis_spi spi_0 {
  SPI_DATA_WIDTH 24
} {
  S_AXIS fifo_0/M_AXIS
  spi_data pmod_a_tri_io
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# FIFO

# Create axis_fifo
cell pavel-demin:user:axis_fifo fifo_1 {
  S_AXIS_TDATA_WIDTH 32
  M_AXIS_TDATA_WIDTH 32
  WRITE_DEPTH 4096
} {
  S_AXIS hub_0/M01_AXIS
  M_AXIS hub_0/S01_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# BRAM

# Create blk_mem_gen
cell xilinx.com:ip:blk_mem_gen bram_0 {
  MEMORY_TYPE True_Dual_Port_RAM
  USE_BRAM_BLOCK Stand_Alone
  USE_BYTE_WRITE_ENABLE true
  BYTE_SIZE 8
  WRITE_WIDTH_A 32
  WRITE_DEPTH_A 131072
  REGISTER_PORTA_OUTPUT_OF_MEMORY_PRIMITIVES false
  REGISTER_PORTB_OUTPUT_OF_MEMORY_PRIMITIVES false
} {
  BRAM_PORTA hub_0/B02_BRAM
  BRAM_PORTB hub_0/B03_BRAM
}
