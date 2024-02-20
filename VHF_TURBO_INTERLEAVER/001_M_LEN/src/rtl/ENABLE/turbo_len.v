`timescale 1ps/1ps

module turbo_len (
    input clk,
    input n_rst,
    input id_enable,
    input [5:0] link_id,
    output [15:0] enable
);
    wire [12:0] m_len;

    id_encoder dut_id_encoder(
        .clk(clk),
        .n_rst(n_rst),
        .link_id(link_id),
        .id_enable(id_enable),
        .m_len(m_len)
    );

    gen_en dut_gen_en(
        .clk(clk),
        .n_rst(n_rst),
        .m_len(m_len),
        .enable(enable)
    );

endmodule