`timescale 1ns/100ps
module rd3bf 
#(
    parameter SIGN_BIT=1,
    parameter INT_BIT=6,
    parameter FLT_BIT=6
)
(
    clk,
    n_rst,
    di_vld,
    in1_re, in1_im,
    in2_re, in2_im,
    in3_re, in3_im,
    out1_re, out1_im,
    out2_re, out2_im,
    out3_re, out3_im,
    do_vld
);

localparam DW = SIGN_BIT+INT_BIT+FLT_BIT;
//parameter D1_SIZE = 13;
//parameter D2_SIZE = 11;


//  0.5       = 34'b0_0_1000_0000_0000_0000_0000_0000_0000_0000  
// -0.5       = 34'b1_1_1000_0000_0000_0000_0000_0000_0000_0000
//  sqrt(3)/2 = 34'b0_0_1101_1101_1011_0010.1_1101_0111_0100_0010
// -sqrt(3)/2 = 34'b1_1_0010_0010_0100_1100_0010_1000_1011_1110

localparam COS120 = 34'b1_1_1000_0000_0___000_0000_0000_0000_0000_0000;
localparam COS240 = 34'b1_1_1000_0000_0___000_0000_0000_0000_0000_0000;
localparam SIN120 = 34'b0_0_1101_1101_1___011_0011_1101_0111_0100_0010;
//localparam SIN240 = 34'b1_1_0010_0010_0___100_1100_0010_1000_1011_1110;
localparam SIN240 = 34'b1_1_0010_0010_1___100_1100_0010_1000_1011_1110;


input clk;
input n_rst;
input di_vld;

input [DW-1:0] in1_re; input [DW-1:0] in1_im;  // x[n] = a + bi
input [DW-1:0] in2_re; input [DW-1:0] in2_im;  // x[n+N/3] = c + di
input [DW-1:0] in3_re; input [DW-1:0] in3_im;  // x[n+2N/3] = e + fi


output [DW+1:0] out1_re; output [DW+1:0] out1_im;
output [DW+1:0] out2_re; output [DW+1:0] out2_im;
output [DW+1:0] out3_re; output [DW+1:0] out3_im;

output do_vld;

////////////////////////complex result////////////////////////

wire [DW:0] c_in2_120_re;
wire [DW:0] c_in2_120_im;
wire [DW:0] c_in3_240_re;
wire [DW:0] c_in3_240_im;
wire [DW:0] c_in2_240_re;
wire [DW:0] c_in2_240_im;
wire [DW:0] c_in3_120_re;
wire [DW:0] c_in3_120_im;

//////////////////////////////////////////////////////////////

wire [DW+1:0] out1_re_a, out1_im_a;
wire [DW+1:0] out2_re_a, out2_im_a;
wire [DW+1:0] out3_re_a, out3_im_a;

//////////////////////////////////////////////////////////////



///////////////////////////x[n]///////////////////////////////

add_input3 #( 
    .SIGN_BIT(SIGN_BIT),
    .INT_BIT(INT_BIT),
    .FLT_BIT(FLT_BIT)
) u_adder_input3_1 (
    .din_a(in1_re),
    .din_b(in2_re),
    .din_c(in3_re),
    .dout(out1_re_a)
); //x[n] re

add_input3 #( 
    .SIGN_BIT(SIGN_BIT),
    .INT_BIT(INT_BIT),
    .FLT_BIT(FLT_BIT)
) u_adder_input3_2 (
    .din_a(in1_im),
    .din_b(in2_im),
    .din_c(in3_im),
    .dout(out1_im_a)
); //x[n] im

reg [DW+1:0] out1_re_d1, out1_im_d1;
reg [DW+1:0] out1_re_d2, out1_im_d2;
reg [DW+1:0] out1_re_d3, out1_im_d3;

always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        out1_re_d1 <= {(DW+2){1'b0}};
        out1_re_d2 <= {(DW+2){1'b0}};
        out1_re_d3 <= {(DW+2){1'b0}};
        out1_im_d1 <= {(DW+2){1'b0}};
        out1_im_d2 <= {(DW+2){1'b0}};
        out1_im_d3 <= {(DW+2){1'b0}};
    end
    else begin
        out1_re_d1 <= out1_re_a;
        out1_re_d2 <= out1_re_d1;
        out1_re_d3 <= out1_re_d2;
        out1_im_d1 <= out1_im_a;
        out1_im_d2 <= out1_im_d1;
        out1_im_d3 <= out1_im_d2;
    end
end

assign out1_re = out1_re_d3;
assign out1_im = out1_im_d3;

///////////////////////////x[n+N/3]///////////////////////

complex_signed_mult u_complex_signed_mult_3_2 (
    .clk(clk),
    .n_rst(n_rst),
    .di_vld(di_vld),
    .d1_re(in2_re),
    .d1_im(in2_im),
    .d2_re(COS120[33:33-DW+3]),
    .d2_im(SIN120[33:33-DW+3]),
    .do_vld(do_vld),
    .do_re(c_in2_120_re),
    .do_im(c_in2_120_im)
);

complex_signed_mult u_complex_signed_mult_3_3 (
    .clk(clk),
    .n_rst(n_rst),
    .di_vld(di_vld),
    .d1_re(in3_re),
    .d1_im(in3_im),
    .d2_re(COS240[33:33-DW+3]),
    .d2_im(SIN240[33:33-DW+3]),
    .do_vld(do_vld),
    .do_re(c_in3_240_re),
    .do_im(c_in3_240_im)
);

add_input3 #( 
    .SIGN_BIT(SIGN_BIT),
    .INT_BIT(INT_BIT),
    .FLT_BIT(FLT_BIT)
) u_adder_input3_3 (
    .din_a(in1_re),
    .din_b(c_in2_120_re[DW:1]),
    .din_c(c_in3_240_re[DW:1]),
    .dout(out2_re_a)
); //x[n+N/3] re

add_input3 #( 
    .SIGN_BIT(SIGN_BIT),
    .INT_BIT(INT_BIT),
    .FLT_BIT(FLT_BIT)
) u_adder_input3_4 (
    .din_a(in1_im),
    .din_b(c_in2_120_im[DW:1]),
    .din_c(c_in3_240_im[DW:1]),
    .dout(out2_im_a)
); //x[n+N/3] im

reg [DW+1:0] out2_re_d1, out2_im_d1;

always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        out2_re_d1 <= {(DW+2){1'b0}};
        out2_im_d1 <= {(DW+2){1'b0}};
    end
    else begin
        out2_re_d1 <= out2_re_a;
        out2_im_d1 <= out2_im_a;
    end
end

assign out2_re = out2_re_d1;
assign out2_im = out2_im_d1;

//////////////////////////x[n+2N/3]////////////////////////////

complex_signed_mult u_complex_signed_mult_5_2 (
    .clk(clk),
    .n_rst(n_rst),
    .di_vld(di_vld),
    .d1_re(in2_re),
    .d1_im(in2_im),
    .d2_re(COS240[33:33-DW+3]),
    .d2_im(SIN240[33:33-DW+3]),
    .do_vld(do_vld),
    .do_re(c_in2_240_re),
    .do_im(c_in2_240_im)
);

complex_signed_mult u_complex_signed_mult_5_3 (
    .clk(clk),
    .n_rst(n_rst),
    .di_vld(di_vld),
    .d1_re(in3_re),
    .d1_im(in3_im),
    .d2_re(COS120[33:33-DW+3]),
    .d2_im(SIN120[33:33-DW+3]),
    .do_vld(do_vld),
    .do_re(c_in3_120_re),
    .do_im(c_in3_120_im)
);


add_input3 #( 
    .SIGN_BIT(SIGN_BIT),
    .INT_BIT(INT_BIT),
    .FLT_BIT(FLT_BIT)
) u_adder_input3_5 (
    .din_a(in1_re),
    .din_b(c_in2_240_re[DW:1]),
    .din_c(c_in3_120_re[DW:1]),
    .dout(out3_re_a)
); //x[n+2N/3] re

add_input3 #( 
    .SIGN_BIT(SIGN_BIT),
    .INT_BIT(INT_BIT),
    .FLT_BIT(FLT_BIT)
) u_adder_input3_6 (
    .din_a(in1_im),
    .din_b(c_in2_240_im[DW:1]),
    .din_c(c_in3_120_im[DW:1]),
    .dout(out3_im_a)
); //x[n+2N/3] im

reg [DW+1:0] out3_re_d1, out3_im_d1;

always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        out3_re_d1 <= {(DW+2){1'b0}};
        out3_im_d1 <= {(DW+2){1'b0}};
    end
    else begin
        out3_re_d1 <= out2_re_a;
        out3_im_d1 <= out2_im_a;
    end
end

assign out3_re = out3_re_d1;
assign out3_im = out3_im_d1;

endmodule