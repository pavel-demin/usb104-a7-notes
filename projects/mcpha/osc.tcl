# scope_0/aresetn and writer_0/aresetn

# Create port_slicer
cell port_slicer slice_0 {
  DIN_WIDTH 2 DIN_FROM 0 DIN_TO 0
}

# scope_0/run_flag

# Create port_slicer
cell port_slicer slice_1 {
  DIN_WIDTH 2 DIN_FROM 1 DIN_TO 1
}

# sel_0/cfg_data

# Create port_slicer
cell port_slicer slice_2 {
  DIN_WIDTH 128 DIN_FROM 0 DIN_TO 0
}

# trig_0/pol_data

# Create port_slicer
cell port_slicer slice_3 {
  DIN_WIDTH 128 DIN_FROM 1 DIN_TO 1
}

# or_0/Op1

# Create port_slicer
cell port_slicer slice_4 {
  DIN_WIDTH 128 DIN_FROM 2 DIN_TO 2
}

# scope_0/pre_data

# Create port_slicer
cell port_slicer slice_5 {
  DIN_WIDTH 128 DIN_FROM 63 DIN_TO 32
}

# scope_0/tot_data

# Create port_slicer
cell port_slicer slice_6 {
  DIN_WIDTH 128 DIN_FROM 95 DIN_TO 64
}

# trig_0/lvl_data

# Create port_slicer
cell port_slicer slice_7 {
  DIN_WIDTH 128 DIN_FROM 127 DIN_TO 96
}

# Create axis_selector
cell axis_selector sel_0 {
  AXIS_TDATA_WIDTH 16
} {
  cfg_data slice_2/dout
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create xlconstant
cell xilinx.com:ip:xlconstant const_0 {
  CONST_WIDTH 16
  CONST_VAL 65535
}

# Create axis_trigger
cell axis_trigger trig_0 {
  AXIS_TDATA_WIDTH 16
  AXIS_TDATA_SIGNED TRUE
} {
  S_AXIS sel_0/M_AXIS
  pol_data slice_3/dout
  msk_data const_0/dout
  lvl_data slice_7/dout
  aclk /pll_0/clk_out1
}

# Create util_vector_logic
cell xilinx.com:ip:util_vector_logic or_0 {
  C_SIZE 1
  C_OPERATION or
} {
  Op1 slice_4/dout
  Op2 trig_0/trg_flag
}

# Create axis_combiner
cell  xilinx.com:ip:axis_combiner comb_0 {
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 2
} {
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create axis_oscilloscope
cell axis_oscilloscope scope_0 {
  AXIS_TDATA_WIDTH 32
  CNTR_WIDTH 17
} {
  S_AXIS comb_0/M_AXIS
  run_flag slice_1/dout
  trg_flag or_0/Res
  pre_data slice_5/dout
  tot_data slice_6/dout
  aclk /pll_0/clk_out1
  aresetn slice_0/dout
}

# Create axis_bram_writer
cell axis_bram_writer writer_0 {
  AXIS_TDATA_WIDTH 32
  BRAM_DATA_WIDTH 32
  BRAM_ADDR_WIDTH 17
} {
  S_AXIS scope_0/M_AXIS
  cfg_data slice_6/dout
  aclk /pll_0/clk_out1
  aresetn slice_0/dout
}

# Create blk_mem_gen
cell xilinx.com:ip:blk_mem_gen bram_0 {
  MEMORY_TYPE True_Dual_Port_RAM
  USE_BRAM_BLOCK Stand_Alone
  USE_BYTE_WRITE_ENABLE true
  BYTE_SIZE 8
  WRITE_WIDTH_A 32
  WRITE_DEPTH_A 100352
  REGISTER_PORTA_OUTPUT_OF_MEMORY_PRIMITIVES false
  REGISTER_PORTB_OUTPUT_OF_MEMORY_PRIMITIVES false
} {
  BRAM_PORTB writer_0/B_BRAM
}
