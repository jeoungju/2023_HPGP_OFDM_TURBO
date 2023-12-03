module BF4 ///no use
#(
    parameter SIGN_BIT=1,
    parameter INT_BIT=6,
    parameter FLT_BIT=6
)
(
    in1_re, in1_im,
    in2_re, in2_im,
    in3_re, in3_im,
    in4_re, in4_im,
    out1_re, out1_im,
    out2_re, out2_im,
    out3_re, out3_im,
    out4_re, out4_im,
);

localparam DW = SIGN_BIT+INT_BIT+FLT_BIT;

//  0.5       = 34'b0_0_1000_0000_0000_0000_0000_0000_0000_0000
// -0.5       = 34'b1_1_1000_0000_0000_0000_0000_0000_0000_0000
//  sqrt(3)/2 = 34'b0_0_1101_1101_1011_0011_1101_0111_0100_0010
// -sqrt(3)/2 = 34'b1_1_0010_0010_0100_1100_0010_1000_1011_1110

input [DW-1:0] in1_re; input [DW-1:0] in1_im;
input [DW-1:0] in2_re; input [DW-1:0] in2_im;
input [DW-1:0] in3_re; input [DW-1:0] in3_im;
input [DW-1:0] in4_re; input [DW-1:0] in4_im;

output [DW+1:0] out1_re; output [DW+1:0] out1_im;
output [DW+1:0] out2_re; output [DW+1:0] out2_im;
output [DW+1:0] out3_re; output [DW+1:0] out3_im;
output [DW+1:0] out4_re; output [DW+1:0] out4_im;

add_input4 #( // out1_re=in1_re+in2_re+in3_re+in4_re;
    .SIGN_BIT(SIGN_BIT),
    .INT_BIT(INT_BIT),
    .FLT_BIT(FLT_BIT)
) u_adder_input4_1 (
    .din_a(in1_re),
    .din_b(in2_re),
    .din_c(in3_re),
    .din_d(in4_re),
    .dout(out1_re)
);

add_input4 #( // out1_im=in1_im+in2_im+in3_im+in4_im;
    .SIGN_BIT(SIGN_BIT),
    .INT_BIT(INT_BIT),
    .FLT_BIT(FLT_BIT)
) u_adder_input4_2 (
    .din_a(in1_im),
    .din_b(in2_im),
    .din_c(in3_im),
    .din_d(in4_im),
    .dout(out1_im)
);

wire [DW-1:0] m_in2_re;
wire [DW-1:0] m_in2_im;
wire [DW-1:0] m_in3_re;
wire [DW-1:0] m_in3_im;
wire [DW-1:0] m_in4_re;
wire [DW-1:0] m_in4_im;

assign m_in2_re = (~(in2_re) + {{(DW-2){1'b0}},1'b1});
assign m_in2_im = (~(in2_im) + {{(DW-2){1'b0}},1'b1});
assign m_in3_re = (~(in3_re) + {{(DW-2){1'b0}},1'b1});
assign m_in3_im = (~(in3_im) + {{(DW-2){1'b0}},1'b1});
assign m_in4_re = (~(in4_re) + {{(DW-2){1'b0}},1'b1});
assign m_in4_im = (~(in4_im) + {{(DW-2){1'b0}},1'b1});

add_input4 #( // out2_re=in1_re+in2_im-in3_re-in4_im;
    .SIGN_BIT(SIGN_BIT),
    .INT_BIT(INT_BIT),
    .FLT_BIT(FLT_BIT)
) u_adder_input4_3 (
    .din_a(in1_re),
    .din_b(in2_im),
    .din_c(m_in3_re),
    .din_d(m_in4_im),
    .dout(out2_re)
);

add_input4 #( // out2_im=in1_im-in2_re-in3_im+in4_re;
    .SIGN_BIT(SIGN_BIT),
    .INT_BIT(INT_BIT),
    .FLT_BIT(FLT_BIT)
) u_adder_input4_4 (
    .din_a(in1_im),
    .din_b(m_in2_re),
    .din_c(m_in3_im),
    .din_d(in4_re),
    .dout(out2_im)
);

add_input4 #( // out3_re=in1_re-in2_re+in3_re-in4_re;
    .SIGN_BIT(SIGN_BIT),
    .INT_BIT(INT_BIT),
    .FLT_BIT(FLT_BIT)
) u_adder_input4_5 (
    .din_a(in1_re),
    .din_b(m_in2_re),
    .din_c(in3_re),
    .din_d(m_in4_re),
    .dout(out3_re)
);

add_input4 #( // out3_im=in1_im-in2_im+in3_im-in4_im;
    .SIGN_BIT(SIGN_BIT),
    .INT_BIT(INT_BIT),
    .FLT_BIT(FLT_BIT)
) u_adder_input4_6 (
    .din_a(in1_im),
    .din_b(m_in2_im),
    .din_c(in3_im),
    .din_d(m_in4_im),
    .dout(out3_im)
);

add_input4 #( // out4_re=in1_re-in2_im-in3_re+in4_im;
    .SIGN_BIT(SIGN_BIT),
    .INT_BIT(INT_BIT),
    .FLT_BIT(FLT_BIT)
) u_adder_input4_7 (
    .din_a(in1_re),
    .din_b(m_in2_im),
    .din_c(m_in3_re),
    .din_d(in4_im),
    .dout(out4_re)
);

add_input4 #( // out4_im=in1_im+in2_re-in3_im-in4_re;
    .SIGN_BIT(SIGN_BIT),
    .INT_BIT(INT_BIT),
    .FLT_BIT(FLT_BIT)
) u_adder_input4_8 (
    .din_a(in1_im),
    .din_b(in2_re),
    .din_c(m_in3_im),
    .din_d(m_in4_re),
    .dout(out4_im)
);

endmodule