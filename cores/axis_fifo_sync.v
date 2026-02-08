
`timescale 1ns / 1ps

module axis_fifo_sync #
(
  parameter integer AXIS_TDATA_WIDTH = 32,
  parameter integer ADDR_WIDTH = 9
)
(
  input  wire                        aclk,
  input  wire                        aresetn,

  output wire [ADDR_WIDTH:0]         count,

  input  wire [AXIS_TDATA_WIDTH-1:0] s_axis_tdata,
  input  wire                        s_axis_tvalid,
  output wire                        s_axis_tready,

  output wire [AXIS_TDATA_WIDTH-1:0] m_axis_tdata,
  output wire                        m_axis_tvalid,
  input  wire                        m_axis_tready
);

  localparam integer BRAM_SIZE = 1 << ADDR_WIDTH;

  reg [AXIS_TDATA_WIDTH-1:0] bram [BRAM_SIZE-1:0];

  reg [ADDR_WIDTH:0] int_count_reg = {(ADDR_WIDTH+1){1'b0}};
  reg [ADDR_WIDTH:0] int_wr_addr_reg = {(ADDR_WIDTH+1){1'b0}};
  reg [ADDR_WIDTH:0] int_rd_addr_reg = {(ADDR_WIDTH+1){1'b0}};

  wire [AXIS_TDATA_WIDTH-1:0] int_data_wire;

  wire [ADDR_WIDTH:0] int_rd_sum_wire, int_wr_sum_wire;
  wire int_valid_wire, int_ready_wire;

  assign count = int_count_reg;

  assign int_wr_sum_wire = int_wr_addr_reg + 1;
  assign int_rd_sum_wire = int_rd_addr_reg + 1;

  assign s_axis_tready = int_wr_addr_reg != {~int_rd_addr_reg[ADDR_WIDTH], int_rd_addr_reg[ADDR_WIDTH-1:0]};
  assign int_valid_wire = int_wr_addr_reg != int_rd_addr_reg;

  always @(posedge aclk)
  begin
    if(~aresetn)
    begin
      int_count_reg <= {(ADDR_WIDTH+1){1'b0}};
    end
    else
    begin
      int_count_reg <= int_wr_addr_reg - int_rd_addr_reg + m_axis_tvalid;
    end
  end

  always @(posedge aclk)
  begin
    if(~aresetn)
    begin
      int_wr_addr_reg <= {(ADDR_WIDTH+1){1'b0}};
    end
    else if(s_axis_tvalid & s_axis_tready)
    begin
      bram[int_wr_addr_reg[ADDR_WIDTH-1:0]] <= s_axis_tdata;
      int_wr_addr_reg <= int_wr_sum_wire;
    end
  end

  always @(posedge aclk)
  begin
    if(~aresetn)
    begin
      int_rd_addr_reg <= {(ADDR_WIDTH+1){1'b0}};
    end
    else if(int_ready_wire & int_valid_wire)
    begin
      int_rd_addr_reg <= int_rd_sum_wire;
    end
  end

  assign int_data_wire = bram[int_rd_addr_reg[ADDR_WIDTH-1:0]];

  output_buffer #(
    .DATA_WIDTH(AXIS_TDATA_WIDTH)
  ) buf_0 (
    .aclk(aclk), .aresetn(aresetn),
    .in_data(int_data_wire), .in_valid(int_valid_wire), .in_ready(int_ready_wire),
    .out_data(m_axis_tdata), .out_valid(m_axis_tvalid), .out_ready(m_axis_tready)
  );

endmodule
