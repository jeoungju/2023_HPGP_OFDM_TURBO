/////////////////////////////////// 
// complex signed multiplier
// SIZE = SIGN(1) + INTEGER + FACTOR 
//
// D1_SIZE >= D2_SIZE
// mag(D2) <= 1
// DOUT_SIZE = D1_SIZE + 1
//  
//////////////////////////////////
// round 
//             * 
// +0.25  0_00_010 ->  0  0_00
// +0.50  0_00_100 -> +0  0_00 (+ 0_00) // if 0, out
// +0.75  0_00_110 -> +1  0_01 (+ 0_01) 
// +1.00  0_01_000 -> +1  0_01
// +1.25  0_01_010 -> +1  0_01
// +1.50  0_01_100 -> +2  0_10 (+ 0_01) // if 1, add
// +1.75  0_01_110 -> +2  0_10 (+ 0_01)
//             *
// -0.250 1_11_110 ->  0 0_00 (+ 0_01)
// -0.375 1_11_101 ->  0 0_00 (+ 0_01)
// -0.500 1_11_100 ->  0 0_00 (+ 0_01) // if 1, add
// -0.625 1_11_011 -> -1 1_11  
// -0.750 1_11_010 -> -1 1_11 
// -0.875 1_11_001 -> -1 1_11 
// -1.000 1_11_000 -> -1 1_11
// -1.125 1_10_111 -> -1 1_11 (+ 0_01)
// -1.250 1_10_110 -> -1 1_11 (+ 0_01)
// -1.375 1_10_101 -> -1 1_11 (+ 0_01)
// -1.500 1_10_100 -> -2 1_10   // if 0, out
// -1.625 1_10_011 -> -2 1_10 
// -1.750 1_10_010 -> -2 1_10 
//////////////////////////////////////////////////
// input decimal ... -128 ~ +127 Error
//                   -127 ~ +127 OK
//////////////////////////////////////////////////

// 2023.12.21
// D2_SIZE = 1 + 1 + D2_FRACTION

module complex_signed_mult (
	clk	,
	n_rst	,

	di_vld,

	d1_re,
	d1_im,
	d2_re,
	d2_im,

	do_vld,
	do_re,
	do_im
);

///////////////////////////////////////////////////
parameter D1_SIZE = 13;
parameter D2_SIZE = 11;

///////////////////////////////////////////////////
// INPUT
///////////////////////////////////////////////////

input						clk	;
input						n_rst;
input						di_vld;

input [(D1_SIZE - 1) : 0] d1_re;
input [(D1_SIZE - 1) : 0] d1_im;
input [(D2_SIZE - 1) : 0] d2_re;
input [(D2_SIZE - 1) : 0] d2_im;
//input					  d2_re_1;
//input					  d2_im_1;

///////////////////////////////////////////////////
// OUTPUT
///////////////////////////////////////////////////
output						do_vld;

output [(D1_SIZE ) : 0]	do_re;
output [(D1_SIZE ) : 0] do_im;

//==================================================
// MAIN
//==================================================
//
// (a + jb) * (c + jd) = (ac - bd) + j(ad + bc)
//

wire [(D1_SIZE - 2) : 0] d1_re_mag_w, d1_im_mag_w;
wire [(D2_SIZE - 2) : 0] d2_re_mag_w, d2_im_mag_w;
//reg  [(D1_SIZE - 2) : 0] d1_re_mag_r, d1_im_mag_r;
//reg  [(D2_SIZE - 2) : 0] d2_re_mag_r, d2_im_mag_r;
wire d1_re_sign  , d1_im_sign  , d2_re_sign  , d2_im_sign;
wire d1_re_sign_w, d1_im_sign_w, d2_re_sign_w, d2_im_sign_w;
//reg  d1_re_sign_r, d1_im_sign_r, d2_re_sign_r, d2_im_sign_r;
wire [(D1_SIZE - 2) : 0] d1_re_mag  , d1_im_mag;
wire [(D2_SIZE - 2) : 0] d2_re_mag  , d2_im_mag;

reg di_vld_d1;
//reg					  d2_re_1_d1;
//reg					  d2_im_1_d1;

//--------------------------------------------------
// for syn ...
//--------------------------------------------------
assign d1_re_sign_w = d1_re[D1_SIZE-1];
assign d1_im_sign_w = d1_im[D1_SIZE-1];
assign d2_re_sign_w = d2_re[D2_SIZE-1];
assign d2_im_sign_w = d2_im[D2_SIZE-1];

assign d1_re_mag_w = (d1_re_sign_w == 1'b1)? ~d1_re[D1_SIZE-2:0] + {{(D1_SIZE-2){1'b0}},1'b1} : d1_re[D1_SIZE-2:0];
assign d1_im_mag_w = (d1_im_sign_w == 1'b1)? ~d1_im[D1_SIZE-2:0] + {{(D1_SIZE-2){1'b0}},1'b1} : d1_im[D1_SIZE-2:0];
assign d2_re_mag_w = (d2_re_sign_w == 1'b1)? ~d2_re[D2_SIZE-2:0] + {{(D2_SIZE-2){1'b0}},1'b1} : d2_re[D2_SIZE-2:0];
assign d2_im_mag_w = (d2_im_sign_w == 1'b1)? ~d2_im[D2_SIZE-2:0] + {{(D2_SIZE-2){1'b0}},1'b1} : d2_im[D2_SIZE-2:0];

//always @(negedge n_rst or posedge clk)
//begin
	//d1_re_mag_r = d1_re_mag_w; 
	//d1_im_mag_r = d1_im_mag_w;
	//d2_re_mag_r = d2_re_mag_w;
	//d2_im_mag_r = d2_im_mag_w;
	//d1_re_sign_r = d1_re_sign_w;
	//d1_im_sign_r = d1_im_sign_w;
	//d2_re_sign_r = d2_re_sign_w;
	//d2_im_sign_r = d2_im_sign_w;
//end

assign d1_re_mag = d1_re_mag_w; 
assign d1_im_mag = d1_im_mag_w;
assign d2_re_mag = d2_re_mag_w;
assign d2_im_mag = d2_im_mag_w;
assign d1_re_sign = d1_re_sign_w;
assign d1_im_sign = d1_im_sign_w;
assign d2_re_sign = d2_re_sign_w;
assign d2_im_sign = d2_im_sign_w;

// ---------------------------------------------------------------
// (a+jb) * (c+jd)
// (ac + (-bd)) + j(ad + bc)
// (D1_SIZE-1)x(D2_SIZE-1) => D1_SIZE-1+D2+SIZE-1 = D1_SIZE + D2_SIZE - 2
wire [(D1_SIZE + D2_SIZE -3):0] mid_re_1st_mag, mid_re_2nd_mag;
wire [(D1_SIZE + D2_SIZE -3):0] mid_im_1st_mag, mid_im_2nd_mag;
wire mid_re_1st_sign, mid_re_2nd_sign, mid_im_1st_sign, mid_im_2nd_sign;

assign mid_re_1st_sign = (d1_re_sign == d2_re_sign)? 1'b0 : 1'b1;    //ac
assign mid_re_2nd_sign = (d1_im_sign == d2_im_sign)? 1'b1 : 1'b0;    //-bd
assign mid_im_1st_sign = (d1_re_sign == d2_im_sign)? 1'b0 : 1'b1;    //ad
assign mid_im_2nd_sign = (d1_im_sign == d2_re_sign)? 1'b0 : 1'b1;    //bc

assign mid_re_1st_mag = d1_re_mag * d2_re_mag;
assign mid_re_2nd_mag = d1_im_mag * d2_im_mag;
assign mid_im_1st_mag = d1_re_mag * d2_im_mag;
assign mid_im_2nd_mag = d1_im_mag * d2_re_mag;
//assign mid_re_1st_mag = (d2_re_1_d1 == 1'b1)? {d1_re_mag,{(D2_SIZE-1){1'b0}}} : d1_re_mag * d2_re_mag;
//assign mid_re_2nd_mag = (d2_im_1_d1 == 1'b1)? {d1_im_mag,{(D2_SIZE-1){1'b0}}} : d1_im_mag * d2_im_mag;
//assign mid_im_1st_mag = (d2_im_1_d1 == 1'b1)? {d1_re_mag,{(D2_SIZE-1){1'b0}}} : d1_re_mag * d2_im_mag;
//assign mid_im_2nd_mag = (d2_re_1_d1 == 1'b1)? {d1_im_mag,{(D2_SIZE-1){1'b0}}} : d1_im_mag * d2_re_mag;
// MSB always is 0 ... because d2 <= 1.0000
// so.... it is used like sign ????

wire [(D1_SIZE + D2_SIZE -3)+1:0] mid_re_1st, mid_re_2nd;
wire [(D1_SIZE + D2_SIZE -3)+1:0] mid_im_1st, mid_im_2nd;

assign mid_re_1st = (mid_re_1st_sign == 1'b1)? ~{1'b0,mid_re_1st_mag} + {{(D1_SIZE+D2_SIZE-3+1){1'b0}},1'b1} : {1'b0,mid_re_1st_mag};
assign mid_re_2nd = (mid_re_2nd_sign == 1'b1)? ~{1'b0,mid_re_2nd_mag} + {{(D1_SIZE+D2_SIZE-3+1){1'b0}},1'b1} : {1'b0,mid_re_2nd_mag};
assign mid_im_1st = (mid_im_1st_sign == 1'b1)? ~{1'b0,mid_im_1st_mag} + {{(D1_SIZE+D2_SIZE-3+1){1'b0}},1'b1} : {1'b0,mid_im_1st_mag};
assign mid_im_2nd = (mid_im_2nd_sign == 1'b1)? ~{1'b0,mid_im_2nd_mag} + {{(D1_SIZE+D2_SIZE-3+1){1'b0}},1'b1} : {1'b0,mid_im_2nd_mag};

//=============================================================

wire [(D1_SIZE + D2_SIZE -2)+1:0] mid_re_sum, mid_im_sum;

assign mid_re_sum = {mid_re_1st[D1_SIZE + D2_SIZE-2],mid_re_1st} + {mid_re_2nd[D1_SIZE + D2_SIZE-2],mid_re_2nd};
assign mid_im_sum = {mid_im_1st[D1_SIZE + D2_SIZE-2],mid_im_1st} + {mid_im_2nd[D1_SIZE + D2_SIZE-2],mid_im_2nd};

//=============================================================

wire re_round_point;
wire im_round_point;

wire re_round_extr_1;
wire im_round_extr_1;

// 2023.12.21
// D2_SIZE = 1 + 0 + D2_FR
//assign re_round_point = mid_re_sum[D2_SIZE-2];
//assign im_round_point = mid_im_sum[D2_SIZE-2];
//
//assign re_round_point_up = mid_re_sum[D2_SIZE-2+1];
//assign im_round_point_up = mid_im_sum[D2_SIZE-2+1];
// D2_SIZE = 1 + 1 + D2_FR
// [D2_SIZE -1] : sign
// [D2_SIZE -2] : integer
// [D2_SIZE -3] : fr1 ... (1/2)
assign re_round_point = mid_re_sum[D2_SIZE-2-1]; // fr1
assign im_round_point = mid_im_sum[D2_SIZE-2-1]; // fr1

assign re_round_point_up = mid_re_sum[D2_SIZE-2-1+1]; // fr0 = integer
assign im_round_point_up = mid_im_sum[D2_SIZE-2-1+1]; // fr0 = integer

assign re_round_extr_1 = (mid_re_sum[D2_SIZE-3-1:0] == {(D2_SIZE-2-1){1'b0}})? 1'b0 : 1'b1; // fr2 ~ 
assign im_round_extr_1 = (mid_im_sum[D2_SIZE-3-1:0] == {(D2_SIZE-2-1){1'b0}})? 1'b0 : 1'b1; // fr2 ~ 

// clipping .... 
reg [D1_SIZE + 1 : 0] re_out; // 2-bit extension
reg [D1_SIZE + 1 : 0] im_out; // 2-bit extension
reg di_vld_d2;

always @(*)
//always @(negedge n_rst or posedge clk)
	//if(!n_rst) begin
		//re_out <= {(D1_SIZE){1'b0}};
	//end
	//else begin
		if (re_round_point == 1'b1) begin // 0.5
			if (re_round_extr_1 == 1'b1)  // larger than 0.5
				re_out = mid_re_sum[D1_SIZE + D2_SIZE -1 : D2_SIZE-1-1] + 1;
			else if (re_round_point_up == 1'b1) // re_round_extr_1 == 1'b0 -> 0.5 .. odd ??
				re_out = mid_re_sum[D1_SIZE + D2_SIZE -1 : D2_SIZE-1-1] + 1;
			else // 0.5 & even ..
				re_out = mid_re_sum[D1_SIZE + D2_SIZE -1:D2_SIZE-1-1];
		end
		else begin
			re_out = mid_re_sum[D1_SIZE + D2_SIZE -1:D2_SIZE-1-1];
		end
	//end

always @(*)
//always @(negedge n_rst or posedge clk)
	//if(!n_rst) begin
		//im_out <= {(D1_SIZE){1'b0}};
	//end
	//else begin
		if (im_round_point == 1'b1) begin
			if (im_round_extr_1 == 1'b1) 
				im_out = mid_im_sum[D1_SIZE + D2_SIZE -1 : D2_SIZE-1-1] + 1;
			else if (im_round_point_up == 1'b1) // im_round_extr_1 == 1'b0
				im_out = mid_im_sum[D1_SIZE + D2_SIZE -1 : D2_SIZE-1-1] + 1;
			else
				im_out = mid_im_sum[D1_SIZE + D2_SIZE -1:D2_SIZE-1-1];
		end
		else begin
			im_out = mid_im_sum[D1_SIZE + D2_SIZE -1:D2_SIZE-1-1];
		end
	//end

// clipping ....
reg [D1_SIZE  : 0] re_out_d1, re_out_d2;
reg [D1_SIZE  : 0] im_out_d1, im_out_d2;

wire re_out_sat, re_out_sat_pos, re_out_sat_neg;
wire im_out_sat, im_out_sat_pos, im_out_sat_neg;
assign re_out_sat = (re_out[D1_SIZE+1] != re_out[D1_SIZE]) ? 1'b1 : 1'b0;
assign re_out_sat_pos = ((re_out_sat == 1'b1) && (re_out[D1_SIZE+1] == 1'b0))? 1'b1 : 1'b0;
assign re_out_sat_neg = ((re_out_sat == 1'b1) && (re_out[D1_SIZE+1] == 1'b1))? 1'b1 : 1'b0;
assign im_out_sat = (im_out[D1_SIZE+1] != im_out[D1_SIZE]) ? 1'b1 : 1'b0;
assign im_out_sat_pos = ((im_out_sat == 1'b1) && (im_out[D1_SIZE+1] == 1'b0))? 1'b1 : 1'b0;
assign im_out_sat_neg = ((im_out_sat == 1'b1) && (im_out[D1_SIZE+1] == 1'b1))? 1'b1 : 1'b0;

always @(negedge n_rst or posedge clk)
begin
	if(!n_rst) begin
		re_out_d1   <= {(D1_SIZE+1){1'b0}};
		re_out_d2   <= {(D1_SIZE+1){1'b0}};
		im_out_d1   <= {(D1_SIZE+1){1'b0}};
		im_out_d2   <= {(D1_SIZE+1){1'b0}};
		di_vld_d1   <= 1'b0;
		di_vld_d2   <= 1'b0;
	end
	else begin
		//re_out_d1   <= re_out;
		//im_out_d1   <= im_out;
		re_out_d1   <= (re_out_sat_pos == 1'b1)? {1'b0,{(D1_SIZE){1'b1}}} : 
		               (re_out_sat_neg == 1'b1)? {1'b1,{(D1_SIZE-1){1'b0}},1'b1} : re_out;
		im_out_d1   <= (im_out_sat_pos == 1'b1)? {1'b0,{(D1_SIZE){1'b1}}} : 
		               (im_out_sat_neg == 1'b1)? {1'b1,{(D1_SIZE-1){1'b0}},1'b1} : im_out;
		re_out_d2   <= re_out_d1;
		im_out_d2   <= im_out_d1;
		di_vld_d1   <= di_vld;
		di_vld_d2   <= di_vld_d1;
	end
end

assign do_re = re_out_d2; //[D1_SIZE+D2_SIZE-1-2:D2_SIZE-2];
assign do_im = im_out_d2; //[D1_SIZE+D2_SIZE-1-2:D2_SIZE-2];
assign do_vld = di_vld_d2;

endmodule
