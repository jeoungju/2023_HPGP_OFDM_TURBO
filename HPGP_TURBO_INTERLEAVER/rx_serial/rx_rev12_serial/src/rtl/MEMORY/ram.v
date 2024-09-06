`timescale 1ps/1ps

module ram #(
    parameter D_WIDTH,
    parameter A_WIDTH
    )(
	clk,
    n_rst,
    ren,
    raddr,
    rdata,
    wen,
    waddr,
    wdata
);

input	                   clk, n_rst;

input	    [A_WIDTH-1:0]  raddr;
input                      ren; //read enable
output	reg [D_WIDTH-1:0]  rdata;

input	    [A_WIDTH-1:0]  waddr;
input                      wen; //write enable
input       [D_WIDTH-1:0]  wdata;

reg [D_WIDTH-1:0] ram [0:2**A_WIDTH-1];

initial begin
    $readmemh("../src/rtl/RAM/ram.txt", ram);
end

always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            rdata <= {(D_WIDTH){1'b0}};
        end else begin
            if (wen == 1'b1) begin
                ram[waddr] <= wdata;
            end
            if(ren == 1'b1) begin
                rdata <= ram[raddr];
            end
        end
    end


/*
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
    if(wen == 1'b1) begin
        ram[SELECT][waddr] <= wdata;
    end
end
*/
endmodule