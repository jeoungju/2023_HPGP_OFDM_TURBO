`timescale 1ps/1ps

module pb_encoder (
    input clk,
    input n_rst,
    input [1:0] pb_size,
    output [11:0] len_l
);
    localparam PB_16 = 2'h0;
    localparam PB_136 = 2'h1;
    localparam PB_520 = 2'h2;

    reg [12:0] l;
    
    always @(posedge clk or negedge n_rst) begin
        if(!n_rst) begin
            l <= 12'h000;
        end
        else begin
            if(pb_size == PB_16) begin
                l <= 12'h040; //64
            end
            else if(pb_size == PB_136) begin
                l <= 12'h220; //544
            end
            else if(pb_size == PB_520) begin
                l <= 12'h820; //2080
            end
            else begin
                l <= 12'h000;
            end
        end
    end

    reg [12:0] len_l_d;
    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            len_l_d <= 12'h000;
        end
        else begin
            len_l_d <= l;
        end
    end

    assign len_l = len_l_d;

endmodule