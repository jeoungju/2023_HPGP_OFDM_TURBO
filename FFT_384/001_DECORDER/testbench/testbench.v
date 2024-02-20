`timescale 1ps/1ps
module testbench();

parameter D_WIDTH = 4;
parameter A_WIDTH = 9;
parameter COS_SIN = 16;


reg clk, n_rst;
reg [A_WIDTH-1:0]din_num;
reg din_vld;

wire [COS_SIN*2-1:0] dout;
wire dout_vld;


always #5 clk = ~clk;
    initial begin
        clk = 1'b0;
        n_rst = 1'b0;
        #7 n_rst = 1'b1;
    end

initial begin
    din_num = 9'd0;
    din_vld = 1'b0;
    #33;
    //din_num = 0
    din_vld = 1'b1;
    #10;
    din_num = 9'd1;
    #10;
    din_num = 9'd2;
    #10;
    din_num = 9'd3;
    #10;
    din_num = 9'd4;
    #10;
    din_num = 9'd5;
    #10;
    din_num = 9'd6;
    #10;
    din_num = 9'd7;
    #10;
    din_num = 9'd8;
    #10;
    din_num = 9'd9;
    #10;
    din_num = 9'd10;
    #10;
    din_num = 9'd11;
    #10;
    din_num = 9'd12;
    #10;
    din_num = 9'd13;
    #10;
    din_num = 9'd14;
    #10;
    din_num = 9'd15;
    #10;
    din_num = 9'd16;
    #10;
    din_num = 9'd17;
    #10;
    din_num = 9'd18;
    #10;
    din_num = 9'd19;
    #10;
    din_num = 9'd20;
    #10;
    din_num = 9'd21;
    #10;
    din_num = 9'd22;
    #10;
    din_num = 9'd23;
    #10;
    din_num = 9'd24;
    #10;
    din_num = 9'd25;
    #10;
    din_num = 9'd26;
    #10;
    din_num = 9'd27;
    #10;
    din_num = 9'd28;
    #10;
    din_num = 9'd29;
    #10;
    din_num = 9'd30;
    #10;
    din_num = 9'd31;
    #10;
    din_num = 9'd32;
    #10;
    din_num = 9'd33;
    #10;
    din_num = 9'd34;
    #10;
    din_num = 9'd35;
    #10;
    din_num = 9'd36;
    #10;
    din_num = 9'd37;
    #10;
    din_num = 9'd38;
    #10;
    din_num = 9'd39;
    #10;
    din_num = 9'd40;
    #10;
    din_num = 9'd41;
    #10;
    din_num = 9'd42;
    #10;
    din_num = 9'd43;
    #10;
    din_num = 9'd44;
    #10;
    din_num = 9'd45;
    #10;
    din_num = 9'd46;
    #10;
    din_num = 9'd47;
    #10;
    din_num = 9'd48;
    #10;
    din_num = 9'd49;
    #50;




    $stop;
end

rom_384 dut_rom_384 (
	.clk(clk),
	.n_rst(n_rst),
	.din_num(din_num),
	.din_vld(din_vld),
	.dout(dout), 
	.dout_vld(dout_vld)
);

endmodule
