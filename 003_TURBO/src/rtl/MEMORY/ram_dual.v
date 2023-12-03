`timescale 1ps/1ps
module ram_dual(
	input clk,
    input n_rst,
	input wdata,
    input [15:0] waddr,

    input [15:0] id_jump,

	output rdata,
    output rdata_itl,

    input wen
    //input request
);

parameter D_WIDTH = 1;
parameter A_WIDTH = 16;

reg	rdata_d;
reg	rdata_itl_d;

reg ram[0 : 2**A_WIDTH-1];

reg [A_WIDTH-1:0] rom_itl [0 : 2**A_WIDTH-1];

initial  begin
    $readmemh("../src/rtl/MEMORY/ter_pi.txt", rom_itl);
    //$readmemh("../src/rtl/MEMORY/prac.txt", rom_itl);
end

reg [A_WIDTH-1:0]   itl_addr_d;
wire [A_WIDTH-1:0]  addr; //
assign addr = waddr + id_jump;
always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        itl_addr_d <= 13'h0000;
    end
    else begin
        itl_addr_d <= rom_itl[addr];
    end
end


//write ram
always @(posedge clk or negedge n_rst) begin
    if(wen == 1'b1) begin
        ram[waddr] <= wdata;
    end
end

//waddr i clock delay
reg [A_WIDTH-1:0] waddr_d;
always @(posedge clk or negedge n_rst) begin
    if(!n_rst) begin
        waddr_d <= {(A_WIDTH){1'b0}};
    end
    else begin
        waddr_d <= waddr;
    end
end


always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        rdata_d <= {(D_WIDTH){1'b0}};
        rdata_itl_d <= {(D_WIDTH){1'b0}};
    end
    else begin
        //rdata_d <= (wen == 1'b0) ? ram[waddr_d] : rdata_d;
        //rdata_itl_d <= (wen == 1'b0) ? ram[itl_addr_d-16'h1] : rdata_itl_d;
        rdata_d <=  ram[waddr_d];
        rdata_itl_d <=  ram[itl_addr_d-16'h1];
    end
end

assign rdata = rdata_d;
assign rdata_itl = rdata_itl_d;

endmodule