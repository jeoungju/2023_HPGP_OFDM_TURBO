`timescale 1ns/100ps
module add_input3
#(
    parameter SIGN_BIT=1,
    parameter INT_BIT=6,
    parameter FLT_BIT=6
)
(
    din_a,
    din_b,
    din_c,
    dout
);

localparam DW = SIGN_BIT+INT_BIT+FLT_BIT;

input [DW-1:0] din_a;
input [DW-1:0] din_b;
input [DW-1:0] din_c;
//input [DW-1:0] din_d;

output [DW+1:0] dout;

wire [DW:0] sum1;
//wire [DW:0] sum2;

add #(
    .SIGN_BIT(SIGN_BIT),
    .INT_BIT(INT_BIT),
    .FLT_BIT(FLT_BIT)
) u_adder1
(
    .din_a(din_a),
    .din_b(din_b),
    .dout(sum1)
);


add #(
    .SIGN_BIT(SIGN_BIT),
    .INT_BIT(INT_BIT+1),
    .FLT_BIT(FLT_BIT)
) u_adder
(
    .din_a(sum1),
    .din_b({din_c[DW-1],din_c[DW-1],din_c[DW-2:0]}),
    .dout(dout)
);

endmodule