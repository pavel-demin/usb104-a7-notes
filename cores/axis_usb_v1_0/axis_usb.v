
`timescale 1 ns / 1 ps

module axis_usb
(
  input  wire        aclk,

  input  wire        usb_clk, usb_full, usb_empty,
  output wire        usb_rdn, usb_wrn, usb_oen, usb_siwun,
  inout  wire [7:0]  usb_data,

  input  wire [31:0] s_axis_tdata,
  input  wire        s_axis_tvalid,
  output wire        s_axis_tready,

  output wire [31:0] m_axis_tdata,
  output wire        m_axis_tvalid,
  input  wire        m_axis_tready
);

  reg [9:0] int_tx_cntr_reg = 10'd0, int_tx_cntr_next;
  reg [1:0] int_tx_case_reg = 2'd0, int_tx_case_next;
  reg int_tx_xtra_reg = 1'b0, int_tx_xtra_next;
  reg int_tx_oe_reg = 1'b0, int_tx_oe_next;
  reg int_tx_si_reg = 1'b0, int_tx_si_next;

  reg int_rx_oe_reg = 1'b0;

  wire [7:0] int_tx_data_wire;

  wire [31:0] int_mdata_wire;
  wire int_mready_wire;

  wire int_tx_full_wire, int_tx_empty_wire;
  wire int_tx_valid_wire, int_tx_ready_wire;
  wire int_tx_rd_wire, int_tx_wr_wire;

  wire int_rx_full_wire, int_rx_empty_wire;
  wire int_rx_valid_wire, int_rx_ready_wire;
  wire int_rx_rd_wire, int_rx_oe_wire;

  assign int_tx_valid_wire = ~int_tx_empty_wire & int_tx_oe_reg;
  assign int_tx_ready_wire = ~usb_full;

  assign int_tx_rd_wire = int_tx_valid_wire & int_tx_ready_wire & ~int_rx_oe_reg;
  assign int_tx_wr_wire = (int_tx_valid_wire | int_tx_xtra_reg) & ~int_rx_oe_reg;

  assign int_rx_valid_wire = ~usb_empty & int_rx_oe_reg;
  assign int_rx_ready_wire = ~int_rx_full_wire;

  assign int_rx_rd_wire = int_rx_valid_wire & int_rx_ready_wire;
  assign int_rx_oe_wire = ~usb_empty & int_rx_ready_wire;

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

    .empty(int_tx_empty_wire),
    .full(int_tx_full_wire),

    .wr_clk(aclk),
    .wr_en(s_axis_tvalid),
    .din(s_axis_tdata),

    .rd_clk(usb_clk),
    .rd_en(int_tx_rd_wire),
    .dout(int_tx_data_wire)
  );

  xpm_fifo_async #(
    .WRITE_DATA_WIDTH(8),
    .FIFO_WRITE_DEPTH(4096),
    .READ_DATA_WIDTH(32),
    .READ_MODE("fwft"),
    .FIFO_READ_LATENCY(0),
    .FIFO_MEMORY_TYPE("block"),
    .USE_ADV_FEATURES("0000"),
    .CDC_SYNC_STAGES(4)
  ) fifo_rx (
    .rst(1'b0),

    .empty(int_rx_empty_wire),
    .full(int_rx_full_wire),

    .wr_clk(usb_clk),
    .wr_en(int_rx_valid_wire),
    .din(usb_data),

    .rd_clk(aclk),
    .rd_en(int_mready_wire),
    .dout(int_mdata_wire)
  );

  inout_buffer #(
    .DATA_WIDTH(32)
  ) buf_0 (
    .aclk(aclk), .aresetn(1'b1),
    .in_data(int_mdata_wire), .in_valid(~int_rx_empty_wire), .in_ready(int_mready_wire),
    .out_data(m_axis_tdata), .out_valid(m_axis_tvalid), .out_ready(m_axis_tready)
  );

  always @(posedge usb_clk)
  begin
    // respect 1 clock cycle delay between output activation
    // and rx data transfer operations
    int_rx_oe_reg <= int_rx_oe_wire;

    int_tx_cntr_reg <= int_tx_cntr_next;
    int_tx_case_reg <= int_tx_case_next;
    int_tx_xtra_reg <= int_tx_xtra_next;
    int_tx_oe_reg <= int_tx_oe_next;
    int_tx_si_reg <= int_tx_si_next;
  end

  always @*
  begin
    int_tx_cntr_next = int_tx_cntr_reg;
    int_tx_case_next = int_tx_case_reg;
    int_tx_xtra_next = int_tx_xtra_reg;
    int_tx_oe_next = int_tx_oe_reg;
    int_tx_si_next = int_tx_si_reg;

    case(int_tx_case_reg)
      2'd0:
      begin
        int_tx_si_next = 1'b0;
        if(~int_tx_empty_wire)
        begin
          int_tx_oe_next = 1'b1;
          int_tx_case_next = 2'd1;
        end
      end
      2'd1:
      begin
        if(int_tx_rd_wire)
        begin
          int_tx_cntr_next = int_tx_cntr_reg + 1'b1;
          if(int_tx_cntr_reg == 10'd1019)
          begin
            int_tx_cntr_next = 10'd0;
          end
        end
        if(int_tx_empty_wire)
        begin
          int_tx_oe_next = 1'b0;
          if(|int_tx_cntr_reg & int_tx_cntr_reg < 10'd17)
          begin
            int_tx_xtra_next = 1'b1;
            int_tx_case_next = 2'd2;
          end
          else
          begin
            int_tx_cntr_next = 10'd17;
            int_tx_case_next = 2'd3;
          end
        end
      end
      2'd2:
      begin
        if(int_tx_ready_wire & ~int_rx_oe_reg)
        begin
          int_tx_cntr_next = int_tx_cntr_reg + 1'b1;
          if(int_tx_cntr_reg == 10'd16)
          begin
            int_tx_xtra_next = 1'b0;
            int_tx_case_next = 2'd3;
          end
        end
      end
      2'd3:
      begin
        int_tx_cntr_next = int_tx_cntr_reg - 1'b1;
        if(int_tx_cntr_reg == 10'd1)
        begin
          int_tx_si_next = 1'b1;
          int_tx_case_next = 2'd0;
        end
      end
    endcase
  end

  assign s_axis_tready = ~int_tx_full_wire;

  assign usb_rdn = ~int_rx_rd_wire;
  assign usb_wrn = ~int_tx_wr_wire;
  assign usb_oen = ~int_rx_oe_wire;
  assign usb_siwun = ~int_tx_si_reg;
  assign usb_data = int_tx_wr_wire ? int_tx_data_wire : {(8){1'bz}};

endmodule
