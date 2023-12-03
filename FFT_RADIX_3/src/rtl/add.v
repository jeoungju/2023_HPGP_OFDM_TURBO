`timescale 1ns/100ps
module add #(
    parameter SIGN_BIT=1,
    parameter INT_BIT=6,
    parameter FLT_BIT=6
)
(
    din_a,
    din_b,
    dout
);

localparam DW = SIGN_BIT+INT_BIT+FLT_BIT;

input [DW-1:0] din_a;
input [DW-1:0] din_b;

output [DW:0] dout;

wire [DW:0] din_a_ext;
wire din_a_sign;

wire [DW:0] din_b_ext;
wire din_b_sign;

assign din_a_sign = din_a[DW-1];
assign din_b_sign = din_b[DW-1];

assign din_a_ext = {din_a_sign,din_a};
assign din_b_ext = {din_b_sign,din_b};

assign dout = din_a_ext+din_b_ext;


endmodule