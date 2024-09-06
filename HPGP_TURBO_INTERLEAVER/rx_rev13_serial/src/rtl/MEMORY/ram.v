`timescale 1ps/1ps

module ram #(
    parameter D_WIDTH,
    parameter A_WIDTH
    )(
	clk,
    n_rst,
    waddr,
    wdata,
    wen,
    raddr,
    rdata
);

input	                   clk, n_rst;

input	    [A_WIDTH-1:0]  waddr;
input                      wen; //read enable
input	    [D_WIDTH-1:0]  wdata;

input	    [A_WIDTH-1:0]  raddr;
output	reg [D_WIDTH-1:0]  rdata;

reg [D_WIDTH-1:0] ram [0:2**A_WIDTH-1];

always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            rdata <= {(D_WIDTH){1'b0}};
        end else begin
            if (wen == 1'b1) begin
                ram[waddr] <= wdata;
            end
            rdata <= ram[raddr];
        end
    end

endmodule