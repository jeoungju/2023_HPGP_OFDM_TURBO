`timescale 1ps/1ps
//TOP MODULE
module top (
    input clk,
    input n_rst,
    input [1:0] pb_size,
    input [1:0] din,
    input din_vld,
    input start,
    input mod_int_dint,

    output [1:0] rdata0,
    output [1:0] rdata1,
    output [1:0] rdata2,
    output [1:0] rdata3,
    //output [1:0] rdata_itl,
    //output rdata_ditl,
    output dout_vld
);
    wire [11:0] enable;
    wire [11:0] pb_offset;
    wire [11:0] pb_len;
    wire din_vld_r;
    wire wen_t;

    turbo_rx dut_turbo_rx (
        .clk(clk),
        .n_rst(n_rst),
        .wdata(din),
        .waddr(enable),
        .pb_offset(pb_offset),
        .pb_len(pb_len),
        .wen(wen_t),
        .start(start),
        .mod_int_dint(mod_int_dint),
        .rdata0(rdata0),
        .rdata1(rdata1),
        .rdata2(rdata2),
        .rdata3(rdata3),
        //.rdata_itl(rdata_itl),
        .din_vld(din_vld_r),
        .dout_vld(dout_vld)
    );

    turbo_len dut_turbo_len (
        .clk(clk),
        .n_rst(n_rst),
        .din_vld(din_vld),
        .pb_size(pb_size),
        .enable(enable),
        .wen(wen_t),
        .pb_offset(pb_offset),
        .pb_len(pb_len),
        .dout_vld(din_vld_r)
    );

endmodule
