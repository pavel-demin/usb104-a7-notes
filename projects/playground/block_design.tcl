# Create xlconstant
cell xilinx.com:ip:xlconstant const_0

# Create proc_sys_reset
cell xilinx.com:ip:proc_sys_reset rst_0 {} {
  ext_reset_in const_0/dout
  dcm_locked const_0/dout
  slowest_sync_clk clk_i
}

# USB

# Create axis_usb
cell axis_usb usb_0 {} {
  usb_clk usb_clk_i
  usb_empty usb_rxfn_i
  usb_full usb_txen_i
  usb_rdn usb_rdn_o
  usb_wrn usb_wrn_o
  usb_oen usb_oen_o
  usb_siwun usb_siwun_o
  usb_data usb_data_tri_io
  aclk clk_i
}

# HUB

# Create axis_hub
cell axis_hub hub_0 {
  CFG_DATA_WIDTH 96
  STS_DATA_WIDTH 64
} {
  S_AXIS usb_0/M_AXIS
  M_AXIS usb_0/S_AXIS
  aclk clk_i
  aresetn rst_0/peripheral_aresetn
}

# LED

# Create port_slicer
cell port_slicer slice_0 {
  DIN_WIDTH 96 DIN_FROM 3 DIN_TO 0
} {
  din hub_0/cfg_data
  dout led_o
}

# DSP48

# Create port_slicer
cell port_slicer slice_1 {
  DIN_WIDTH 96 DIN_FROM 47 DIN_TO 32
} {
  din hub_0/cfg_data
}

# Create port_slicer
cell port_slicer slice_2 {
  DIN_WIDTH 96 DIN_FROM 63 DIN_TO 48
} {
  din hub_0/cfg_data
}

# Create dsp_macro
cell xilinx.com:ip:dsp_macro dsp_0 {
  INSTRUCTION1 A*B
  A_WIDTH.VALUE_SRC USER
  B_WIDTH.VALUE_SRC USER
  OUTPUT_PROPERTIES User_Defined
  A_WIDTH 16
  B_WIDTH 16
  P_WIDTH 32
} {
  A slice_1/dout
  B slice_2/dout
  CLK clk_i
}

# Create xlconcat
cell xilinx.com:ip:xlconcat concat_0 {
  NUM_PORTS 2
  IN0_WIDTH 32
  IN1_WIDTH 32
} {
  In0 btn_i
  In1 dsp_0/P
  dout hub_0/sts_data
}

# COUNTER

# Create axis_counter
cell axis_counter cntr_0 {
  AXIS_TDATA_WIDTH 32
} {
  M_AXIS hub_0/S00_AXIS
  aclk clk_i
}

# DDS

# Create port_slicer
cell port_slicer slice_3 {
  DIN_WIDTH 96 DIN_FROM 95 DIN_TO 64
} {
  din hub_0/cfg_data
}

# Create axis_constant
cell axis_constant phase_0 {
  AXIS_TDATA_WIDTH 32
} {
  cfg_data slice_3/dout
  aclk clk_i
}

# Create dds_compiler
cell xilinx.com:ip:dds_compiler dds_0 {
  DDS_CLOCK_RATE 100
  SPURIOUS_FREE_DYNAMIC_RANGE 96
  FREQUENCY_RESOLUTION 0.1
  PHASE_INCREMENT Streaming
  HAS_PHASE_OUT false
  PHASE_WIDTH 30
  OUTPUT_WIDTH 16
} {
  S_AXIS_PHASE phase_0/M_AXIS
  M_AXIS_DATA hub_0/S01_AXIS
  aclk clk_i
}
