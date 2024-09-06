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

	output [D_WIDTH-1:0]    rdata,
    output [D_WIDTH-1:0]    rdata_ditl,

    input                   wen,
    input                   din_vld,
    output                  dout_vld
);


wire  [A_WIDTH-1:0]   ditl_addr;
reg  [A_WIDTH-1:0]   ditl_addr_d;
wire [A_WIDTH-1:0]  addr; //
assign              addr = waddr + pb_offset;


rom #(
    .D_WIDTH(0),
    .A_WIDTH(12)
) dut_rom (
	.clk(clk),
    .n_rst(n_rst),
	.raddr(addr),
	.data_out(ditl_addr)
);

always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        ditl_addr_d <= {(A_WIDTH){1'b0}};
    end
    else begin
        ditl_addr_d <= ditl_addr;
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


ram #(
    .D_WIDTH(2),
    .A_WIDTH(12)
) dut_ram_origin (
	.clk(clk),
    .n_rst(n_rst),
    .waddr(waddr),
    .wdata(wdata),
    .wen(wen),
    .raddr(waddr_d),
    .rdata(rdata)
);

ram #(
    .D_WIDTH(2),
    .A_WIDTH(12)
    ) dut_ram_ditl (
	.clk(clk),
    .n_rst(n_rst),
    .waddr(waddr),
    .wdata(wdata),
    .wen(wen),  
    .raddr(ditl_addr_d),
    .rdata(rdata_ditl)
);

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

assign dout_vld = dout_vld_dd;

endmodule