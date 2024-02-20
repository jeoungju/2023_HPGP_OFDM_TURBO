`timescale 1ps/1ps

module ram (
	clk,
    n_rst,
	wdata,
	raddr,
	waddr,
	wen,
    ren,
	rdata
);

parameter D_WIDTH = 2;
parameter A_WIDTH = 12;

input	                   clk, n_rst;
input	    [A_WIDTH-1:0]  waddr;
input	                   wen; //write enable
input	    [D_WIDTH-1:0]  wdata;

input	    [A_WIDTH-1:0]  raddr;
input                      ren; //read enable
output	reg [D_WIDTH-1:0]  rdata;

reg [D_WIDTH-1:0] ram [0:2**A_WIDTH-1];

always @(posedge clk or negedge n_rst) begin
    if(wen == 1'b1) begin
        ram[waddr] <= wdata;
    end
end

always @(posedge clk or negedge n_rst) begin
    if(ren == 1'b1) begin
        rdata <= ram[raddr];
    end
end

endmodule