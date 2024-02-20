`timescale 1ps/1ps
///////////////////////////////////////
/////////SAT-UPLINK INTERLEAVER////////
///////////////////////////////////////

module ram_dual # (
    parameter D_WIDTH = 1,
    parameter A_WIDTH = 16
    )
    (
	input           clk,
    input           n_rst,
	input           wdata,
    input [15:0]    waddr,

    input [15:0]    id_offset,

	output          rdata,
    output          rdata_itl,
    output          rdata_ditl,

    input wen
    //input request
);



reg	                rdata_d;      //original data
reg	                rdata_itl_d;  //interleaver data
reg	                rdata_ditl_d; //deinterleaver data

// din store ram
reg                 ram[0 : 2**A_WIDTH-1];

reg [A_WIDTH-1:0]   rom_itl [0 : 2**A_WIDTH-1];
reg [A_WIDTH-1:0]   rom_ditl [0 : 2**A_WIDTH-1];

// address rom
initial  begin
    $readmemh("../src/rtl/MEMORY/sat_up_pi.txt", rom_itl);
    $readmemh("../src/rtl/MEMORY/sat_up_depi.txt", rom_ditl);
end

reg [A_WIDTH-1:0]   itl_addr_d;
wire [A_WIDTH-1:0]  addr; //
assign              addr = waddr + id_offset;

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

//
wire [A_WIDTH-1:0]   itl_addr_dd;
assign               itl_addr_dd = itl_addr_d-16'h1;

wire [A_WIDTH-1:0]   ditl_addr_d;
assign               ditl_addr_d = itl_addr_dd + id_offset; 

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
        rdata_itl_d <=  ram[itl_addr_dd];
    end
end
/////////////deinterleaver addr/////////////////
reg [A_WIDTH-1:0] ditl_addr_rom;
always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        ditl_addr_rom <= {(D_WIDTH){1'b0}};
    end
    else begin
        ditl_addr_rom <= rom_ditl[ditl_addr_d];
    end
end
/////////////deinterleaver data/////////////////
wire [A_WIDTH-1:0]   ditl_addr_dd;
assign               ditl_addr_dd = ditl_addr_rom-16'h1;

always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        rdata_ditl_d <= {(D_WIDTH){1'b0}};
    end
    else begin
        rdata_ditl_d <= ram[ditl_addr_dd];
    end
end


assign rdata = rdata_d;
assign rdata_itl = rdata_itl_d;
assign rdata_ditl = rdata_ditl_d;

endmodule