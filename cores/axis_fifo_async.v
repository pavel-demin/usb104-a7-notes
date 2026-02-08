
`timescale 1ns / 1ps

module axis_fifo_async #
(
  parameter integer AXIS_TDATA_WIDTH = 32,
  parameter integer ADDR_WIDTH = 9
)
(
  input  wire                        s_axis_aclk,
  input  wire                        s_axis_aresetn,

  input  wire [AXIS_TDATA_WIDTH-1:0] s_axis_tdata,
  input  wire                        s_axis_tvalid,
  output wire                        s_axis_tready,

  input  wire                        m_axis_aclk,
  input  wire                        m_axis_aresetn,

  output wire [AXIS_TDATA_WIDTH-1:0] m_axis_tdata,
  output wire                        m_axis_tvalid,
  input  wire                        m_axis_tready
);

  localparam integer BRAM_SIZE = 1 << ADDR_WIDTH;

  reg [AXIS_TDATA_WIDTH-1:0] bram [BRAM_SIZE-1:0];

  reg [ADDR_WIDTH:0] int_wr_addr_reg = {(ADDR_WIDTH+1){1'b0}};
  reg [ADDR_WIDTH:0] int_rd_addr_reg = {(ADDR_WIDTH+1){1'b0}};

  reg [ADDR_WIDTH:0] int_wr_gray_reg = {(ADDR_WIDTH+1){1'b0}};
  reg [ADDR_WIDTH:0] int_rd_gray_reg = {(ADDR_WIDTH+1){1'b0}};

  reg [ADDR_WIDTH:0] int_wr_cdc0_reg = {(ADDR_WIDTH+1){1'b0}};
  reg [ADDR_WIDTH:0] int_wr_cdc1_reg = {(ADDR_WIDTH+1){1'b0}};
  reg [ADDR_WIDTH:0] int_wr_cdc2_reg = {(ADDR_WIDTH+1){1'b0}};
  reg [ADDR_WIDTH:0] int_wr_cdc3_reg = {(ADDR_WIDTH+1){1'b0}};

  reg [ADDR_WIDTH:0] int_rd_cdc0_reg = {(ADDR_WIDTH+1){1'b0}};
  reg [ADDR_WIDTH:0] int_rd_cdc1_reg = {(ADDR_WIDTH+1){1'b0}};
  reg [ADDR_WIDTH:0] int_rd_cdc2_reg = {(ADDR_WIDTH+1){1'b0}};
  reg [ADDR_WIDTH:0] int_rd_cdc3_reg = {(ADDR_WIDTH+1){1'b0}};

  wire [AXIS_TDATA_WIDTH-1:0] int_data_wire;
  wire [ADDR_WIDTH:0] int_rd_sum_wire, int_wr_sum_wire;
  wire int_valid_wire, int_ready_wire;

  assign int_wr_sum_wire = int_wr_addr_reg + 1;
  assign int_rd_sum_wire = int_rd_addr_reg + 1;

  assign s_axis_tready = int_wr_cdc3_reg != {~int_wr_gray_reg[ADDR_WIDTH:ADDR_WIDTH-1], int_wr_gray_reg[ADDR_WIDTH-2:0]};
  assign int_valid_wire = int_rd_cdc3_reg != int_rd_gray_reg;

  always @(posedge s_axis_aclk)
  begin
    if(~s_axis_aresetn)
    begin
      int_wr_addr_reg <= {(ADDR_WIDTH+1){1'b0}};
      int_wr_gray_reg <= {(ADDR_WIDTH+1){1'b0}};
      int_wr_cdc0_reg <= {(ADDR_WIDTH+1){1'b0}};
      int_wr_cdc1_reg <= {(ADDR_WIDTH+1){1'b0}};
      int_wr_cdc2_reg <= {(ADDR_WIDTH+1){1'b0}};
      int_wr_cdc3_reg <= {(ADDR_WIDTH+1){1'b0}};
    end
    else
    begin
      if(s_axis_tvalid & s_axis_tready)
      begin
        bram[int_wr_addr_reg[ADDR_WIDTH-1:0]] <= s_axis_tdata;
        int_wr_addr_reg <= int_wr_sum_wire;
        int_wr_gray_reg <= {int_wr_sum_wire[ADDR_WIDTH], int_wr_sum_wire[ADDR_WIDTH-1:0] ^ int_wr_sum_wire[ADDR_WIDTH:1]};
      end
      int_wr_cdc0_reg <= int_rd_gray_reg;
      int_wr_cdc1_reg <= int_wr_cdc0_reg;
      int_wr_cdc2_reg <= int_wr_cdc1_reg;
      int_wr_cdc3_reg <= int_wr_cdc2_reg;
    end
  end

  always @(posedge m_axis_aclk)
  begin
    if(~m_axis_aresetn)
    begin
      int_rd_addr_reg <= {(ADDR_WIDTH+1){1'b0}};
      int_rd_gray_reg <= {(ADDR_WIDTH+1){1'b0}};
      int_rd_cdc0_reg <= {(ADDR_WIDTH+1){1'b0}};
      int_rd_cdc1_reg <= {(ADDR_WIDTH+1){1'b0}};
      int_rd_cdc2_reg <= {(ADDR_WIDTH+1){1'b0}};
      int_rd_cdc3_reg <= {(ADDR_WIDTH+1){1'b0}};
    end
    else
    begin
      if(int_ready_wire & int_valid_wire)
      begin
        int_rd_addr_reg <= int_rd_sum_wire;
        int_rd_gray_reg <= {int_rd_sum_wire[ADDR_WIDTH], int_rd_sum_wire[ADDR_WIDTH-1:0] ^ int_rd_sum_wire[ADDR_WIDTH:1]};
      end
      int_rd_cdc0_reg <= int_wr_gray_reg;
      int_rd_cdc1_reg <= int_rd_cdc0_reg;
      int_rd_cdc2_reg <= int_rd_cdc1_reg;
      int_rd_cdc3_reg <= int_rd_cdc2_reg;
    end
  end

  assign int_data_wire = bram[int_rd_addr_reg[ADDR_WIDTH-1:0]];

  output_buffer #(
    .DATA_WIDTH(AXIS_TDATA_WIDTH)
  ) buf_0 (
    .aclk(m_axis_aclk), .aresetn(m_axis_aresetn),
    .in_data(int_data_wire), .in_valid(int_valid_wire), .in_ready(int_ready_wire),
    .out_data(m_axis_tdata), .out_valid(m_axis_tvalid), .out_ready(m_axis_tready)
  );

endmodule
