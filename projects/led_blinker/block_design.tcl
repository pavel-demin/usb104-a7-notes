# Create c_counter_binary
cell xilinx.com:ip:c_counter_binary cntr_0 {
  OUTPUT_WIDTH 32
} {
  CLK clk_i
}

# Create port_slicer
cell port_slicer slice_0 {
  DIN_WIDTH 32 DIN_FROM 26 DIN_TO 26
} {
  din cntr_0/Q
  dout led_o
}
