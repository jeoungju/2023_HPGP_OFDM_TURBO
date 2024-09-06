`timescale 1ps/1ps

module rom #(
    parameter D_WIDTH;
    parameter A_WIDTH;
    parameter SELECT;
    )(
	clk,
    n_rst,
	raddr,
    mod_int_dint,
	data_out
);



input	                   clk, n_rst;

input	    [A_WIDTH-1:0]  raddr;
input                      mod_int_dint;

output	reg [A_WIDTH-1:0]  data_out;

reg [D_WIDTH-1:0] ram [0:2**A_WIDTH-1];

// paraller deinterleaver rom
reg [A_WIDTH-1:0] rom_d_16_0 [0 : 2**A_WIDTH-1];
reg [A_WIDTH-1:0] rom_d_16_1 [0 : 2**A_WIDTH-1];
reg [A_WIDTH-1:0] rom_d_16_2 [0 : 2**A_WIDTH-1];
reg [A_WIDTH-1:0] rom_d_16_3 [0 : 2**A_WIDTH-1];

initial  begin
    $readmemh("../src/rtl/RX_ROM/pb_deint_rom0.txt", rom_d_16_0);
    $readmemh("../src/rtl/RX_ROM/pb_deint_rom1.txt", rom_d_16_1);
    $readmemh("../src/rtl/RX_ROM/pb_deint_rom2.txt", rom_d_16_2);
    $readmemh("../src/rtl/RX_ROM/pb_deint_rom3.txt", rom_d_16_3);
end

// paraller interleaver rom
reg [A_WIDTH-1:0] rom_i_16_0 [0 : 2**A_WIDTH-1];
reg [A_WIDTH-1:0] rom_i_16_1 [0 : 2**A_WIDTH-1];
reg [A_WIDTH-1:0] rom_i_16_2 [0 : 2**A_WIDTH-1];
reg [A_WIDTH-1:0] rom_i_16_3 [0 : 2**A_WIDTH-1];

initial  begin
    $readmemh("../src/rtl/RX_ROM/pb_int_rom0.txt", rom_i_16_0);
    $readmemh("../src/rtl/RX_ROM/pb_int_rom1.txt", rom_i_16_1);
    $readmemh("../src/rtl/RX_ROM/pb_int_rom2.txt", rom_i_16_2);
    $readmemh("../src/rtl/RX_ROM/pb_int_rom3.txt", rom_i_16_3);
end

always @(*) begin
    if (mod_int_dint == 1'b1) begin
        case (SELECT)
            0: data_out = rom_i_16_0[raddr];
            1: data_out = rom_i_16_1[raddr];
            2: data_out = rom_i_16_2[raddr];
            3: data_out = rom_i_16_3[raddr];
            default: data_out = {(A_WIDTH){1'b0}};
        endcase
    end 
    else begin
        case (SELECT)
            0: data_out = rom_d_16_0[raddr];
            1: data_out = rom_d_16_1[raddr];
            2: data_out = rom_d_16_2[raddr];
            3: data_out = rom_d_16_3[raddr];
            default: data_out = {(A_WIDTH){1'b0}};
        endcase
    end
end


endmodule