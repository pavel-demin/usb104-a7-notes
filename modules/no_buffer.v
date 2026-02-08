
`timescale 1 ns / 1 ps

module no_buffer #
(
  parameter integer DATA_WIDTH = 32
)
(
  input  wire                  aclk,
  input  wire                  aresetn,

  input  wire [DATA_WIDTH-1:0] in_data,
  input  wire                  in_valid,
  output wire                  in_ready,

  output wire [DATA_WIDTH-1:0] out_data,
  output wire                  out_valid,
  input  wire                  out_ready
);

  assign in_ready = out_ready;

  assign out_data = in_data;
  assign out_valid = in_valid;

endmodule
