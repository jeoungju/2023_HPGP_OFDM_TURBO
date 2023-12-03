`timescale 1ps/1ps
module testbench();
    reg clk;
    reg n_rst;
    reg id_enable;
    reg [5:0] link_id;
    wire [12:0] data;

    top dut_top(
        .clk(clk),
        .n_rst(n_rst),
        .id_enable(id_enable),
        .link_id(link_id),
        .enable(enable)
    );

    always #5 clk = ~clk;
    initial begin
        clk = 1'b0;
        n_rst = 1'b0;
        #7 n_rst = 1'b1;
    end

    initial begin
        id_enable = 1'b0;
        link_id = 6'h00;
        #20;
        link_id = 6'h14;
        #10;
        id_enable = 1'b1;
        #10;
        id_enable = 1'b0;
        link_id = 6'h00;
        #1100;

        $stop;

    end


endmodule