`timescale 1ps/1ps

module testbench();

    reg clk;
    reg n_rst;
    reg [1:0] pb_size;
    reg [1:0] din;
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

    top dut_top(
        .clk(clk),
        .n_rst(n_rst),
        .pb_size(pb_size),
        .din(din),
        .din_vld(din_vld),
        .start(start),
        .mod_int_dint(mod_int_dint),
        .rdata0(rdata0),
        .rdata1(rdata1),
        .rdata2(rdata2),
        .rdata3(rdata3),
        //.rdata_itl(rdata_itl),
        //.rdata_ditl(rdata_ditl),
        .dout_vld(dout_vld)
    );

    always #5 clk = ~clk;
    initial begin
        clk = 1'b0;
        n_rst = 1'b0;
        #7 n_rst = 1'b1;
    end

    initial begin
        //input set
        pb_size = 2'h0;
        din = 2'b00;
        din_vld = 1'b0;
        start = 1'b0;
        mod_int_dint = 1'b0;
        #27;

        mod_int_dint = 1'b1;
        din_vld = 1'b1;
        #10;
        din_vld = 1'b0;
        #640;

        start = 1'b1;
        #10;
        start = 1'b0;
        #200;

        pb_size = 2'h1;
        #10;
        din_vld = 1'b1;
        #10;
        din_vld = 1'b0;
        #5440;
        start = 1'b1;
        #10;
        start = 1'b0;
        #1400;

        pb_size = 2'h2;
        #10;
        din_vld = 1'b1;
        #10;
        din_vld = 1'b0;
        #20800;
        start = 1'b1;
        #10;
        start = 1'b0;
        #5200;

        $stop;
    end
endmodule

