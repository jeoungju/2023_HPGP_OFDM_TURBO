`timescale 1ps/1ps

module testbench();

    reg clk;
    reg n_rst;
    reg [1:0] wdata;
    reg [11:0] waddr;
    reg [11:0] pb_offset;
    reg [11:0] pb_len;
    reg wen;
    reg din_vld;
    reg start;
    reg mod_int_dint;

    wire [1:0] rdata0;
    wire [1:0] rdata1;
    wire [1:0] rdata2;
    wire [1:0] rdata3;
    //wire [1:0] rdata_itl;
    //wire rdata_ditl;
    wire dout_vld;

    turbo_rx dut_turbo_rx(
        .clk(clk),
        .n_rst(n_rst),
        .wdata(wdata),
        .waddr(waddr),
        .pb_offset(pb_offset),
        .pb_len(pb_len),
        .wen(wen),
        .din_vld(din_vld),
        .start(start),
        .mod_int_dint(mod_int_dint),
        .rdata0(rdata0),
        .rdata1(rdata1),
        .rdata2(rdata2),
        .rdata3(rdata3),
        .dout_vld(dout_vld)
    );

    always #5 clk = ~clk;
    initial begin
        clk = 1'b0;
        n_rst = 1'b0;
        #7 n_rst = 1'b1;
    end

    initial begin
        wdata = 2'b00;
        waddr = 12'h0;
        pb_offset = 12'h00;
        pb_len = 12'h00;
        wen = 1'b0;
        din_vld = 1'b0;
        start = 1'b0;
        mod_int_dint = 1'b0;
        #27;

        pb_len = 12'h40;
        din_vld = 1'b1;
        start = 1'b1;
        mod_int_dint = 1'b1;
        #10;
        start = 1'b0;

        #150;
        din_vld = 1'b0;

        #50;

        pb_len = 12'h220;
        din_vld = 1'b1;
        start = 1'b1;
        mod_int_dint = 1'b1;
        #10;
        start = 1'b0;

        #1350;
        din_vld = 1'b0;

        #50;

        $stop;
    end
endmodule

