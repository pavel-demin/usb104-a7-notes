
`timescale 1 ns / 1 ps

module axis_bscan
(
  input  wire        aclk,
  input  wire        aresetn,

  input  wire [31:0] s_axis_tdata,
  input  wire        s_axis_tvalid,
  output wire        s_axis_tready,

  output wire [31:0] m_axis_tdata,
  output wire        m_axis_tvalid,
  input  wire        m_axis_tready
);

  wire int_sel_wire, int_shift_wire;
  wire int_tdi_wire, int_tdo_wire;
  wire int_tck_wire, int_reset_wire;

  wire [31:0] int_tx_tdata_wire;
  wire int_tx_tvalid_wire, int_tx_tready_wire;

  wire [31:0] int_rx_tdata_wire;
  wire int_rx_tvalid_wire, int_rx_tready_wire;

  axis_fifo_async #(
    .AXIS_TDATA_WIDTH(32),
    .ADDR_WIDTH(10)
  ) fifo_tx (
    .s_axis_aclk(aclk),
    .s_axis_aresetn(1'b1),

    .s_axis_tdata(s_axis_tdata),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tready(s_axis_tready),

    .m_axis_aclk(int_tck_wire),
    .m_axis_aresetn(1'b1),

    .m_axis_tdata(int_tx_tdata_wire),
    .m_axis_tvalid(int_tx_tvalid_wire),
    .m_axis_tready(int_tx_tready_wire)
  );

  axis_downsizer #(
    .S_AXIS_TDATA_WIDTH(32),
    .M_AXIS_TDATA_WIDTH(1)
  ) conv_tx (
    .aclk(int_tck_wire),
    .aresetn(int_sel_wire),

    .cfg_data(16'd31),

    .s_axis_tdata(int_tx_tdata_wire),
    .s_axis_tvalid(int_tx_tvalid_wire),
    .s_axis_tready(int_tx_tready_wire),

    .m_axis_tdata(int_tdo_wire),
    .m_axis_tvalid(int_reset_wire),
    .m_axis_tready(int_shift_wire)
  );

  BSCANE2 #(
    .JTAG_CHAIN(1)
  ) bscan_0 (
    .TCK(int_tck_wire),
    .SEL(int_sel_wire),
    .SHIFT(int_shift_wire),
    .TDI(int_tdi_wire),
    .TDO(int_tdo_wire)
  );

  axis_upsizer #(
    .S_AXIS_TDATA_WIDTH(1),
    .M_AXIS_TDATA_WIDTH(32)
  ) conv_rx (
    .aclk(int_tck_wire),
    .aresetn(int_sel_wire & ~int_reset_wire),

    .cfg_data(16'd31),

    .s_axis_tdata(int_tdi_wire),
    .s_axis_tvalid(int_shift_wire),

    .m_axis_tdata(int_rx_tdata_wire),
    .m_axis_tvalid(int_rx_tvalid_wire),
    .m_axis_tready(int_rx_tready_wire)
  );

  axis_fifo_async #(
    .AXIS_TDATA_WIDTH(32),
    .ADDR_WIDTH(10)
  ) fifo_rx (
    .s_axis_aclk(int_tck_wire),
    .s_axis_aresetn(1'b1),

    .s_axis_tdata(int_rx_tdata_wire),
    .s_axis_tvalid(int_rx_tvalid_wire),
    .s_axis_tready(int_rx_tready_wire),

    .m_axis_aclk(aclk),
    .m_axis_aresetn(1'b1),

    .m_axis_tdata(m_axis_tdata),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready(m_axis_tready)
  );

endmodule
