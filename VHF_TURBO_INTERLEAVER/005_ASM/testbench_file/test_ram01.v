`timescale 1ps/1ps
module testbench();
    reg clk;
    reg n_rst;
    reg [5:0] link_id;
    reg [12:0] din;
    reg din_vld;
    reg request;
    reg wen;

    wire [12:0] rdata;
    wire [12:0] rdata_itl;

    top dut_top(
        .clk(clk),
        .n_rst(n_rst),
        .link_id(link_id),
        .din(din),
        .din_vld(din_vld),
        .request(request),
        .rdata(rdata),
        .rdata_itl(rdata_itl),
        .wen(wen)
    );

    always #5 clk = ~clk;
    initial begin
        clk = 1'b0;
        n_rst = 1'b0;
        #7 n_rst = 1'b1;
    end

    initial begin
        din = 13'h0000;
        din_vld = 1'b0;
        link_id = 6'h00;
        request = 1'b0;
        wen = 1'b0;
        #27;
        link_id = 6'h03;
        #10;
        din_vld = 1'b1;
        wen = 1'b1;
        #10;
        din = 13'h0_0001; //
        #10;
        din = 13'h0_0002; //
        din_vld = 1'b0;
        #10;
        din = 13'h0_0003; //
        #10;
        din = 13'h0_0004; //
        #10;
        din = 13'h0_0005; //
        #10;
        din = 13'h0_0006; //
        #10;
        din = 13'h0_0007; //
        #10;
        din = 13'h0_0008; //
        #10;
        din = 13'h0_0009; //
        #10;
        din = 13'h0_000a; //
        #10;
        wen = 1'b0;
        #100;

        request = 1'b1;
        #10;
        request = 1'b0;
        #300;

        $stop;

    end


endmodule


