`timescale 1ps/1ps

module turbo_len (
    input clk,
    input n_rst,
    input din_vld,
    input [1:0] pb_size,
    output [11:0] enable,
    output [11:0] pb_offset,
    output dout_vld
);
    wire [11:0] len_l;

    pb_encoder dut_pb_encoder(
        .clk(clk),
        .n_rst(n_rst),
        .pb_size(pb_size),
        .len_l(len_l)
    );

    gen_en dut_gen_en(
        .clk(clk),
        .n_rst(n_rst),
        .din_vld(din_vld),
        .len_l(len_l),
        .enable(enable),
        .pb_offset(pb_offset),
        .dout_vld(dout_vld)
    );

endmodule