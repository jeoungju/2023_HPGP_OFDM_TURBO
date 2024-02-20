`timescale 1ps/1ps

module full_384 (
    clk,
	n_rst,
	start,
	mode_3072_384,
	in_vld,
	in_re,
	in_im,
	out_re,
	out_im,
	out_vld
);

parameter IDLE = 2'b00;
parameter MODE_384 = 2'b01;
parameter MODE_3072 = 2'b10;
//complex parameter
parameter D1_SIZE = 6; // cos, sin  parameter
parameter D2_SIZE = 4; // input 	parameter

parameter SIGN_BIT=1;
parameter INT_BIT=6;
parameter FLT_BIT=6;

localparam DW = SIGN_BIT + INT_BIT + FLT_BIT;
localparam DW_W_F = 16; 
localparam DW_W = SIGN_BIT + 1 + DW_W_F;

input clk;
input n_rst;
input start;
input mode_3072_384;

input in_vld;
input  [D2_SIZE-1:0]	in_re;
input  [D2_SIZE-1:0]	in_im;

output [D1_SIZE:0]	out_re;
output [D1_SIZE:0]	out_im;
output out_vld;

wire rom_out_vld;
wire [DW_W_F*2-1:0] rom_out;

wire [D1_SIZE-1:0] rom_out_re;
wire [D1_SIZE-1:0] rom_out_im;
assign rom_out_re = rom_out[31:31-D1_SIZE+1];
assign rom_out_im = rom_out[15:15-D1_SIZE+1];
//assign rom_out_re = {rom_out[27],5'h01,rom_out[26],rom_out[25:20]};
//assign rom_out_im = {rom_out[23],5'h01,rom_out[12],rom_out[11:6]};

reg [1:0] state, next_state;
always @(posedge clk or negedge n_rst)
    if (!n_rst) begin
        state <= 2'b0;
    end
    else begin
        state <= next_state;
    end

reg [11:0] cnt_3072;
reg [8:0] cnt_384;

wire start_384, start_3072;
assign start_384 = ((start == 1'b1) && (mode_3072_384 == 1'b1)) ? 1'b1 : 1'b0;
assign start_3072 = ((start == 1'b1) && (mode_3072_384 == 1'b0)) ? 1'b1 : 1'b0;
always @(*)
    case(state)
        IDLE : next_state = (start_384 == 1'b1) ? MODE_384 : (start_3072 == 1'b1) ? MODE_3072 : state;
        MODE_384 : next_state = (cnt_384 == 9'd383) ? IDLE : state;
        MODE_3072 : next_state = (cnt_3072 == 12'd3071) ? IDLE : state;
        default : next_state = IDLE;
    endcase

always @(posedge clk or negedge n_rst)
    if (!n_rst) begin
        cnt_384 <= 9'd0;
    end
    else begin
        cnt_384 <= (cnt_384 == 9'd383) ? 9'd0 : ((state == MODE_384) && (in_vld)) ? cnt_384 + 9'd1 : cnt_384;
    end


always @(posedge clk or negedge n_rst)
    if (!n_rst) begin
        cnt_3072 <= 12'd0;
    end
    else begin
        cnt_3072 <= (cnt_3072 == 12'd3071) ? 12'd0 : ((state == MODE_3072) && (in_vld)) ? cnt_3072 + 12'd1 : cnt_3072;
    end

wire [11:0] addr_3072;
wire [8:0] addr_384;

assign addr_3072 = cnt_3072;
assign addr_384 = cnt_384;

rom_384_decoder u_rom_384_decoder (
	.clk(clk),
	.n_rst(n_rst),
	.din_num(addr_384),
	//.mode_3072_384(),
	.din_vld(in_vld),
	.dout(rom_out),
	.dout_vld(rom_out_vld)
);

reg  [D2_SIZE-1:0]	in1_re_d;
reg  [D2_SIZE-1:0]	in1_im_d;
always @(posedge clk or negedge n_rst) begin
	if(!n_rst) begin
		in1_re_d <= {(DW){1'b0}};
		in1_im_d <= {(DW){1'b0}};
	end
	else begin
		in1_re_d <= in_re;
		in1_im_d <= in_im;
	end
end

complex_signed_mult #(
	.D1_SIZE(6), 
	.D2_SIZE(4) // 0_1_00, 1_1_00
) u_complex_signed_mult (
	.clk(clk),
	.n_rst(n_rst),
	.di_vld(rom_out_vld),
	.d2_re(in1_re_d),
	.d2_im(in1_im_d),
	.d1_re(rom_out_re),
	.d1_im(rom_out_im),
	.do_vld(out_vld),
	.do_re(out_re),
	.do_im(out_im)
);

endmodule
