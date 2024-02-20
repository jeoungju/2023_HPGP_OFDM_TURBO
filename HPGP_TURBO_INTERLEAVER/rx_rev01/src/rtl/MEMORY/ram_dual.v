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
    input [A_WIDTH-1:0]     pb_len,
    input                   wen,
    input                   start, //start read
    input                   mod_int_dint, //choose int or dint

	output [D_WIDTH-1:0]    rdata0,
    output [D_WIDTH-1:0]    rdata1,
    output [D_WIDTH-1:0]    rdata2,
    output [D_WIDTH-1:0]    rdata3,
    //output [D_WIDTH-1:0]    rdata,
    //output [D_WIDTH-1:0]    rdata_itl,
    input                   din_vld,
    output                  dout_vld
);

    localparam      IDLE =      3'h0;
    localparam      READ =     3'h1;
    localparam      STOP =     3'h2; // check PB_size 
    //localparam      READ_16 =   'h3;
    //localparam      READ_136 =   'h4;
    //localparam      READ_520 =   'h5;

    parameter       STATE_LEN = 3;


reg	[D_WIDTH-1:0]           rdata_d;      //original data
reg	[D_WIDTH-1:0]           rdata_itl_d;  //interleaver data
wire [D_WIDTH-1:0]           rdata_itl_mod;

// din store ram
reg [D_WIDTH-1:0]           ram [0 : 2**A_WIDTH-1];

reg [D_WIDTH-1:0]           ram0 [0 : 2**A_WIDTH-1];
reg [D_WIDTH-1:0]           ram1 [0 : 2**A_WIDTH-1];
reg [D_WIDTH-1:0]           ram2 [0 : 2**A_WIDTH-1];
reg [D_WIDTH-1:0]           ram3 [0 : 2**A_WIDTH-1];

initial  begin
    $readmemh("../src/rtl/RAM/ram0.txt", ram0);
    $readmemh("../src/rtl/RAM/ram1.txt", ram1);
    $readmemh("../src/rtl/RAM/ram2.txt", ram2);
    $readmemh("../src/rtl/RAM/ram3.txt", ram3);
end

reg [A_WIDTH-1:0]           rom_itl [0 : 2**A_WIDTH-1];
reg [A_WIDTH-1:0]           rom_ditl [0 : 2**A_WIDTH-1];


//------------------paraller-----------------------
// paraller deinterleaver rom
reg [A_WIDTH-1:0]           rom_d_16_0 [0 : 2**A_WIDTH-1];
reg [A_WIDTH-1:0]           rom_d_16_1 [0 : 2**A_WIDTH-1];
reg [A_WIDTH-1:0]           rom_d_16_2 [0 : 2**A_WIDTH-1];
reg [A_WIDTH-1:0]           rom_d_16_3 [0 : 2**A_WIDTH-1];

initial  begin
    $readmemh("../src/rtl/ROM/pb_16_deint_rom0.txt", rom_d_16_0);
    $readmemh("../src/rtl/ROM/pb_16_deint_rom1.txt", rom_d_16_1);
    $readmemh("../src/rtl/ROM/pb_16_deint_rom2.txt", rom_d_16_2);
    $readmemh("../src/rtl/ROM/pb_16_deint_rom3.txt", rom_d_16_3);
end

// paraller deinterleaver rom
reg [A_WIDTH-1:0]           rom_i_16_0 [0 : 2**A_WIDTH-1];
reg [A_WIDTH-1:0]           rom_i_16_1 [0 : 2**A_WIDTH-1];
reg [A_WIDTH-1:0]           rom_i_16_2 [0 : 2**A_WIDTH-1];
reg [A_WIDTH-1:0]           rom_i_16_3 [0 : 2**A_WIDTH-1];

initial  begin
    $readmemh("../src/rtl/ROM/pb_16_int_rom0.txt", rom_i_16_0);
    $readmemh("../src/rtl/ROM/pb_16_int_rom1.txt", rom_i_16_1);
    $readmemh("../src/rtl/ROM/pb_16_int_rom2.txt", rom_i_16_2);
    $readmemh("../src/rtl/ROM/pb_16_int_rom3.txt", rom_i_16_3);
end


//---------------------------------------------------


//-----------------read address--------------------
wire [A_WIDTH-1:0] raddr_0;   //    0
wire [A_WIDTH-1:0] raddr_1_4; //    1/4 , cycle
wire [A_WIDTH-1:0] raddr_1_2; //    1/2
wire [A_WIDTH-1:0] raddr_3_4; //    3/4

assign raddr_0   = {(A_WIDTH){1'b0}};           // read addr 0 ~ 1/4 -1
assign raddr_1_4 = {2'b00,pb_len[A_WIDTH-1:2]};  // read addr 1/4 ~ 1/2 -1
assign raddr_1_2 = {1'b0,pb_len[A_WIDTH-1:1]}; // read addr 1/2 ~ 3/4 -1
assign raddr_3_4 = raddr_1_4 + raddr_1_2;       // read addr 3/4 ~ pb_len-1
//--------------------------------------------------


// address rom
initial  begin
    //$readmemh("../src/rtl/ROM/pb_interleav.txt", rom_itl);
    //$readmemh("../src/rtl/ROM/pb_deinterleav.txt", rom_ditl);
end

reg [STATE_LEN-1 : 0]  state, n_state;
always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        state <= IDLE;
    end
    else begin
        state <= n_state;
    end
end

//read address
reg [9:0] cnt0, cnt1, cnt2, cnt3;

always @(*)
        case (state)
            IDLE    : n_state = (start == 1'b1) ? READ : state;
            READ    : n_state = (cnt0 == raddr_1_4 - 10'h1) ? IDLE : state;
            default: n_state = IDLE;
        endcase

//read enable
wire ren;
assign ren = (state == READ) ? 1'b1 : 1'b0;

//write ram
always @(posedge clk or negedge n_rst) begin
    if(wen == 1'b1) begin
        ram[waddr] <= wdata;
    end
end

//read address
always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        cnt0 <= 10'h000;
        cnt1 <= 10'h000;
        cnt2 <= 10'h000;
        cnt3 <= 10'h000;
    end
    else if (start == 1'b1) begin
        cnt0 <= raddr_0;
        cnt1 <= raddr_1_4;
        cnt2 <= raddr_1_2;
        cnt3 <= raddr_3_4;
    end
    else begin
        if (state == READ) begin
            cnt0 <= cnt0 + 10'h1;
            cnt1 <= cnt1 + 10'h1;
            cnt2 <= cnt2 + 10'h1;
            cnt3 <= cnt3 + 10'h1;
        end
        else begin
            cnt0 <= raddr_0;
            cnt1 <= raddr_1_4;
            cnt2 <= raddr_1_2;
            cnt3 <= raddr_3_4;
        end
    end
end

wire [A_WIDTH-1:0]  addr0;
wire [A_WIDTH-1:0]  addr1;
wire [A_WIDTH-1:0]  addr2;
wire [A_WIDTH-1:0]  addr3;
assign              addr0 = cnt0 + pb_offset;
assign              addr1 = cnt1 + pb_offset;
assign              addr2 = cnt2 + pb_offset;
assign              addr3 = cnt3 + pb_offset;

//intl addr or dintl addr
reg [A_WIDTH-1:0] mix_addr0;
reg [A_WIDTH-1:0] mix_addr1;
reg [A_WIDTH-1:0] mix_addr2;
reg [A_WIDTH-1:0] mix_addr3;

always @(posedge clk or negedge n_rst) begin
    if(!n_rst) begin
        mix_addr0 <= {(A_WIDTH){1'b0}};
        mix_addr1 <= {(A_WIDTH){1'b0}};
        mix_addr2 <= {(A_WIDTH){1'b0}};
        mix_addr3 <= {(A_WIDTH){1'b0}};
    end
    else begin
        if (mod_int_dint == 1'b1) begin //intleaver
            mix_addr0 <= rom_i_16_0[addr0];
            mix_addr1 <= rom_i_16_1[addr0];
            mix_addr2 <= rom_i_16_2[addr0];
            mix_addr3 <= rom_i_16_3[addr0];
        end
        else begin
            mix_addr0 <= rom_d_16_0[addr0];
            mix_addr1 <= rom_d_16_1[addr0];
            mix_addr2 <= rom_d_16_2[addr0];
            mix_addr3 <= rom_d_16_3[addr0];
        end
    end
end

reg [D_WIDTH-1:0] rdata0_d; // addr 0 ~ 1/4 -1's data
reg [D_WIDTH-1:0] rdata1_d; // addr 1/4 ~ 1/2 -1's data
reg [D_WIDTH-1:0] rdata2_d; // addr 1/2 ~ 3/4 -1's data
reg [D_WIDTH-1:0] rdata3_d; // addr 3/4 ~ pb_len -1's data

always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        rdata0_d <= {(D_WIDTH){1'b0}}; 
    end
    else begin
        if(mix_addr0[5:4] == 2'b00) begin
            rdata0_d <= ram0[mix_addr0[3:0]];
        end
        else if(mix_addr1[5:4] == 2'b00) begin
            rdata0_d <= ram1[mix_addr1[3:0]];
        end
        else if(mix_addr2[5:4] == 2'b00) begin
            rdata0_d <= ram2[mix_addr2[3:0]];
        end
        else if(mix_addr3[5:4] == 2'b00) begin
            rdata0_d <= ram3[mix_addr3[3:0]];
        end
        else begin
            rdata0_d <= rdata0_d;
        end
    end
end

always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin 
        rdata1_d <= {(D_WIDTH){1'b0}};  
    end
    else begin
        if(mix_addr0[5:4] == 2'b01) begin
            rdata1_d <= ram0[mix_addr0[3:0]];
        end
        else if(mix_addr1[5:4] == 2'b01) begin
            rdata1_d <= ram2[mix_addr1[3:0]];
        end
        else if(mix_addr2[5:4] == 2'b01) begin
            rdata1_d <= ram2[mix_addr2[3:0]];
        end
        else if(mix_addr3[5:4] == 2'b01) begin
            rdata1_d <= ram3[mix_addr3[3:0]];
        end
        else begin
            rdata1_d <= rdata1_d;
        end
    end
end

always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        rdata2_d <= {(D_WIDTH){1'b0}};  
    end
    else begin
        if(mix_addr0[5:4] == 2'b10) begin
            rdata2_d <= ram0[mix_addr0[3:0]];
        end
        else if(mix_addr1[5:4] == 2'b10) begin
            rdata2_d <= ram1[mix_addr1[3:0]];
        end
        else if(mix_addr2[5:4] == 2'b10) begin
            rdata2_d <= ram2[mix_addr2[3:0]];
        end
        else if(mix_addr3[5:4] == 2'b10) begin
            rdata2_d <= ram3[mix_addr3[3:0]];
        end
        else begin
            rdata2_d <= rdata2_d;
        end
    end
end

always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        rdata3_d <= {(D_WIDTH){1'b0}}; 
    end
    else begin
        if(mix_addr0[5:4] == 2'b11) begin
            rdata3_d <= ram0[mix_addr0[3:0]];
        end 
        else if(mix_addr1[5:4] == 2'b11) begin
            rdata3_d <= ram1[mix_addr1[3:0]];
        end
        else if(mix_addr2[5:4] == 2'b11) begin
            rdata3_d <= ram2[mix_addr2[3:0]];
        end
        else if(mix_addr3[5:4] == 2'b11) begin
            rdata3_d <= ram3[mix_addr3[3:0]];
        end
        else begin
            rdata3_d <= rdata3_d;
        end
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

/*
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
*/

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


//assign rdata = rdata_d;
assign rdata0 = rdata0_d;
assign rdata1 = rdata1_d;
assign rdata2 = rdata2_d;
assign rdata3 = rdata3_d;

//assign rdata_itl = (waddr_dd[0] == 1'b0) ? {rdata_itl_d[0],rdata_itl_d[1]} : rdata_itl_d;

assign dout_vld = dout_vld_dd;

endmodule