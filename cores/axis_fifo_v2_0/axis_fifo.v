
`timescale 1 ns / 1 ps

module axis_fifo #
(
  parameter integer S_AXIS_TDATA_WIDTH = 32,
  parameter integer M_AXIS_TDATA_WIDTH = 32,
  parameter integer WRITE_DEPTH = 512,
  parameter         ALWAYS_READY = "FALSE",
  parameter         ALWAYS_VALID = "FALSE"
)
(
  // System signals
  input  wire                          aclk,
  input  wire                          aresetn,

  // FIFO status
  output wire [15:0]                   write_count,
  output wire [15:0]                   read_count,

  // Slave side
  input  wire [S_AXIS_TDATA_WIDTH-1:0] s_axis_tdata,
  input  wire                          s_axis_tvalid,
  output wire                          s_axis_tready,

  // Master side
  output wire [M_AXIS_TDATA_WIDTH-1:0] m_axis_tdata,
  output wire                          m_axis_tvalid,
  input  wire                          m_axis_tready
);

  function integer clogb2 (input integer value);
    for(clogb2 = 0; value > 0; clogb2 = clogb2 + 1) value = value >> 1;
  endfunction

  localparam integer WRITE_COUNT_WIDTH = clogb2(WRITE_DEPTH - 1) + 1;
  localparam integer READ_COUNT_WIDTH = clogb2(WRITE_DEPTH * S_AXIS_TDATA_WIDTH / M_AXIS_TDATA_WIDTH - 1) + 1;

  wire [READ_COUNT_WIDTH-1:0] int_rcount_wire;
  wire [M_AXIS_TDATA_WIDTH-1:0] int_data_wire [2:0];
  wire [3:0] int_valid_wire, int_ready_wire;
  wire int_empty_wire, int_full_wire;

  xpm_fifo_sync #(
    .WRITE_DATA_WIDTH(S_AXIS_TDATA_WIDTH),
    .FIFO_WRITE_DEPTH(WRITE_DEPTH),
    .READ_DATA_WIDTH(M_AXIS_TDATA_WIDTH),
    .READ_MODE("std"),
    .FIFO_READ_LATENCY(1),
    .FIFO_MEMORY_TYPE("block"),
    .USE_ADV_FEATURES("0404"),
    .WR_DATA_COUNT_WIDTH(WRITE_COUNT_WIDTH),
    .RD_DATA_COUNT_WIDTH(READ_COUNT_WIDTH)
  ) fifo_0 (
    .empty(int_empty_wire),
    .full(int_full_wire),
    .wr_data_count(write_count),
    .rd_data_count(int_rcount_wire),
    .rst(~aresetn),
    .wr_clk(aclk),
    .wr_en(s_axis_tvalid),
    .din(s_axis_tdata),
    .rd_en(int_ready_wire[0]),
    .dout(int_data_wire[0])
  );

  assign read_count = int_rcount_wire + int_valid_wire[1] + int_valid_wire[2] + int_valid_wire[3];

  assign int_valid_wire[0] = ~int_empty_wire;

  assign int_ready_wire[3] = m_axis_tready;

  generate
    if(ALWAYS_READY == "TRUE")
    begin : READY_INPUT
      assign s_axis_tready = 1'b1;
    end
    else
    begin : BLOCKING_INPUT
      assign s_axis_tready = ~int_full_wire;
    end
  endgenerate

  generate
    if(ALWAYS_VALID == "TRUE")
    begin : VALID_OUTPUT
      assign m_axis_tdata = int_valid_wire[3] ? int_data_wire[2] : {(M_AXIS_TDATA_WIDTH){1'b0}};
      assign m_axis_tvalid = 1'b1;
    end
    else
    begin : BLOCKING_OUTPUT
      assign m_axis_tdata = int_data_wire[2];
      assign m_axis_tvalid = int_valid_wire[3];
    end
  endgenerate

  output_buffer #(
    .DATA_WIDTH(0)
  ) buf_0 (
    .aclk(aclk), .aresetn(aresetn),
    .in_valid(int_valid_wire[0]), .in_ready(int_ready_wire[0]),
    .out_valid(int_valid_wire[1]), .out_ready(int_ready_wire[1])
  );

  input_buffer #(
    .DATA_WIDTH(M_AXIS_TDATA_WIDTH)
  ) buf_1 (
    .aclk(aclk), .aresetn(aresetn),
    .in_data(int_data_wire[0]), .in_valid(int_valid_wire[1]), .in_ready(int_ready_wire[1]),
    .out_data(int_data_wire[1]), .out_valid(int_valid_wire[2]), .out_ready(int_ready_wire[2])
  );

  output_buffer #(
    .DATA_WIDTH(M_AXIS_TDATA_WIDTH)
  ) buf_2 (
    .aclk(aclk), .aresetn(aresetn),
    .in_data(int_data_wire[1]), .in_valid(int_valid_wire[2]), .in_ready(int_ready_wire[2]),
    .out_data(int_data_wire[2]), .out_valid(int_valid_wire[3]), .out_ready(int_ready_wire[3])
  );

endmodule
