
`timescale 1 ns / 1 ps

module axis_downsizer #
(
  parameter integer S_AXIS_TDATA_WIDTH = 128,
  parameter integer M_AXIS_TDATA_WIDTH = 32
)
(
  // System signals
  input  wire                          aclk,
  input  wire                          aresetn,

  input  wire [15:0]                   cfg_data,

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

  localparam integer RATIO = S_AXIS_TDATA_WIDTH / M_AXIS_TDATA_WIDTH;
  localparam integer CNTR_WIDTH = RATIO > 1 ? clogb2(RATIO - 1) : 1;
  localparam integer DATA_WIDTH = S_AXIS_TDATA_WIDTH - M_AXIS_TDATA_WIDTH;

  reg [DATA_WIDTH-1:0] int_data_reg, int_data_next;
  reg [CNTR_WIDTH-1:0] int_cntr_reg, int_cntr_next;

  wire [M_AXIS_TDATA_WIDTH-1:0] int_data_mux [RATIO-2:0];
  wire [M_AXIS_TDATA_WIDTH-1:0] int_data_wire;
  wire int_comp_wire, int_valid_wire, int_ready_wire;

  genvar j;

  assign int_comp_wire = |int_cntr_reg;

  assign int_valid_wire = int_comp_wire | s_axis_tvalid;

  assign int_data_wire = int_comp_wire ? int_data_mux[cfg_data-int_cntr_reg] : s_axis_tdata[M_AXIS_TDATA_WIDTH-1:0];

  generate
    for(j = 0; j < RATIO - 1; j = j + 1)
    begin : WORDS
      assign int_data_mux[j] = int_data_reg[j*M_AXIS_TDATA_WIDTH+:M_AXIS_TDATA_WIDTH];
    end
  endgenerate

  always @(posedge aclk)
  begin
    if(~aresetn)
    begin
      int_data_reg <= {(DATA_WIDTH){1'b0}};
      int_cntr_reg <= {(CNTR_WIDTH){1'b0}};
    end
    else
    begin
      int_data_reg <= int_data_next;
      int_cntr_reg <= int_cntr_next;
    end
  end

  always @*
  begin
    int_data_next = int_data_reg;
    int_cntr_next = int_cntr_reg;

    if(int_comp_wire & int_ready_wire)
    begin
      int_cntr_next = int_cntr_reg - 1'b1;
    end

    if(s_axis_tvalid & s_axis_tready)
    begin
      int_cntr_next = cfg_data[CNTR_WIDTH-1:0];
      int_data_next = s_axis_tdata[S_AXIS_TDATA_WIDTH-1:M_AXIS_TDATA_WIDTH];
    end
  end

  inout_buffer #(
    .DATA_WIDTH(M_AXIS_TDATA_WIDTH)
  ) buf_0 (
    .aclk(aclk), .aresetn(aresetn),
    .in_data(int_data_wire), .in_valid(int_valid_wire), .in_ready(int_ready_wire),
    .out_data(m_axis_tdata), .out_valid(m_axis_tvalid), .out_ready(m_axis_tready)
  );

  assign s_axis_tready = ~int_comp_wire & int_ready_wire;

endmodule
