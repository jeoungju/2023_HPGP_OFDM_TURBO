`timescale 1ps/1ps
//-----HPGP INTERLEAVER------

module ram_dual # (
    parameter D_WIDTH = 2,
    parameter A_WIDTH = 12
    )
    (
	input                   clk,
    input                   n_rst,
	input [D_WIDTH-1:0]     wdata,
    input [A_WIDTH-1:0]     waddr,

    input [A_WIDTH-1:0]     pb_offset,
    input                   wen,

	output [D_WIDTH-1:0]    rdata,
    output [D_WIDTH-1:0]    rdata_itl,

    input                   din_vld,
    output                  dout_vld
);



reg	[D_WIDTH-1:0]           rdata_d;      //original data
reg	[D_WIDTH-1:0]           rdata_itl_d;  //interleaver data
wire [D_WIDTH-1:0]           rdata_itl_mod;

// din store ram
reg [D_WIDTH-1:0]           ram [0 : 2**A_WIDTH-1];

reg [A_WIDTH-1:0]           rom_itl [0 : 2**A_WIDTH-1];


// address rom
initial  begin
    $readmemh("../src/rtl/ROM/pb_interleav.txt", rom_itl);
end

reg  [A_WIDTH-1:0]   itl_addr_d;
wire [A_WIDTH-1:0]  addr; //
assign              addr = waddr + pb_offset;

always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        itl_addr_d <= {(A_WIDTH){1'b0}};
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
reg [A_WIDTH-1:0] waddr_dd; //output mod2 change
always @(posedge clk or negedge n_rst) begin
    if(!n_rst) begin
        waddr_d <= {(A_WIDTH){1'b0}};
        waddr_dd <= {(A_WIDTH){1'b0}};
    end
    else begin
        waddr_d <= waddr;
        waddr_dd <= waddr_d;
    end
end


wire [A_WIDTH-1:0]   ditl_addr_d;
assign               ditl_addr_d = itl_addr_d + pb_offset; 

////////////////original data//////////////////
always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        rdata_d <= {(D_WIDTH){1'b0}};      
    end
    else begin
        rdata_d <=  ram[waddr_d];
    end
end
//////////////interleaver data/////////////////
always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        rdata_itl_d <= {(D_WIDTH){1'b0}};   
    end
    else begin
        rdata_itl_d <=  ram[itl_addr_d];
    end
end


reg dout_vld_d, dout_vld_dd;
always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        dout_vld_d <= 1'b0;
        dout_vld_dd <= 1'b0;
    end
    else begin
        dout_vld_d <= din_vld;
        dout_vld_dd <= dout_vld_d;
    end
end


assign rdata = rdata_d;
assign rdata_itl = (waddr_dd[0] == 1'b0) ? {rdata_itl_d[0],rdata_itl_d[1]} : rdata_itl_d;

assign dout_vld = dout_vld_dd;

endmodule