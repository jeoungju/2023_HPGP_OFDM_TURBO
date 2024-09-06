`timescale 1ps/1ps

module ram #(
    parameter D_WIDTH;
    parameter A_WIDTH;
    parameter SELECT;
    )(
	clk,
    n_rst,
    ren,
    raddr,
    rdata
);

input	                   clk, n_rst;

input	    [A_WIDTH-1:0]  raddr;
input                      ren; //read enable
output	reg [D_WIDTH-1:0]  rdata;

reg [D_WIDTH-1:0] ram[0:3][0:2**A_WIDTH-1];

initial begin
    case (SELECT)
        0: $readmemh("../src/rtl/RAM/ram0.txt", ram[0]);
        1: $readmemh("../src/rtl/RAM/ram1.txt", ram[1]);
        2: $readmemh("../src/rtl/RAM/ram2.txt", ram[2]);
        3: $readmemh("../src/rtl/RAM/ram3.txt", ram[3]);
        default: $readmemh("../src/rtl/RAM/ram0.txt", ram[0]);
    endcase
end

always @(posedge clk or negedge n_rst) begin
    if(ren == 1'b1) begin
        rdata <= ram[SELECT][raddr];
    end
end

endmodule