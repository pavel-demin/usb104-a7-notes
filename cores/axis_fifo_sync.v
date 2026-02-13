
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

  reg [ADDR_WIDTH:0] int_count_reg = 0;

  reg [ADDR_WIDTH:0] int_wr_addr0_reg = 0;
  reg [ADDR_WIDTH-1:0] int_wr_addr1_reg = 1;
  reg [ADDR_WIDTH-1:0] int_wr_addr2_reg = 2;

  reg [ADDR_WIDTH:0] int_rd_addr0_reg = 0;
  reg [ADDR_WIDTH-1:0] int_rd_addr1_reg = 1;

  reg int_wr_ready_reg, int_rd_valid_reg;

  wire [ADDR_WIDTH:0] int_wr_sum0_wire, int_rd_sum0_wire;
  wire [ADDR_WIDTH-1:0] int_wr_sum1_wire, int_wr_sum2_wire, int_rd_sum1_wire;

  wire [ADDR_WIDTH-1:0] int_wr_addr0_wire, int_rd_addr0_wire;

  wire int_wr_enbl_wire, int_rd_enbl_wire;

  wire int_wr_ready1_wire, int_wr_ready2_wire;
  wire int_rd_valid0_wire, int_rd_valid1_wire;

  wire int_rd_ready_wire;

  assign count = int_count_reg;

  assign int_wr_sum0_wire = int_wr_addr0_reg + 1'b1;
  assign int_wr_sum1_wire = int_wr_addr1_reg + 1'b1;
  assign int_wr_sum2_wire = int_wr_addr2_reg + 1'b1;

  assign int_rd_sum0_wire = int_rd_addr0_reg + 1'b1;
  assign int_rd_sum1_wire = int_rd_addr1_reg + 1'b1;

  assign int_wr_addr0_wire = int_wr_addr0_reg[ADDR_WIDTH-1:0];
  assign int_rd_addr0_wire = int_rd_addr0_reg[ADDR_WIDTH-1:0];

  assign int_wr_enbl_wire = s_axis_tvalid & int_wr_ready_reg;
  assign int_rd_enbl_wire = int_rd_valid_reg & int_rd_ready_wire;

  assign int_wr_ready1_wire = (int_wr_addr1_reg != int_rd_addr0_wire);
  assign int_wr_ready2_wire = (int_wr_addr2_reg != int_rd_addr0_wire) | ~int_wr_enbl_wire;

  assign int_rd_valid0_wire = (int_rd_addr0_wire != int_wr_addr0_wire);
  assign int_rd_valid1_wire = (int_rd_addr1_reg != int_wr_addr0_wire) | ~int_rd_enbl_wire;

  always @(posedge aclk)
  begin
    if(~aresetn)
    begin
      int_count_reg <= 0;
      int_wr_ready_reg <= 1'b0;
      int_rd_valid_reg <= 1'b0;
    end
    else
    begin
      int_count_reg <= int_wr_addr0_reg - int_rd_addr0_reg + m_axis_tvalid;
      int_wr_ready_reg <= int_wr_ready1_wire & int_wr_ready2_wire;
      int_rd_valid_reg <= int_rd_valid0_wire & int_rd_valid1_wire;
    end
  end

  always @(posedge aclk)
  begin
    if(~aresetn)
    begin
      int_wr_addr0_reg <= 0;
      int_wr_addr1_reg <= 1;
      int_wr_addr2_reg <= 2;
    end
    else if(int_wr_enbl_wire)
    begin
      bram[int_wr_addr0_wire] <= s_axis_tdata;
      int_wr_addr0_reg <= int_wr_sum0_wire;
      int_wr_addr1_reg <= int_wr_sum1_wire;
      int_wr_addr2_reg <= int_wr_sum2_wire;
    end
  end

  always @(posedge aclk)
  begin
    if(~aresetn)
    begin
      int_rd_addr0_reg <= 0;
      int_rd_addr1_reg <= 1;
    end
    else if(int_rd_enbl_wire)
    begin
      int_rd_addr0_reg <= int_rd_sum0_wire;
      int_rd_addr1_reg <= int_rd_sum1_wire;
    end
  end

  output_buffer #(
    .DATA_WIDTH(AXIS_TDATA_WIDTH)
  ) buf_0 (
    .aclk(aclk), .aresetn(aresetn),
    .in_data(bram[int_rd_addr0_wire]), .in_valid(int_rd_valid_reg), .in_ready(int_rd_ready_wire),
    .out_data(m_axis_tdata), .out_valid(m_axis_tvalid), .out_ready(m_axis_tready)
  );

  assign s_axis_tready = int_wr_ready_reg;

endmodule
