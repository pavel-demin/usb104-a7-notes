
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

  reg [ADDR_WIDTH-1:0] int_wr_addr0_reg = 0;
  reg [ADDR_WIDTH-1:0] int_wr_addr1_reg = 1;
  reg [ADDR_WIDTH-1:0] int_wr_addr2_reg = 2;

  reg [ADDR_WIDTH-1:0] int_rd_addr0_reg = 0;
  reg [ADDR_WIDTH-1:0] int_rd_addr1_reg = 1;

  reg [ADDR_WIDTH-1:0] int_wr_gray0_reg = 0;
  reg [ADDR_WIDTH-1:0] int_wr_gray1_reg = 1;
  reg [ADDR_WIDTH-1:0] int_wr_gray2_reg = 3;

  reg [ADDR_WIDTH-1:0] int_rd_gray0_reg = 0;
  reg [ADDR_WIDTH-1:0] int_rd_gray1_reg = 1;

  reg int_wr_ready_reg, int_rd_valid_reg;

  wire [ADDR_WIDTH-1:0] int_wr_sum0_wire, int_rd_sum0_wire;
  wire [ADDR_WIDTH-1:0] int_wr_sum1_wire, int_wr_sum2_wire, int_rd_sum1_wire;

  wire [ADDR_WIDTH-1:0] int_wr_addr0_wire, int_rd_addr0_wire;

  wire [ADDR_WIDTH-1:0] int_wr_gray0_wire, int_rd_gray0_wire;

  wire int_wr_enbl_wire, int_rd_enbl_wire;

  wire int_wr_ready1_wire, int_wr_ready2_wire;
  wire int_rd_valid0_wire, int_rd_valid1_wire;

  wire int_rd_ready_wire;

  assign int_wr_sum0_wire = int_wr_addr0_reg + 1'b1;
  assign int_wr_sum1_wire = int_wr_addr1_reg + 1'b1;
  assign int_wr_sum2_wire = int_wr_addr2_reg + 1'b1;

  assign int_rd_sum0_wire = int_rd_addr0_reg + 1'b1;
  assign int_rd_sum1_wire = int_rd_addr1_reg + 1'b1;

  assign int_wr_addr0_wire = int_wr_addr0_reg[ADDR_WIDTH-1:0];
  assign int_rd_addr0_wire = int_rd_addr0_reg[ADDR_WIDTH-1:0];

  assign int_wr_enbl_wire = s_axis_tvalid & int_wr_ready_reg;
  assign int_rd_enbl_wire = int_rd_valid_reg & int_rd_ready_wire;

  assign int_wr_ready1_wire = (int_wr_gray1_reg != int_rd_gray0_wire);
  assign int_wr_ready2_wire = (int_wr_gray2_reg != int_rd_gray0_wire) | ~int_wr_enbl_wire;

  assign int_rd_valid0_wire = (int_rd_gray0_reg != int_wr_gray0_wire);
  assign int_rd_valid1_wire = (int_rd_gray1_reg != int_wr_gray0_wire) | ~int_rd_enbl_wire;

  cdc #(
    .DATA_WIDTH(ADDR_WIDTH)
  ) cdc_wr (
    .aclk(s_axis_aclk),
    .aresetn(s_axis_aresetn),
    .in_data(int_rd_gray0_reg),
    .out_data(int_rd_gray0_wire)
  );

  always @(posedge s_axis_aclk)
  begin
    if(~s_axis_aresetn)
    begin
      int_wr_ready_reg <= 1'b0;
    end
    else
    begin
      int_wr_ready_reg <= int_wr_ready1_wire & int_wr_ready2_wire;
    end
  end

  always @(posedge s_axis_aclk)
  begin
    if(~s_axis_aresetn)
    begin
      int_wr_addr0_reg <= 0;
      int_wr_addr1_reg <= 1;
      int_wr_addr2_reg <= 2;
      int_wr_gray0_reg <= 0;
      int_wr_gray1_reg <= 1;
      int_wr_gray2_reg <= 3;
    end
    else if(int_wr_enbl_wire)
    begin
      bram[int_wr_addr0_wire] <= s_axis_tdata;
      int_wr_addr0_reg <= int_wr_sum0_wire;
      int_wr_addr1_reg <= int_wr_sum1_wire;
      int_wr_addr2_reg <= int_wr_sum2_wire;
      int_wr_gray0_reg <= {int_wr_sum0_wire[ADDR_WIDTH], int_wr_sum0_wire[ADDR_WIDTH-1:0] ^ int_wr_sum0_wire[ADDR_WIDTH-1:1]};
      int_wr_gray1_reg <= {int_wr_sum1_wire[ADDR_WIDTH], int_wr_sum1_wire[ADDR_WIDTH-1:0] ^ int_wr_sum1_wire[ADDR_WIDTH-1:1]};
      int_wr_gray2_reg <= {int_wr_sum2_wire[ADDR_WIDTH], int_wr_sum2_wire[ADDR_WIDTH-1:0] ^ int_wr_sum2_wire[ADDR_WIDTH-1:1]};
    end
  end

  cdc #(
    .DATA_WIDTH(ADDR_WIDTH)
  ) cdc_rd (
    .aclk(m_axis_aclk),
    .aresetn(m_axis_aresetn),
    .in_data(int_wr_gray0_reg),
    .out_data(int_wr_gray0_wire)
  );

  always @(posedge m_axis_aclk)
  begin
    if(~m_axis_aresetn)
    begin
      int_rd_valid_reg <= 1'b0;
    end
    else
    begin
      int_rd_valid_reg <= int_rd_valid0_wire & int_rd_valid1_wire;
    end
  end

  always @(posedge m_axis_aclk)
  begin
    if(~m_axis_aresetn)
    begin
      int_rd_addr0_reg <= 0;
      int_rd_addr1_reg <= 1;
      int_rd_gray0_reg <= 0;
      int_rd_gray1_reg <= 1;
    end
    else if(int_rd_enbl_wire)
    begin
      int_rd_addr0_reg <= int_rd_sum0_wire;
      int_rd_addr1_reg <= int_rd_sum1_wire;
      int_rd_gray0_reg <= {int_rd_sum0_wire[ADDR_WIDTH], int_rd_sum0_wire[ADDR_WIDTH-1:0] ^ int_rd_sum0_wire[ADDR_WIDTH-1:1]};
      int_rd_gray1_reg <= {int_rd_sum1_wire[ADDR_WIDTH], int_rd_sum1_wire[ADDR_WIDTH-1:0] ^ int_rd_sum1_wire[ADDR_WIDTH-1:1]};
    end
  end

  output_buffer #(
    .DATA_WIDTH(AXIS_TDATA_WIDTH)
  ) buf_0 (
    .aclk(m_axis_aclk), .aresetn(m_axis_aresetn),
    .in_data(bram[int_rd_addr0_wire]), .in_valid(int_rd_valid_reg), .in_ready(int_rd_ready_wire),
    .out_data(m_axis_tdata), .out_valid(m_axis_tvalid), .out_ready(m_axis_tready)
  );

  assign s_axis_tready = int_wr_ready_reg;

endmodule
