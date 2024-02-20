`timescale 1ps/1ps
///////////////////////////////////////
/////////SAT-UPLINK INTERLEAVER////////
///////////////////////////////////////
//TOP MODULE
module top (
    input clk,
    input n_rst,
    input [5:0] link_id,
    input din,
    input din_vld,
    input request,
    output rdata,
    output rdata_itl,
    output rdata_ditl,
    output dout_vld
    //input wen
);
    wire [15:0] enable;
    wire [15:0] id_offset;
    wire wen;
    //wire [12:0] m_len;

    ram_dual dut_ram_dual (
        .clk(clk),
        .n_rst(n_rst),
        .wdata(din),
        .waddr(enable),
        .id_offset(id_offset),
        .rdata(rdata),
        .rdata_itl(rdata_itl),
        .rdata_ditl(rdata_ditl),
        .wen(wen)
    );

    turbo_len dut_turbo_len (
        .clk(clk),
        .n_rst(n_rst),
        .din_vld(din_vld),
        .request(request),
        .link_id(link_id),
        .enable(enable),
        .id_offset(id_offset),
        .wen(wen),
        .dout_vld(dout_vld)
    );

    
endmodule