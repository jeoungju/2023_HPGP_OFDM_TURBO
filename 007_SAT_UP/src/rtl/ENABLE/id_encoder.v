`timescale 1ps/1ps
//m_len data according to Link Id
///////////////////////////////////////
/////////SAT-UPLINK INTERLEAVER////////
///////////////////////////////////////

module id_encoder (
    input clk,
    input n_rst,
    input [5:0] link_id,
    output [12:0] m_len
);
    localparam ID3 = 6'h03; //example
    localparam ID4 = 6'h04;
    localparam ID5 = 6'h05;
    localparam ID6 = 6'h06;
    localparam ID7 = 6'h07;
    localparam ID8 = 6'h08;
    localparam ID9 = 6'h09;
    localparam ID10 = 6'h0a;
    localparam ID11 = 6'h0b;
    localparam ID12 = 6'h0c;
    localparam ID13 = 6'h0d;
    localparam ID14 = 6'h0e;
    localparam ID15 = 6'h0f;
    localparam ID16 = 6'h10;
    localparam ID17 = 6'h11;
    localparam ID18 = 6'h12;
    localparam ID19 = 6'h13;
    localparam ID20 = 6'h14;
    localparam ID21 = 6'h15;
    localparam ID22 = 6'h16;
    localparam ID23 = 6'h17;
    localparam ID24 = 6'h18;
    localparam ID25 = 6'h19;
    localparam ID26 = 6'h1a;
    localparam ID27 = 6'h1b;
    localparam ID28 = 6'h1c;
    localparam ID29 = 6'h1d;
    localparam ID30 = 6'h1e;
    localparam ID31 = 6'h1f;
    localparam ID32 = 6'h20;
    localparam ID33 = 6'h21;
    localparam ID34 = 6'h22;

    reg [12:0] k;
    
    always @(posedge clk or negedge n_rst) begin
        if(!n_rst) begin
            k <= 13'h0000;
        end
        else begin
            if(link_id == ID4) begin
                k <= 13'h03c0;
            end
            else if(link_id == ID3) begin
                k <= 13'h000a; //example
            end
            else if(link_id == ID5) begin
                k <= 13'h0120;
            end
            else if(link_id == ID6) begin
                k <= 13'h02a0;
            end
            else if(link_id == ID7) begin
                k <= 13'h0420;
            end
            else if(link_id == ID8) begin
                k <= 13'h00c0;
            end
            else if(link_id == ID9) begin
                k <= 13'h01c0;
            end
            else if(link_id == ID10) begin
                k <= 13'h02c0;
            end
            else if(link_id == ID11) begin
                k <= 13'h01b0;
            end
            else if(link_id == ID12) begin
                k <= 13'h03cc;
            end
            else if(link_id == ID13) begin
                k <= 13'h0510;
            end
            else if(link_id == ID14) begin
                k <= 13'h0380;
            end
            else if(link_id == ID15) begin
                k <= 13'h07e0;
            end
            else if(link_id == ID16) begin
                k <= 13'h0a80;
            end
            else if(link_id == ID17) begin
                k <= 13'h0750;
            end
            else if(link_id == ID18) begin
                k <= 13'h0fc0;
            end
            else if(link_id == ID19) begin
                k <= 13'h15f0;
            end
            else if(link_id == ID20) begin
                k <= 13'h0060;
            end
            else if(link_id == ID21) begin
                k <= 13'h02e0;
            end
            else if(link_id == ID22) begin
                k <= 13'h0c30;
            end
            else if(link_id == ID23) begin
                k <= 13'h11c0;
            end
            else if(link_id == ID24) begin
                k <= 13'h0ecc;
            end
            else if(link_id == ID25) begin
                k <= 13'h12a8;
            end
            else if(link_id == ID26) begin
                k <= 13'h1550;
            end
            else if(link_id == ID27) begin
                k <= 13'h1790;
            end
            else if(link_id == ID28) begin
                k <= 13'h14a0;
            end
            else if(link_id == ID29) begin
                k <= 13'h15b0;
            end
            else if(link_id == ID30) begin
                k <= 13'h14c8;
            end
            else if(link_id == ID31) begin
                k <= 13'h14d0;
            end
            else if(link_id == ID32) begin
                k <= 13'h0138;
            end
            else if(link_id == ID33) begin
                k <= 13'h10b8;
            end
            else if(link_id == ID34) begin
                k <= 13'h1040;
            end
            else begin
                k <= 13'h0000;
            end
        end
    end

    reg [12:0] m_len_d;
    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            m_len_d <= 13'h0000;
        end
        else begin
            m_len_d <= k;
        end
    end

    assign m_len = m_len_d;

endmodule