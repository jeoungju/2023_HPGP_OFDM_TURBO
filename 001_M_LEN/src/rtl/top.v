`timescale 1ps/1ps
//TOP MODULE
module top (
    input clk,
    input n_rst,
    input id_enable,
    input [5:0] link_id,
    output [12:0] data
);
    wire [15:0] enable;
    //wire [12:0] m_len;

    rom dut_rom (
        .clk(clk),
        .n_rst(n_rst),
        .addr(enable),
        .data(data)
    );

    turbo_len dut_turbo_len (
        .clk(clk),
        .n_rst(n_rst),
        .id_enable(id_enable),
        .link_id(link_id),
        .enable(enable)
    );
endmodule