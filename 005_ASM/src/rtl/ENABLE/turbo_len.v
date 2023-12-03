`timescale 1ps/1ps
///////////////////////////////////////
///////////ASM INTERLEAVER/////////////
///////////////////////////////////////

module turbo_len (
    input clk,
    input n_rst,
    input din_vld,
    input request,
    input [5:0] link_id,
    output [15:0] enable,
    output [15:0] id_offset,
    output wen,
    output dout_vld
);
    wire [12:0] m_len;

    id_encoder dut_id_encoder(
        .clk(clk),
        .n_rst(n_rst),
        .link_id(link_id),
        .m_len(m_len)
    );

    gen_en dut_gen_en(
        .clk(clk),
        .n_rst(n_rst),
        .din_vld(din_vld),
        .request(request),
        .m_len(m_len),
        .enable(enable),
        .id_offset(id_offset),
        .wen(wen),
        .dout_vld(dout_vld)
    );

endmodule