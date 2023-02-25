hub_size = 6
source = """
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
{% for i in range(hub_size) -%}
{% set index =  "%02d" % i %}
  output wire                      b{{index}}_bram_clk,
  output wire                      b{{index}}_bram_rst,
  output wire                      b{{index}}_bram_en,
  output wire [3:0]                b{{index}}_bram_we,
  output wire [15:0]               b{{index}}_bram_addr,
  output wire [31:0]               b{{index}}_bram_wdata,
  input  wire [31:0]               b{{index}}_bram_rdata,

  input  wire [31:0]               s{{index}}_axis_tdata,
  input  wire                      s{{index}}_axis_tvalid,
  output wire                      s{{index}}_axis_tready,

  output wire [31:0]               m{{index}}_axis_tdata,
  output wire                      m{{index}}_axis_tvalid,
  input  wire                      m{{index}}_axis_tready{% if not loop.last %},{% endif %}
{% endfor -%}
);

  function integer clogb2 (input integer value);
    for(clogb2 = 0; value > 0; clogb2 = clogb2 + 1) value = value >> 1;
  endfunction

  localparam integer HUB_SIZE = {{hub_size}};
  localparam integer MUX_SIZE = HUB_SIZE + 2;
  localparam integer CFG_SIZE = CFG_DATA_WIDTH / 32;
  localparam integer CFG_WIDTH = CFG_SIZE > 1 ? clogb2(CFG_SIZE - 1) : 1;
  localparam integer STS_SIZE = STS_DATA_WIDTH / 32;
  localparam integer STS_WIDTH = STS_SIZE > 1 ? clogb2(STS_SIZE - 1) : 1;

  reg [11:0] int_awcntr_reg, int_awcntr_next;
  reg [11:0] int_arcntr_reg, int_arcntr_next;
  reg [HUB_SIZE-1:0] int_rsel_reg;

  wire s_axis_awvalid, s_axis_wvalid, s_axis_arvalid;

  wire int_awvalid_wire, int_awready_wire;
  wire int_wvalid_wire, int_wready_wire;
  wire int_arvalid_wire, int_arready_wire;
  wire int_rvalid_wire, int_rready_wire;

  wire [11:0] int_awlen_wire;
  wire [18:0] int_awaddr_wire;

  wire int_wlast_wire;
  wire [31:0] int_wdata_wire;

  wire [11:0] int_arlen_wire;
  wire [18:0] int_araddr_wire;

  wire int_rlast_wire;
  wire [31:0] int_rdata_wire [MUX_SIZE-1:0];

  wire [31:0] int_sdata_wire [HUB_SIZE-1:0];
  wire [31:0] int_mdata_wire [HUB_SIZE-1:0];
  wire [HUB_SIZE-1:0] int_svalid_wire, int_sready_wire;
  wire [HUB_SIZE-1:0] int_mvalid_wire, int_mready_wire;

  wire [31:0] int_bdata_wire [HUB_SIZE-1:0];

  wire [15:0] int_waddr_wire;
  wire [15:0] int_raddr_wire;

  wire [31:0] int_cfg_mux [CFG_SIZE-1:0];
  wire [31:0] int_sts_mux [STS_SIZE-1:0];

  wire [31:0] int_rdata_mux [MUX_SIZE-1:0];
  wire [MUX_SIZE-1:0] int_wsel_wire, int_rsel_wire;

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

  assign int_waddr_wire = int_awaddr_wire[15:0] + int_awcntr_reg;
  assign int_raddr_wire = int_araddr_wire[15:0] + int_arcntr_reg;

  assign int_rdata_wire[0] = int_rdata_mux[int_araddr_wire[18:16]];

  assign int_rdata_mux[0] = int_cfg_mux[int_raddr_wire[CFG_WIDTH-1:0]];
  assign int_rdata_mux[1] = int_sts_mux[int_raddr_wire[STS_WIDTH-1:0]];

  generate
    for(j = 0; j < HUB_SIZE; j = j + 1)
    begin : MUXES
      assign int_rdata_mux[j+2] = int_svalid_wire[j] ? int_sdata_wire[j] : 32'd0;
      assign int_rdata_wire[j+2] = int_rsel_reg[j] ? int_bdata_wire[j] : 32'd0;
      assign int_mdata_wire[j] = int_wdata_wire;
      assign int_mvalid_wire[j] = int_wsel_wire[j+2];
      assign int_sready_wire[j] = int_rsel_wire[j+2];
    end
  endgenerate

  generate
    for(j = 0; j < MUX_SIZE; j = j + 1)
    begin : SELECTS
      assign int_wsel_wire[j] = int_we_wire & (int_awaddr_wire[18:16] == j);
      assign int_rsel_wire[j] = int_re_wire & (int_araddr_wire[18:16] == j);
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
    if(~aresetn)
    begin
      int_awcntr_reg <= 12'd0;
      int_arcntr_reg <= 12'd0;
      int_rsel_reg <= {(HUB_SIZE){1'b0}};
    end
    else
    begin
      int_awcntr_reg <= int_awcntr_next;
      int_arcntr_reg <= int_arcntr_next;
      int_rsel_reg <= int_rsel_wire[2+HUB_SIZE-1:2] & ~int_svalid_wire;
    end
  end

  always @*
  begin
    int_awcntr_next = int_awcntr_reg;
    int_arcntr_next = int_arcntr_reg;

    if(int_awvalid_wire & int_awready_wire)
    begin
      int_awcntr_next = 12'd0;
    end

    if(int_arvalid_wire & int_arready_wire)
    begin
      int_arcntr_next = 12'd0;
    end

    if(~int_wlast_wire & int_we_wire)
    begin
      int_awcntr_next = int_awcntr_reg + 1'b1;
    end

    if(~int_rlast_wire & int_re_wire)
    begin
      int_arcntr_next = int_arcntr_reg + 1'b1;
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
    .DATA_WIDTH(32)
  ) buf_3 (
    .aclk(aclk), .aresetn(aresetn),
    .in_data(int_rdata_wire[0]),
    .in_valid(int_rvalid_wire), .in_ready(int_rready_wire),
    .out_data(int_rdata_wire[1]),
    .out_valid(m_axis_tvalid), .out_ready(m_axis_tready)
  );

  assign s_axis_tready = s_axis_awready ? s_axis_tdata[31] | s_axis_arready : s_axis_wready;

  assign m_axis_tdata = {{m_axis_tdata(hub_size)}};
{% for i in range(hub_size) -%}
{% set index =  "%02d" % i %}
  assign int_bdata_wire[{{i}}] = b{{index}}_bram_rdata;
  assign b{{index}}_bram_clk = aclk;
  assign b{{index}}_bram_rst = ~aresetn;
  assign b{{index}}_bram_en = int_rsel_wire[{{i+2}}] | int_wsel_wire[{{i+2}}];
  assign b{{index}}_bram_we = int_wsel_wire[{{i+2}}] ? 4'd15 : 4'd0;
  assign b{{index}}_bram_addr = int_we_wire ? int_waddr_wire : int_raddr_wire;
  assign b{{index}}_bram_wdata = int_wdata_wire;

  assign int_sdata_wire[{{i}}] = s{{index}}_axis_tdata;
  assign int_svalid_wire[{{i}}] = s{{index}}_axis_tvalid;
  assign s{{index}}_axis_tready = int_sready_wire[{{i}}];

  inout_buffer #(
    .DATA_WIDTH(32)
  ) mbuf_{{i}} (
    .aclk(aclk), .aresetn(aresetn),
    .in_data(int_mdata_wire[{{i}}]), .in_valid(int_mvalid_wire[{{i}}]), .in_ready(int_mready_wire[{{i}}]),
    .out_data(m{{index}}_axis_tdata), .out_valid(m{{index}}_axis_tvalid), .out_ready(m{{index}}_axis_tready)
  );
{% endfor %}
endmodule
"""

import jinja2


def m_axis_tdata(n):
    return " | ".join(map(lambda i: "int_rdata_wire[%d]" % i, range(1, n + 2)))


print(jinja2.Template(source).render(hub_size=hub_size, m_axis_tdata=m_axis_tdata))
