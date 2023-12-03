`timescale 1ns/100ps
`define T_CLK 10
module testbench;

reg clk, n_rst;
initial clk = 1'b1;
always #(`T_CLK/2) clk = ~clk;

initial begin
	n_rst = 1'b0;
	#(`T_CLK * 1.2) n_rst = 1'b1;
end

parameter D1_SIZE = 13;
parameter D2_SIZE = 11;
parameter SIGN_BIT=1,
parameter INT_BIT=6,
parameter FLT_BIT=6


reg [D1_SIZE-1:0] d1_re, d1_im;
reg [D1_SIZE-1:0] d2_re, d2_im;
reg [D1_SIZE-1:0] d3_re, d3_im;

wire [D1_SIZE+1:0] o_d1_re, o_d1_im;
wire [D1_SIZE+1:0] o_d2_re, o_d2_im;
wire [D1_SIZE+1:0] o_d3_re, o_d3_im;

reg din_vld;
wire dout_vld;

integer i, j, p, q;
integer fp, fpall;

initial begin
	fp = $fopen("csm_results_NoRound_v.txt","w");
	fpall = $fopen("csm_results_v.txt","w");
end

initial begin
	din_vld = 1'b0;
	d1_re = 0;
	d1_im = 0;
	d2_re = 0;
	d2_im = 0;
	d3_re = 0;
	d3 _im = 0;

	wait (n_rst == 1'b1);

	for (i = 62;i<66;i=i+1) begin // 4->16, 3->8, 7->128, 6->64
		$display("%d",i);
		for (j=0;j<128;j=j+1) begin // j < 128
			for (p = 0;p<64;p=p+1) begin
				for (q=0;q<64;q=q+1) begin
					d1_re = i;
					d1_im = j;
					d2_re = p;
					d2_im = q;
					din_vld = 1'b1;
					#(`T_CLK) din_vld = 1'b0;
					wait(dout_vld == 1'b1);
					//#(`T_CLK*0.2);
					@(negedge clk)
					//$display("%3d %3d : %3d %3d ; r=%5d, i=%5d : r=%5d, i=%5d",i, j, p, q, 
					//	u_complex_signed_mult.mid_re_sum,u_complex_signed_mult.mid_im_sum,
					//	o_d_re, o_d_im
					//);
					//$fdisplay(fp,"%3d %3d : %3d %3d ; r=%5d, i=%5d",i, j, p, q, 
						//u_complex_signed_mult.mid_re_sum,u_complex_signed_mult.mid_im_sum
					//);
					//$fdisplay(fpall,"%3d %3d : %3d %3d ; r=%5d, i=%5d : r=%5d, i=%5d",i, j, p, q, 
					//	u_complex_signed_mult.mid_re_sum,u_complex_signed_mult.mid_im_sum,
					//	o_d_re, o_d_im
					//);
					//$fdisplay(fpall,"%5d, %5d", o_d_re, o_d_im);
					wait(dout_vld == 1'b0);
					#(`T_CLK * 0.2);
				end
			end
		end
	end
	$fclose(fp);
	$fclose(fpall);
	$stop;
end

rd3bf # (
	parameter SIGN_BIT=1,
    parameter INT_BIT=6,
    parameter FLT_BIT=6
) u_rd3bf (
	.clk(clk),
	.n_rst(n_rst),
	.di_vld(din_vld),
	.in1_re(d1_re), .in1_im(d1_im),
    .in2_re(d2_re), .in2_im(d2_im),
    .in3_re(d3_re), .in3_im(d3_im),
	.out1_re(o_d1_re), .out1_im(o_d1_im),
    .out2_re(o_d2_re), .out2_im(o_d2_im),
    .out3_re(o_d3_re), .out3_im(o_d3_im),
	.do_vld(dout_vld)
);


endmodule
