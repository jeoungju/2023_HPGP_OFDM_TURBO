`timescale 1ps/1ps

module rom #(
    parameter D_WIDTH,
    parameter A_WIDTH
    )(
	clk,
    n_rst,
	raddr,
	data_out
);



input	                   clk, n_rst;

input	    [A_WIDTH-1:0]  raddr;

output	    [A_WIDTH-1:0]  data_out;


reg [A_WIDTH-1:0]           rom_itl [0 : 2**A_WIDTH-1];

// address rom
initial  begin
    $readmemh("../src/rtl/TX_ROM/pb_interleav.txt", rom_itl);
end

assign data_out = rom_itl[raddr];

endmodule