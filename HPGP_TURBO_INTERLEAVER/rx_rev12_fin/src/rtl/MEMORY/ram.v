`timescale 1ps/1ps

module ram #(
    parameter D_WIDTH,
    parameter A_WIDTH,
    parameter SELECT
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

reg [D_WIDTH-1:0] ram0 [0:2**A_WIDTH-1];
reg [D_WIDTH-1:0] ram1 [0:2**A_WIDTH-1];
reg [D_WIDTH-1:0] ram2 [0:2**A_WIDTH-1];
reg [D_WIDTH-1:0] ram3 [0:2**A_WIDTH-1];

initial begin
    case (SELECT)
        0: $readmemh("../src/rtl/RAM/ram0.txt", ram0);
        1: $readmemh("../src/rtl/RAM/ram1.txt", ram1);
        2: $readmemh("../src/rtl/RAM/ram2.txt", ram2);
        3: $readmemh("../src/rtl/RAM/ram3.txt", ram3);
        default: $readmemh("../src/rtl/RAM/ram0.txt", ram0);
    endcase
end

always @(posedge clk or negedge n_rst) begin
    if (SELECT == 0) begin
        if(ren == 1'b1) begin
            rdata <= ram0[raddr];
        end
        if(wen == 1'b1) begin
            ram0[waddr] <= wdata;
        end
    end
    else if (SELECT == 1) begin
        if(ren == 1'b1) begin
            rdata <= ram1[raddr];
        end
        if(wen == 1'b1) begin
            ram1[waddr] <= wdata;
        end
    end
    else if (SELECT == 2) begin
        if(ren == 1'b1) begin
            rdata <= ram2[raddr];
        end
        if(wen == 1'b1) begin
            ram2[waddr] <= wdata;
        end
    end
    else if (SELECT == 3) begin
        if(ren == 1'b1) begin
            rdata <= ram3[raddr];
        end
        if(wen == 1'b1) begin
            ram3[waddr] <= wdata;
        end
    end
    else begin
        if(ren == 1'b1) begin
            rdata <= ram[raddr];
        end
        if(wen == 1'b1) begin
            ram[waddr] <= wdata;
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