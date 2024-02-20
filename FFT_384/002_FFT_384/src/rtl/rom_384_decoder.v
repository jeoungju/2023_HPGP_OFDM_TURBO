`timescale 1ps/1ps
//------- fft 384 mux --------

module rom_384_decoder (
	clk,
	n_rst,
	din_num, // Carrier Number, din 0-383 => 9bit
	din_vld,
	dout, // data = {cos,sin}
	dout_vld
);

parameter D_WIDTH = 4;
parameter A_WIDTH = 8;
parameter COS_SIN = 1 + 1 + 14;

// din 10-153 => 8bit

// SIGN_BIT 1 + INT_BIT 1 + FLT_BIT 14
//  cos parameter
localparam COS_0 = 16'b0_1_00_0000_0000_0000;
//  1.0
localparam COS_PI_8 = 16'b0_0_11_1011_0010_0000;
//  0.923880
localparam COS_PI_4 = 16'b0_0_10_1101_0100_0001;
//  0.707107
//  sin parameter
localparam SIN_0 = 16'b0_0_00_0000_0000_0000;
//  0.0
localparam SIN_PI_8 = 16'b0_0_01_1000_0111_1101;
//  0.382683

localparam M_COS_0 = 16'b1_1_00_0000_0000_0000;
localparam M_COS_PI_8 = 16'b1_1_00_0100_1110_0000;
localparam M_COS_PI_4 = 16'b1_1_01_0010_1011_1111;
localparam M_SIN_PI_8 = 16'b1_1_10_0111_1000_0011;
localparam M_SIN_0 = 16'b0_0_00_0000_0000_0000;

input clk;
input n_rst;
input [8:0] din_num; // Carrier Number, din 0-383 => 9bit

input din_vld;

output [COS_SIN*2-1:0] dout; // data = {cos,sin}
output dout_vld;


reg [D_WIDTH-1:0] rom_cell [0:2**A_WIDTH-1];
reg [D_WIDTH-1:0] data_f;

// address rom
initial  begin
    $readmemh("../src/rtl/rom_384_angle.txt", rom_cell);
	//$readmemh("../src/rtl/rom_384_addr.txt", rom_cell);
end

// rom-addr match
wire [A_WIDTH-1:0] addr;
assign addr = din_num;
always @(posedge clk or negedge n_rst) begin
	if (!n_rst) begin
		data_f <= {(D_WIDTH){1'b0}};
	end
	else begin
		data_f <= rom_cell[addr];
	end
end

reg [COS_SIN-1:0] dout_re, dout_im;
always @(*) begin
	case(data_f)
		4'h0 : begin
			dout_re = COS_0;
			dout_im = SIN_0;
		end
		4'h1 : begin
			dout_re = COS_PI_8;
			dout_im = SIN_PI_8;
		end
		4'h2 : begin
			dout_re = COS_PI_4;
			dout_im = COS_PI_4;
		end
		4'h3 : begin
			dout_re = SIN_PI_8;
			dout_im = COS_PI_8;
		end
		4'h4 : begin
			dout_re = SIN_0;
			dout_im = COS_0;
		end
		4'h5 : begin
			dout_re = M_SIN_PI_8;
			dout_im = COS_PI_8;
		end
		4'h6 : begin
			dout_re = M_COS_PI_4;
			dout_im = COS_PI_4;
		end
		4'h7 : begin
			dout_re = M_COS_PI_8;
			dout_im = SIN_PI_8;
		end
		4'h8 : begin
			dout_re = M_COS_0;
			dout_im = SIN_0;
		end
		4'h9 : begin
			dout_re = M_COS_PI_8;
			dout_im = M_SIN_PI_8;
		end
		4'ha : begin
			dout_re = M_COS_PI_4;
			dout_im = M_COS_PI_4;
		end
		4'hb : begin
			dout_re = M_SIN_PI_8;
			dout_im = M_COS_PI_8;
		end
		4'hc : begin
			dout_re = SIN_0;
			dout_im = M_COS_0;
		end
		4'hd : begin
			dout_re = SIN_PI_8;
			dout_im = M_COS_PI_8;
		end
		4'he : begin
			dout_re = COS_PI_4;
			dout_im = M_COS_PI_4;
		end
		4'hf : begin
			dout_re = COS_PI_8;
			dout_im = M_SIN_PI_8;
		end
		default : begin
			dout_re = COS_PI_8;
			dout_im = M_SIN_PI_8;
		end
	endcase
end


reg dout_vld_f;
always @(posedge clk or negedge n_rst) begin
	if (!n_rst) begin
		dout_vld_f <= 1'b0;
	end
	else begin
		dout_vld_f <= din_vld;
	end
end


assign dout = {dout_re,dout_im};
assign dout_vld = dout_vld_f;

endmodule
