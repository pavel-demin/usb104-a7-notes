module usb_fifo #
(
  parameter integer CFG_DATA_WIDTH = 32
)
(
  input  wire                      aclk,

  input  wire                      usb_clk, usb_full, usb_empty,
  output wire                      usb_rdn, usb_wrn, usb_oen, usb_siwun,
  inout  wire [7:0]                usb_data,

  output wire [CFG_DATA_WIDTH-1:0] cfg_data,

  // Slave side
  input  wire [31:0]               s_axis_tdata,
  input  wire                      s_axis_tvalid,
  output wire                      s_axis_tready,

  // Master side
  output wire [31:0]               m_axis_tdata,
  output wire                      m_axis_tvalid,
  input  wire                      m_axis_tready
);

  function integer clogb2 (input integer value);
    for(clogb2 = 0; value > 0; clogb2 = clogb2 + 1) value = value >> 1;
  endfunction

  localparam integer MUX_SIZE = 2;
  localparam integer CFG_SIZE = CFG_DATA_WIDTH / 32;
  localparam integer CFG_WIDTH = CFG_SIZE > 1 ? clogb2(CFG_SIZE - 1) : 1;

  wire [CFG_SIZE-1:0] int_fdre_ce;
  wire [MUX_SIZE-1:0] int_wsel;

  reg [8:0] byte_counter = 9'd0;
  reg [4:0] idle_counter = 5'd0;
  reg int_rx_ready_reg = 1'b0;

  wire [63:0] int_rx_data;
  wire [7:0] int_tx_data;

  wire int_tx_full, int_tx_empty;
  wire int_rx_full, int_rx_empty, int_rx_valid;
  wire int_rx_ready, int_tx_ready;
  wire int_rx_rd, int_tx_wr, int_tx_pktend;

  genvar j, k;

  assign int_rx_valid = ~int_rx_empty;

  assign int_rx_ready = ~usb_empty & ~int_rx_full & ~int_tx_pktend;
  assign int_tx_ready = ~int_rx_ready & ~usb_full & ~int_tx_empty & ~int_tx_pktend;

  assign int_rx_rd = int_rx_ready & int_rx_ready_reg;
  assign int_tx_wr = int_tx_ready & ~int_rx_ready_reg;

  assign int_tx_pktend = &idle_counter;

  assign int_wsel[0] = int_rx_valid & int_rx_data[63:56] == 0;
  assign int_wsel[1] = int_rx_valid & int_rx_data[63:56] == 1;

  generate
    for(j = 0; j < CFG_SIZE; j = j + 1)
    begin : CFG_WORDS
      assign int_fdre_ce[j] = int_wsel[0] & int_rx_data[32+CFG_WIDTH-1:32] == j;
      for(k = 0; k < 32; k = k + 1)
      begin : CFG_BITS
        FDRE #(
          .INIT(1'b0)
        ) FDRE_inst (
          .CE(int_fdre_ce[j]),
          .C(aclk),
          .R(1'b0),
          .D(int_rx_data[k]),
          .Q(cfg_data[j*32+k])
        );
      end
    end
  endgenerate

  xpm_fifo_async #(
    .WRITE_DATA_WIDTH(32),
    .FIFO_WRITE_DEPTH(1024),
    .READ_DATA_WIDTH(8),
    .READ_MODE("fwft"),
    .FIFO_READ_LATENCY(0),
    .FIFO_MEMORY_TYPE("block"),
    .USE_ADV_FEATURES("0000"),
    .CDC_SYNC_STAGES(4)
  ) fifo_tx (
    .rst(1'b0),

    .empty(int_tx_empty),
    .full(int_tx_full),

    .wr_clk(aclk),
    .wr_en(s_axis_tvalid),
    .din(s_axis_tdata),

    .rd_clk(usb_clk),
    .rd_en(int_tx_wr),
    .dout(int_tx_data)
  );

  xpm_fifo_async #(
    .WRITE_DATA_WIDTH(8),
    .FIFO_WRITE_DEPTH(4096),
    .READ_DATA_WIDTH(64),
    .READ_MODE("fwft"),
    .FIFO_READ_LATENCY(0),
    .FIFO_MEMORY_TYPE("block"),
    .USE_ADV_FEATURES("0000"),
    .CDC_SYNC_STAGES(4)
  ) fifo_rx (
    .rst(1'b0),

    .empty(int_rx_empty),
    .full(int_rx_full),

    .wr_clk(usb_clk),
    .wr_en(int_rx_rd),
    .din(usb_data),

    .rd_clk(aclk),
    .rd_en(int_rx_valid),
    .dout(int_rx_data)
  );

  always @(posedge usb_clk)
  begin
    // respect 1 clock delay between fifo selection
    // and data transfer operations
    int_rx_ready_reg <= int_rx_ready;

    // assert pktend if buffer contains unsent data
    // and fifo_tx stays empty for more than 30 clocks
    if(int_tx_pktend)
    begin
      byte_counter <= 9'd0;
      idle_counter <= 5'd0;
    end
    else if(int_tx_wr)
    begin
      byte_counter <= byte_counter + 1'b1;
      idle_counter <= 5'd0;
    end
    else if(|byte_counter & int_tx_empty & ~int_rx_ready)
    begin
      idle_counter <= idle_counter + 1'b1;
    end
  end

  assign s_axis_tready = ~int_tx_full;

  assign m_axis_tdata = int_rx_data[31:0];
  assign m_axis_tvalid = int_wsel[1];

  assign usb_rdn = ~int_rx_rd;
  assign usb_wrn = ~int_tx_wr;
  assign usb_oen = ~int_rx_ready;
  assign usb_siwun = ~int_tx_pktend;
  assign usb_data = int_tx_wr ? int_tx_data : {(8){1'bz}};

endmodule
