
`timescale 1 ns / 1 ps

module cdc #
(
  parameter integer DATA_WIDTH = 32
)
(
  input  wire                  aclk,
  input  wire                  aresetn,

  input  wire [DATA_WIDTH-1:0] in_data,

  output wire [DATA_WIDTH-1:0] out_data
);

  reg [DATA_WIDTH-1:0] int_data0_reg = {(DATA_WIDTH){1'b0}};
  reg [DATA_WIDTH-1:0] int_data1_reg = {(DATA_WIDTH){1'b0}};
  reg [DATA_WIDTH-1:0] int_data2_reg = {(DATA_WIDTH){1'b0}};
  reg [DATA_WIDTH-1:0] int_data3_reg = {(DATA_WIDTH){1'b0}};

  always @(posedge aclk)
  begin
    if(~aresetn)
    begin
      int_data0_reg <= {(DATA_WIDTH){1'b0}};
      int_data1_reg <= {(DATA_WIDTH){1'b0}};
      int_data2_reg <= {(DATA_WIDTH){1'b0}};
      int_data3_reg <= {(DATA_WIDTH){1'b0}};
    end
    else
    begin
      int_data0_reg <= in_data;
      int_data1_reg <= int_data0_reg;
      int_data2_reg <= int_data1_reg;
      int_data3_reg <= int_data2_reg;
    end
  end

  assign out_data = int_data3_reg;

endmodule
