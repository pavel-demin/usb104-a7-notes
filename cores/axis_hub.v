
`timescale 1 ns / 1 ps

module axis_hub #
(
  parameter integer CFG_DATA_WIDTH = 1024,
  parameter integer STS_DATA_WIDTH = 1024
)
(
  input  wire                      aclk,
  input  wire                      aresetn,

  input  wire [31:0]               s_axis_tdata,
  input  wire                      s_axis_tvalid,
  output wire                      s_axis_tready,

  output wire [31:0]               m_axis_tdata,
  output wire                      m_axis_tvalid,
  input  wire                      m_axis_tready,

  output wire [CFG_DATA_WIDTH-1:0] cfg_data,

  input  wire [STS_DATA_WIDTH-1:0] sts_data,

  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b00_bram CLK" *)
  output wire                      b00_bram_clk,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b00_bram RST" *)
  output wire                      b00_bram_rst,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b00_bram EN" *)
  output wire                      b00_bram_en,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b00_bram WE" *)
  output wire [3:0]                b00_bram_we,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b00_bram ADDR" *)
  output wire [17:0]               b00_bram_addr,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b00_bram DIN" *)
  output wire [31:0]               b00_bram_wdata,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b00_bram DOUT" *)
  input  wire [31:0]               b00_bram_rdata,

  input  wire [31:0]               s00_axis_tdata,
  input  wire                      s00_axis_tvalid,
  output wire                      s00_axis_tready,

  output wire [31:0]               m00_axis_tdata,
  output wire                      m00_axis_tvalid,
  input  wire                      m00_axis_tready,

  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b01_bram CLK" *)
  output wire                      b01_bram_clk,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b01_bram RST" *)
  output wire                      b01_bram_rst,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b01_bram EN" *)
  output wire                      b01_bram_en,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b01_bram WE" *)
  output wire [3:0]                b01_bram_we,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b01_bram ADDR" *)
  output wire [17:0]               b01_bram_addr,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b01_bram DIN" *)
  output wire [31:0]               b01_bram_wdata,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b01_bram DOUT" *)
  input  wire [31:0]               b01_bram_rdata,

  input  wire [31:0]               s01_axis_tdata,
  input  wire                      s01_axis_tvalid,
  output wire                      s01_axis_tready,

  output wire [31:0]               m01_axis_tdata,
  output wire                      m01_axis_tvalid,
  input  wire                      m01_axis_tready,

  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b02_bram CLK" *)
  output wire                      b02_bram_clk,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b02_bram RST" *)
  output wire                      b02_bram_rst,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b02_bram EN" *)
  output wire                      b02_bram_en,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b02_bram WE" *)
  output wire [3:0]                b02_bram_we,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b02_bram ADDR" *)
  output wire [17:0]               b02_bram_addr,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b02_bram DIN" *)
  output wire [31:0]               b02_bram_wdata,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b02_bram DOUT" *)
  input  wire [31:0]               b02_bram_rdata,

  input  wire [31:0]               s02_axis_tdata,
  input  wire                      s02_axis_tvalid,
  output wire                      s02_axis_tready,

  output wire [31:0]               m02_axis_tdata,
  output wire                      m02_axis_tvalid,
  input  wire                      m02_axis_tready,

  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b03_bram CLK" *)
  output wire                      b03_bram_clk,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b03_bram RST" *)
  output wire                      b03_bram_rst,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b03_bram EN" *)
  output wire                      b03_bram_en,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b03_bram WE" *)
  output wire [3:0]                b03_bram_we,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b03_bram ADDR" *)
  output wire [17:0]               b03_bram_addr,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b03_bram DIN" *)
  output wire [31:0]               b03_bram_wdata,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b03_bram DOUT" *)
  input  wire [31:0]               b03_bram_rdata,

  input  wire [31:0]               s03_axis_tdata,
  input  wire                      s03_axis_tvalid,
  output wire                      s03_axis_tready,

  output wire [31:0]               m03_axis_tdata,
  output wire                      m03_axis_tvalid,
  input  wire                      m03_axis_tready,

  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b04_bram CLK" *)
  output wire                      b04_bram_clk,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b04_bram RST" *)
  output wire                      b04_bram_rst,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b04_bram EN" *)
  output wire                      b04_bram_en,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b04_bram WE" *)
  output wire [3:0]                b04_bram_we,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b04_bram ADDR" *)
  output wire [17:0]               b04_bram_addr,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b04_bram DIN" *)
  output wire [31:0]               b04_bram_wdata,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b04_bram DOUT" *)
  input  wire [31:0]               b04_bram_rdata,

  input  wire [31:0]               s04_axis_tdata,
  input  wire                      s04_axis_tvalid,
  output wire                      s04_axis_tready,

  output wire [31:0]               m04_axis_tdata,
  output wire                      m04_axis_tvalid,
  input  wire                      m04_axis_tready,

  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b05_bram CLK" *)
  output wire                      b05_bram_clk,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b05_bram RST" *)
  output wire                      b05_bram_rst,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b05_bram EN" *)
  output wire                      b05_bram_en,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b05_bram WE" *)
  output wire [3:0]                b05_bram_we,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b05_bram ADDR" *)
  output wire [17:0]               b05_bram_addr,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b05_bram DIN" *)
  output wire [31:0]               b05_bram_wdata,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 b05_bram DOUT" *)
  input  wire [31:0]               b05_bram_rdata,

  input  wire [31:0]               s05_axis_tdata,
  input  wire                      s05_axis_tvalid,
  output wire                      s05_axis_tready,

  output wire [31:0]               m05_axis_tdata,
  output wire                      m05_axis_tvalid,
  input  wire                      m05_axis_tready
);

  localparam integer HUB_SIZE = 6;
  localparam integer MUX_SIZE = HUB_SIZE + 2;
  localparam integer CFG_SIZE = CFG_DATA_WIDTH / 32;
  localparam integer CFG_WIDTH = CFG_SIZE > 1 ? $clog2(CFG_SIZE) : 1;
  localparam integer STS_SIZE = STS_DATA_WIDTH / 32;
  localparam integer STS_WIDTH = STS_SIZE > 1 ? $clog2(STS_SIZE) : 1;

  reg [9:0] int_awcntr_reg = 10'd0;
  reg [9:0] int_arcntr_reg = 10'd0;

  wire s_axis_awvalid, s_axis_wvalid, s_axis_arvalid;

  wire int_awvalid_wire, int_awready_wire;
  wire int_wvalid_wire, int_wready_wire;
  wire int_arvalid_wire, int_arready_wire;
  wire int_rvalid_wire, int_rready_wire;

  wire [9:0] int_awlen_wire;
  wire [20:0] int_awaddr_wire;

  wire int_wlast_wire;
  wire [31:0] int_wdata_wire;

  wire [9:0] int_arlen_wire;
  wire [20:0] int_araddr_wire;

  wire int_rlast_wire;
  wire [31:0] int_rdata_wire [MUX_SIZE-1:0];

  wire [31:0] int_sdata_wire [HUB_SIZE-1:0];
  wire [31:0] int_mdata_wire [HUB_SIZE-1:0];
  wire [HUB_SIZE-1:0] int_svalid_wire, int_sready_wire;
  wire [HUB_SIZE-1:0] int_mvalid_wire, int_mready_wire;

  wire [31:0] int_bdata_wire [HUB_SIZE-1:0];

  wire [17:0] int_waddr_wire;
  wire [17:0] int_raddr_wire;

  wire [31:0] int_cfg_mux [CFG_SIZE-1:0];
  wire [31:0] int_sts_mux [STS_SIZE-1:0];

  wire [31:0] int_rdata_mux [MUX_SIZE-1:0];
  wire [MUX_SIZE-1:0] int_wsel_wire, int_rsel_wire;

  wire [HUB_SIZE-1:0] int_bsel_wire;

  wire [CFG_SIZE-1:0] int_ce_wire;
  wire int_we_wire, int_re_wire;

  genvar j, k;

  assign s_axis_awvalid = s_axis_tvalid & s_axis_tdata[31];
  assign s_axis_wvalid = s_axis_tvalid & ~s_axis_awready;
  assign s_axis_arvalid = s_axis_tvalid & ~s_axis_tdata[31] & s_axis_awready;

  assign int_awready_wire = int_wvalid_wire & int_wlast_wire;
  assign int_wready_wire = int_awvalid_wire;
  assign int_wlast_wire = int_awcntr_reg == int_awlen_wire;

  assign int_arready_wire = int_rready_wire & int_rlast_wire;
  assign int_rvalid_wire = int_arvalid_wire;
  assign int_rlast_wire = int_arcntr_reg == int_arlen_wire;

  assign int_we_wire = int_awvalid_wire & int_wvalid_wire;
  assign int_re_wire = int_rready_wire & int_arvalid_wire;

  assign int_waddr_wire = int_awaddr_wire[17:0] + int_awcntr_reg;
  assign int_raddr_wire = int_araddr_wire[17:0] + int_arcntr_reg;

  assign int_rdata_wire[0] = int_rdata_mux[int_araddr_wire[20:18]];

  assign int_rdata_mux[0] = int_cfg_mux[int_raddr_wire[CFG_WIDTH-1:0]];
  assign int_rdata_mux[1] = int_sts_mux[int_raddr_wire[STS_WIDTH-1:0]];

  generate
    for(j = 0; j < HUB_SIZE; j = j + 1)
    begin : MUXES
      assign int_rdata_mux[j+2] = int_svalid_wire[j] ? int_sdata_wire[j] : 32'd0;
      assign int_rdata_wire[j+2] = int_bsel_wire[j] ? int_bdata_wire[j] : 32'd0;
      assign int_mdata_wire[j] = int_wdata_wire;
      assign int_mvalid_wire[j] = int_wsel_wire[j+2];
      assign int_sready_wire[j] = int_rsel_wire[j+2];
    end
  endgenerate

  generate
    for(j = 0; j < MUX_SIZE; j = j + 1)
    begin : SELECTS
      assign int_wsel_wire[j] = int_we_wire & (int_awaddr_wire[20:18] == j);
      assign int_rsel_wire[j] = int_re_wire & (int_araddr_wire[20:18] == j);
    end
  endgenerate

  generate
    for(j = 0; j < CFG_SIZE; j = j + 1)
    begin : CFG_WORDS
      assign int_cfg_mux[j] = cfg_data[j*32+31:j*32];
      assign int_ce_wire[j] = int_wsel_wire[0] & (int_waddr_wire[CFG_WIDTH-1:0] == j);
      for(k = 0; k < 32; k = k + 1)
      begin : CFG_BITS
        FDRE #(
          .INIT(1'b0)
        ) FDRE_inst (
          .CE(int_ce_wire[j]),
          .C(aclk),
          .R(~aresetn),
          .D(int_wdata_wire[k]),
          .Q(cfg_data[j*32 + k])
        );
      end
    end
  endgenerate

  generate
    for(j = 0; j < STS_SIZE; j = j + 1)
    begin : STS_WORDS
      assign int_sts_mux[j] = sts_data[j*32+31:j*32];
    end
  endgenerate

  always @(posedge aclk)
  begin
    if(~aresetn | (int_awvalid_wire & int_awready_wire))
    begin
      int_awcntr_reg <= 10'd0;
    end
    else if(~int_wlast_wire & int_we_wire)
    begin
      int_awcntr_reg <= int_awcntr_reg + 1'b1;
    end

    if(~aresetn | (int_arvalid_wire & int_arready_wire))
    begin
      int_arcntr_reg <= 10'd0;
    end
    else if(~int_rlast_wire & int_re_wire)
    begin
      int_arcntr_reg <= int_arcntr_reg + 1'b1;
    end
  end

  input_buffer #(
    .DATA_WIDTH(31)
  ) buf_0 (
    .aclk(aclk), .aresetn(aresetn),
    .in_data(s_axis_tdata[30:0]),
    .in_valid(s_axis_awvalid), .in_ready(s_axis_awready),
    .out_data({int_awlen_wire, int_awaddr_wire}),
    .out_valid(int_awvalid_wire), .out_ready(int_awready_wire)
  );

  input_buffer #(
    .DATA_WIDTH(32)
  ) buf_1 (
    .aclk(aclk), .aresetn(aresetn),
    .in_data(s_axis_tdata),
    .in_valid(s_axis_wvalid), .in_ready(s_axis_wready),
    .out_data(int_wdata_wire),
    .out_valid(int_wvalid_wire), .out_ready(int_wready_wire)
  );

  input_buffer #(
    .DATA_WIDTH(31)
  ) buf_2 (
    .aclk(aclk), .aresetn(aresetn),
    .in_data(s_axis_tdata[30:0]),
    .in_valid(s_axis_arvalid), .in_ready(s_axis_arready),
    .out_data({int_arlen_wire, int_araddr_wire}),
    .out_valid(int_arvalid_wire), .out_ready(int_arready_wire)
  );

  output_buffer #(
    .DATA_WIDTH(HUB_SIZE + 32)
  ) buf_3 (
    .aclk(aclk), .aresetn(aresetn),
    .in_data({int_rsel_wire[MUX_SIZE-1:2] & ~int_svalid_wire, int_rdata_wire[0]}),
    .in_valid(int_rvalid_wire), .in_ready(int_rready_wire),
    .out_data({int_bsel_wire, int_rdata_wire[1]}),
    .out_valid(m_axis_tvalid), .out_ready(m_axis_tready)
  );

  assign s_axis_tready = s_axis_awready ? s_axis_tdata[31] | s_axis_arready : s_axis_wready;

  assign m_axis_tdata = int_rdata_wire[1] | int_rdata_wire[2] | int_rdata_wire[3] | int_rdata_wire[4] | int_rdata_wire[5] | int_rdata_wire[6] | int_rdata_wire[7];

  assign int_bdata_wire[0] = b00_bram_rdata;
  assign b00_bram_clk = aclk;
  assign b00_bram_rst = ~aresetn;
  assign b00_bram_en = int_rsel_wire[2] | int_wsel_wire[2];
  assign b00_bram_we = int_wsel_wire[2] ? 4'd15 : 4'd0;
  assign b00_bram_addr = int_we_wire ? int_waddr_wire : int_raddr_wire;
  assign b00_bram_wdata = int_wdata_wire;

  assign int_sdata_wire[0] = s00_axis_tdata;
  assign int_svalid_wire[0] = s00_axis_tvalid;
  assign s00_axis_tready = int_sready_wire[0];

  inout_buffer #(
    .DATA_WIDTH(32)
  ) mbuf_0 (
    .aclk(aclk), .aresetn(aresetn),
    .in_data(int_mdata_wire[0]), .in_valid(int_mvalid_wire[0]), .in_ready(int_mready_wire[0]),
    .out_data(m00_axis_tdata), .out_valid(m00_axis_tvalid), .out_ready(m00_axis_tready)
  );

  assign int_bdata_wire[1] = b01_bram_rdata;
  assign b01_bram_clk = aclk;
  assign b01_bram_rst = ~aresetn;
  assign b01_bram_en = int_rsel_wire[3] | int_wsel_wire[3];
  assign b01_bram_we = int_wsel_wire[3] ? 4'd15 : 4'd0;
  assign b01_bram_addr = int_we_wire ? int_waddr_wire : int_raddr_wire;
  assign b01_bram_wdata = int_wdata_wire;

  assign int_sdata_wire[1] = s01_axis_tdata;
  assign int_svalid_wire[1] = s01_axis_tvalid;
  assign s01_axis_tready = int_sready_wire[1];

  inout_buffer #(
    .DATA_WIDTH(32)
  ) mbuf_1 (
    .aclk(aclk), .aresetn(aresetn),
    .in_data(int_mdata_wire[1]), .in_valid(int_mvalid_wire[1]), .in_ready(int_mready_wire[1]),
    .out_data(m01_axis_tdata), .out_valid(m01_axis_tvalid), .out_ready(m01_axis_tready)
  );

  assign int_bdata_wire[2] = b02_bram_rdata;
  assign b02_bram_clk = aclk;
  assign b02_bram_rst = ~aresetn;
  assign b02_bram_en = int_rsel_wire[4] | int_wsel_wire[4];
  assign b02_bram_we = int_wsel_wire[4] ? 4'd15 : 4'd0;
  assign b02_bram_addr = int_we_wire ? int_waddr_wire : int_raddr_wire;
  assign b02_bram_wdata = int_wdata_wire;

  assign int_sdata_wire[2] = s02_axis_tdata;
  assign int_svalid_wire[2] = s02_axis_tvalid;
  assign s02_axis_tready = int_sready_wire[2];

  inout_buffer #(
    .DATA_WIDTH(32)
  ) mbuf_2 (
    .aclk(aclk), .aresetn(aresetn),
    .in_data(int_mdata_wire[2]), .in_valid(int_mvalid_wire[2]), .in_ready(int_mready_wire[2]),
    .out_data(m02_axis_tdata), .out_valid(m02_axis_tvalid), .out_ready(m02_axis_tready)
  );

  assign int_bdata_wire[3] = b03_bram_rdata;
  assign b03_bram_clk = aclk;
  assign b03_bram_rst = ~aresetn;
  assign b03_bram_en = int_rsel_wire[5] | int_wsel_wire[5];
  assign b03_bram_we = int_wsel_wire[5] ? 4'd15 : 4'd0;
  assign b03_bram_addr = int_we_wire ? int_waddr_wire : int_raddr_wire;
  assign b03_bram_wdata = int_wdata_wire;

  assign int_sdata_wire[3] = s03_axis_tdata;
  assign int_svalid_wire[3] = s03_axis_tvalid;
  assign s03_axis_tready = int_sready_wire[3];

  inout_buffer #(
    .DATA_WIDTH(32)
  ) mbuf_3 (
    .aclk(aclk), .aresetn(aresetn),
    .in_data(int_mdata_wire[3]), .in_valid(int_mvalid_wire[3]), .in_ready(int_mready_wire[3]),
    .out_data(m03_axis_tdata), .out_valid(m03_axis_tvalid), .out_ready(m03_axis_tready)
  );

  assign int_bdata_wire[4] = b04_bram_rdata;
  assign b04_bram_clk = aclk;
  assign b04_bram_rst = ~aresetn;
  assign b04_bram_en = int_rsel_wire[6] | int_wsel_wire[6];
  assign b04_bram_we = int_wsel_wire[6] ? 4'd15 : 4'd0;
  assign b04_bram_addr = int_we_wire ? int_waddr_wire : int_raddr_wire;
  assign b04_bram_wdata = int_wdata_wire;

  assign int_sdata_wire[4] = s04_axis_tdata;
  assign int_svalid_wire[4] = s04_axis_tvalid;
  assign s04_axis_tready = int_sready_wire[4];

  inout_buffer #(
    .DATA_WIDTH(32)
  ) mbuf_4 (
    .aclk(aclk), .aresetn(aresetn),
    .in_data(int_mdata_wire[4]), .in_valid(int_mvalid_wire[4]), .in_ready(int_mready_wire[4]),
    .out_data(m04_axis_tdata), .out_valid(m04_axis_tvalid), .out_ready(m04_axis_tready)
  );

  assign int_bdata_wire[5] = b05_bram_rdata;
  assign b05_bram_clk = aclk;
  assign b05_bram_rst = ~aresetn;
  assign b05_bram_en = int_rsel_wire[7] | int_wsel_wire[7];
  assign b05_bram_we = int_wsel_wire[7] ? 4'd15 : 4'd0;
  assign b05_bram_addr = int_we_wire ? int_waddr_wire : int_raddr_wire;
  assign b05_bram_wdata = int_wdata_wire;

  assign int_sdata_wire[5] = s05_axis_tdata;
  assign int_svalid_wire[5] = s05_axis_tvalid;
  assign s05_axis_tready = int_sready_wire[5];

  inout_buffer #(
    .DATA_WIDTH(32)
  ) mbuf_5 (
    .aclk(aclk), .aresetn(aresetn),
    .in_data(int_mdata_wire[5]), .in_valid(int_mvalid_wire[5]), .in_ready(int_mready_wire[5]),
    .out_data(m05_axis_tdata), .out_valid(m05_axis_tvalid), .out_ready(m05_axis_tready)
  );

endmodule
