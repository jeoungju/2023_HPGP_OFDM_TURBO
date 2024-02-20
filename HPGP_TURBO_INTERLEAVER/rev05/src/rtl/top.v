`timescale 1ps/1ps
//TOP MODULE
module top (
    input clk,
    input n_rst,
    input [1:0] pb_size,
    input [1:0] din,
    input din_vld,
    output [1:0] rdata,
    output [1:0] rdata_itl,
    //output rdata_ditl,
    output dout_vld
);
    wire [11:0] enable;
    wire [11:0] pb_offset;
    wire din_vld_r;
    wire wen_t;

    ram_dual dut_ram_dual (
        .clk(clk),
        .n_rst(n_rst),
        .wdata(din),
        .waddr(enable),
        .pb_offset(pb_offset),
        .wen(wen_t),
        .rdata(rdata),
        .rdata_itl(rdata_itl),
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
        .dout_vld(din_vld_r)
    );

endmodule