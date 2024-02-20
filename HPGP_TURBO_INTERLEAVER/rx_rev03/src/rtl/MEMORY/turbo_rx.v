`timescale 1ps/1ps
//-----HPGP INTERLEAVER------

module turbo_rx # (
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
    input                   din_vld,
    output                  dout_vld
);

    localparam      IDLE =      3'h0;
    localparam      READ =     3'h1;
    localparam      STOP =     3'h2; // check PB_size 
    localparam      READ_16 =   3'h3;
    localparam      READ_136 =   3'h4;
    localparam      READ_520 =   3'h5;

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


//-----------------------------paraller----------------------------------
// paraller deinterleaver rom
reg [A_WIDTH-1:0]           rom_d_16_0 [0 : 2**A_WIDTH-1];
reg [A_WIDTH-1:0]           rom_d_16_1 [0 : 2**A_WIDTH-1];
reg [A_WIDTH-1:0]           rom_d_16_2 [0 : 2**A_WIDTH-1];
reg [A_WIDTH-1:0]           rom_d_16_3 [0 : 2**A_WIDTH-1];

initial  begin
    $readmemh("../src/rtl/RX_ROM/pb_deint_rom0.txt", rom_d_16_0);
    $readmemh("../src/rtl/RX_ROM/pb_deint_rom1.txt", rom_d_16_1);
    $readmemh("../src/rtl/RX_ROM/pb_deint_rom2.txt", rom_d_16_2);
    $readmemh("../src/rtl/RX_ROM/pb_deint_rom3.txt", rom_d_16_3);
end

// paraller deinterleaver rom
reg [A_WIDTH-1:0]           rom_i_16_0 [0 : 2**A_WIDTH-1];
reg [A_WIDTH-1:0]           rom_i_16_1 [0 : 2**A_WIDTH-1];
reg [A_WIDTH-1:0]           rom_i_16_2 [0 : 2**A_WIDTH-1];
reg [A_WIDTH-1:0]           rom_i_16_3 [0 : 2**A_WIDTH-1];

initial  begin
    $readmemh("../src/rtl/RX_ROM/pb_int_rom0.txt", rom_i_16_0);
    $readmemh("../src/rtl/RX_ROM/pb_int_rom1.txt", rom_i_16_1);
    $readmemh("../src/rtl/RX_ROM/pb_int_rom2.txt", rom_i_16_2);
    $readmemh("../src/rtl/RX_ROM/pb_int_rom3.txt", rom_i_16_3);
end

//-------------------------------------------------------------------------


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

wire [A_WIDTH-1:0] pb_offset_addr;
assign pb_offset_addr = (pb_len == 12'h220) ? 12'h10 : (pb_len == 12'h820) ? 12'h98 : 12'h0;


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
reg [9:0] cnt0;

always @(*)
        case (state)
            IDLE        : n_state = ((start == 1'b1) && (pb_len == 12'h40)) ? READ_16  :
                                ((start == 1'b1) && (pb_len == 12'h220)) ? READ_136 :
                                ((start == 1'b1) && (pb_len == 12'h820)) ? READ_520 : state;
            READ_16     : n_state = (cnt0 == raddr_1_4 - 10'h1) ? IDLE : state;
            READ_136    : n_state = (cnt0 == raddr_1_4 - 10'h1) ? IDLE : state;
            READ_520    : n_state = (cnt0 == raddr_1_4 - 10'h1) ? IDLE : state;
            default     : n_state = IDLE;
        endcase

//read enable
wire ren;
assign ren = (state == READ_16) ? 1'b1 : 
                (state == READ_136) ? 1'b1 :
                (state == READ_520) ? 1'b1 : 1'b0;

//write ram
ram dut_ram_store (
    .clk(clk),
    .n_rst(n_rst),
    .wdata(wdata),
    .raddr(),
    .waddr(waddr),
    .wen(wen),
    .ren(1'b0),
    .rdata()
);

//read address
always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        cnt0 <= 10'h000;
    end
    else if (start == 1'b1) begin
        cnt0 <= raddr_0 +10'h1;
    end
    else begin
        if (state == READ_16) begin
            cnt0 <= cnt0 + 10'h1;
        end
        else if (state == READ_136) begin
            cnt0 <= cnt0 + 10'h1;
        end
        else if (state == READ_520) begin
            cnt0 <= cnt0 + 10'h1;
        end
        else begin
            cnt0 <= raddr_0;
        end
    end
end

reg [9:0] cnt0_d;
always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        cnt0_d <= 10'h0;
    end
    else begin
        cnt0_d <= cnt0;
    end
end

wire [A_WIDTH-1:0]  addr;
assign              addr = cnt0 + pb_offset_addr;

//intl addr or dintl addr
//PB_SIZE 16
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
            mix_addr0 <= rom_i_16_0[addr];
            mix_addr1 <= rom_i_16_1[addr];
            mix_addr2 <= rom_i_16_2[addr];
            mix_addr3 <= rom_i_16_3[addr];
        end
        else begin
            mix_addr0 <= rom_d_16_0[addr];
            mix_addr1 <= rom_d_16_1[addr];
            mix_addr2 <= rom_d_16_2[addr];
            mix_addr3 <= rom_d_16_3[addr];
        end
    end
end

//ram addr
reg [A_WIDTH-1:0] ram_addr0;
reg [A_WIDTH-1:0] ram_addr1;
reg [A_WIDTH-1:0] ram_addr2;
reg [A_WIDTH-1:0] ram_addr3;
always @(*) begin
    if (state == READ_16) begin
        if(mix_addr0[5:4] == 2'b00) begin
            ram_addr0 = mix_addr0;
        end
        else if(mix_addr1[5:4] == 2'b00) begin
            ram_addr0 = mix_addr1;
        end
        else if(mix_addr2[5:4] == 2'b00) begin
            ram_addr0 = mix_addr2;
        end
        else if(mix_addr3[5:4] == 2'b00) begin
            ram_addr0 = mix_addr3;
        end
        else begin
            ram_addr0 = ram_addr0;
        end
    end
    else if (state == READ_136) begin
        if(mix_addr0 < 12'h88) begin
            ram_addr0 = mix_addr0;
        end
        else if(mix_addr1 < 12'h88) begin
            ram_addr0 = mix_addr1;
        end
        else if(mix_addr2 < 12'h88) begin
            ram_addr0 = mix_addr2;
        end
        else if(mix_addr3 < 12'h88) begin
            ram_addr0 = mix_addr3;
        end
        else begin
            ram_addr0 = ram_addr0;
        end
    end
    else if (state == READ_520) begin
        if(mix_addr0 < 12'h208) begin
            ram_addr0 = mix_addr0;
        end
        else if(mix_addr1 < 12'h208) begin
            ram_addr0 = mix_addr1;
        end
        else if(mix_addr2 < 12'h208) begin
            ram_addr0 = mix_addr2;
        end
        else if(mix_addr3 < 12'h208) begin
            ram_addr0 = mix_addr3;
        end
        else begin
            ram_addr0 = ram_addr0;
        end
    end
    else begin
        ram_addr0 = ram_addr0;
    end
end

always @(*) begin
    if (state == READ_16) begin
        if(mix_addr0[5:4] == 2'b01) begin
            ram_addr1 = mix_addr0 - 12'h10;
        end
        else if(mix_addr1[5:4] == 2'b01) begin
            ram_addr1 = mix_addr1 - 12'h10;
        end
        else if(mix_addr2[5:4] == 2'b01) begin
            ram_addr1 = mix_addr2 - 12'h10;
        end
        else if(mix_addr3[5:4] == 2'b01) begin
            ram_addr1 = mix_addr3 - 12'h10;
        end
        else begin
            ram_addr1 = ram_addr1;
        end
    end
    else if (state == READ_136) begin
        if((12'h88 <= mix_addr0) && (mix_addr0 < 12'h110)) begin
            ram_addr1 = mix_addr0 - 12'h88;
        end
        else if((12'h88 <= mix_addr1) && (mix_addr1 < 12'h110)) begin
            ram_addr1 = mix_addr1 - 12'h88;
        end
        else if((12'h88 <= mix_addr2) && (mix_addr2 < 12'h110)) begin
            ram_addr1 = mix_addr2 - 12'h88;
        end
        else if((12'h88 <= mix_addr3) && (mix_addr3 < 12'h110)) begin
            ram_addr1 = mix_addr3 - 12'h88;
        end
        else begin
            ram_addr1 = ram_addr1;
        end
    end
    else if (state == READ_520) begin
        if((12'h208 <= mix_addr0) && (mix_addr0 < 12'h410)) begin
            ram_addr1 = mix_addr0 - 12'h208;
        end
        else if((12'h208 <= mix_addr1) && (mix_addr1 < 12'h410)) begin
            ram_addr1 = mix_addr1 - 12'h208;
        end
        else if((12'h208 <= mix_addr2) && (mix_addr2 < 12'h410)) begin
            ram_addr1 = mix_addr2 - 12'h208;
        end
        else if((12'h208 <= mix_addr3) && (mix_addr3 < 12'h410)) begin
            ram_addr1 = mix_addr3 - 12'h208;
        end
        else begin
            ram_addr1 = ram_addr1;
        end
    end
    else begin
        ram_addr1 = ram_addr1;
    end
end

always @(*) begin
    if (state == READ_16) begin
        if(mix_addr0[5:4] == 2'b10) begin
            ram_addr2 = mix_addr0 - 12'h20;
        end
        else if(mix_addr1[5:4] == 2'b10) begin
            ram_addr2 = mix_addr1 - 12'h20;
        end
        else if(mix_addr2[5:4] == 2'b10) begin
            ram_addr2 = mix_addr2 - 12'h20;
        end
        else if(mix_addr3[5:4] == 2'b10) begin
            ram_addr2 = mix_addr3 - 12'h20;
        end
        else begin
            ram_addr2 = ram_addr2;
        end
    end
    else if (state == READ_136) begin
        if((12'h110 <= mix_addr0) && (mix_addr0 < 12'h198)) begin
            ram_addr2 = mix_addr0 - 12'h110;
        end
        else if((12'h110 <= mix_addr1) && (mix_addr1 < 12'h198)) begin
            ram_addr2 = mix_addr1 - 12'h110;
        end
        else if((12'h110 <= mix_addr2) && (mix_addr2 < 12'h198)) begin
            ram_addr2 = mix_addr2 - 12'h110;
        end
        else if((12'h110 <= mix_addr3) && (mix_addr3 < 12'h198)) begin
            ram_addr2 = mix_addr3 - 12'h110;
        end
        else begin
            ram_addr2 = ram_addr2;
        end
    end
    else if (state == READ_520) begin
        if((12'h410 <= mix_addr0) && (mix_addr0 < 12'h618)) begin
            ram_addr2 = mix_addr0 - 12'h410;
        end
        else if((12'h410 <= mix_addr1) && (mix_addr1 < 12'h618)) begin
            ram_addr2 = mix_addr1 - 12'h410;
        end
        else if((12'h410 <= mix_addr2) && (mix_addr2 < 12'h618)) begin
            ram_addr2 = mix_addr2 - 12'h410;
        end
        else if((12'h410 <= mix_addr3) && (mix_addr3 < 12'h618)) begin
            ram_addr2 = mix_addr3 - 12'h410;
        end
        else begin
            ram_addr2 = ram_addr2;
        end
    end
    else begin
        ram_addr2 = ram_addr2;
    end
end

always @(*) begin
    if (state == READ_16) begin
        if(mix_addr0[5:4] == 2'b11) begin
            ram_addr3 = mix_addr0 - 12'h30;
        end
        else if(mix_addr1[5:4] == 2'b11) begin
            ram_addr3 = mix_addr1 - 12'h30;
        end
        else if(mix_addr2[5:4] == 2'b11) begin
            ram_addr3 = mix_addr2 - 12'h30;
        end
        else if(mix_addr3[5:4] == 2'b11) begin
            ram_addr3 = mix_addr3 - 12'h30;
        end
        else begin
            ram_addr3 = ram_addr3;
        end
    end
    else if (state == READ_136) begin
        if(mix_addr0 >= 12'h198) begin
            ram_addr3 = mix_addr0 - 12'h198;
        end
        else if(mix_addr1 >= 12'h198) begin
            ram_addr3 = mix_addr1 - 12'h198;
        end
        else if(mix_addr2 >= 12'h198) begin
            ram_addr3 = mix_addr2 - 12'h198;
        end
        else if(mix_addr3 >= 12'h198) begin
            ram_addr3 = mix_addr3 - 12'h198;
        end
        else begin
            ram_addr3 = ram_addr3;
        end
    end
    else if (state == READ_520) begin
        if(mix_addr0 >= 12'h618) begin
            ram_addr3 = mix_addr0 - 12'h618;
        end
        else if(mix_addr1 >= 12'h618) begin
            ram_addr3 = mix_addr1 - 12'h618;
        end
        else if(mix_addr2 >= 12'h618) begin
            ram_addr3 = mix_addr2 - 12'h618;
        end
        else if(mix_addr3 >=12'h618) begin
            ram_addr3 = mix_addr3 - 12'h618;
        end
        else begin
            ram_addr3 = ram_addr3;
        end
    end
    else begin
        ram_addr3 = ram_addr3;
    end
end

wire [A_WIDTH-1:0]  addr0, addr1, addr2, addr3;
assign              addr0 = ram_addr0 + pb_offset_addr;
assign              addr1 = ram_addr1 + pb_offset_addr;
assign              addr2 = ram_addr2 + pb_offset_addr;
assign              addr3 = ram_addr3 + pb_offset_addr;

//output data
reg [D_WIDTH-1:0] rdata0_d; // addr 0 ~ 1/4 -1's data
reg [D_WIDTH-1:0] rdata1_d; // addr 1/4 ~ 1/2 -1's data
reg [D_WIDTH-1:0] rdata2_d; // addr 1/2 ~ 3/4 -1's data
reg [D_WIDTH-1:0] rdata3_d; // addr 3/4 ~ pb_len -1's data

always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        rdata0_d <= {(D_WIDTH){1'b0}}; 
    end
    else if (state == READ_16) begin
        if(mix_addr0[5:4] == 2'b00) begin
            rdata0_d <= ram0[addr0];
        end
        else if(mix_addr1[5:4] == 2'b00) begin
            rdata0_d <= ram1[addr1];
        end
        else if(mix_addr2[5:4] == 2'b00) begin
            rdata0_d <= ram2[addr2];
        end
        else if(mix_addr3[5:4] == 2'b00) begin
            rdata0_d <= ram3[addr3];
        end
        else begin
            rdata0_d <= rdata0_d;
        end
    end
    else if (state == READ_136) begin
        if(mix_addr0 < 12'h88) begin
            rdata0_d <= ram0[addr0];
        end
        else if(mix_addr1 < 12'h88) begin
            rdata0_d <= ram1[addr1];
        end
        else if(mix_addr2 < 12'h88) begin
            rdata0_d <= ram2[addr2];
        end
        else if(mix_addr3 < 12'h88) begin
            rdata0_d <= ram3[addr3];
        end
        else begin
            rdata0_d <= rdata0_d;
        end
    end
    else if (state == READ_520) begin
        if(mix_addr0 < 12'h208) begin
            rdata0_d <= ram0[addr0];
        end
        else if(mix_addr1 < 12'h208) begin
            rdata0_d <= ram1[addr1];
        end
        else if(mix_addr2 < 12'h208) begin
            rdata0_d <= ram2[addr2];
        end
        else if(mix_addr3 < 12'h208) begin
            rdata0_d <= ram3[addr3];
        end
        else begin
            rdata0_d <= rdata0_d;
        end
    end
    else begin
        rdata0_d <= rdata0_d;
    end
end

always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        rdata1_d <= {(D_WIDTH){1'b0}};
    end
    else if (state == READ_16) begin
        if(mix_addr0[5:4] == 2'b01) begin
            rdata1_d <= ram0[addr0];
        end
        else if(mix_addr1[5:4] == 2'b01) begin
            rdata1_d <= ram1[addr1];
        end
        else if(mix_addr2[5:4] == 2'b01) begin
            rdata1_d <= ram2[addr2];
        end
        else if(mix_addr3[5:4] == 2'b01) begin
            rdata1_d <= ram3[addr3];
        end
        else begin
            rdata1_d <= rdata1_d;
        end
    end
    else if (state == READ_136) begin
        if((12'h88 <= mix_addr0) && (mix_addr0 < 12'h110)) begin
            rdata1_d <= ram0[addr0];
        end
        else if((12'h88 <= mix_addr1) && (mix_addr1 < 12'h110)) begin
            rdata1_d <= ram1[addr1];
        end
        else if((12'h88 <= mix_addr2) && (mix_addr2 < 12'h110)) begin
            rdata1_d <= ram2[addr2];
        end
        else if((12'h88 <= mix_addr3) && (mix_addr3 < 12'h110)) begin
            rdata1_d <= ram3[addr3];
        end
        else begin
            rdata1_d <= rdata1_d;
        end
    end
    else if (state == READ_520) begin
        if((12'h208 <= mix_addr0) && (mix_addr0 < 12'h410)) begin
            rdata1_d <= ram0[addr0];
        end
        else if((12'h208 <= mix_addr1) && (mix_addr1 < 12'h410)) begin
            rdata1_d <= ram1[addr1];
        end
        else if((12'h208 <= mix_addr2) && (mix_addr2 < 12'h410)) begin
            rdata1_d <= ram2[addr2];
        end
        else if((12'h208 <= mix_addr3) && (mix_addr3 < 12'h410)) begin
            rdata1_d <= ram3[addr3];
        end
        else begin
            rdata1_d <= rdata1_d;
        end
    end
    else begin
        rdata1_d <= rdata1_d;
    end
end

always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        rdata2_d <= {(D_WIDTH){1'b0}};
    end
    else if (state == READ_16) begin
        if(mix_addr0[5:4] == 2'b10) begin
            rdata2_d <= ram0[addr0];
        end
        else if(mix_addr1[5:4] == 2'b10) begin
            rdata2_d <= ram1[addr1];
        end
        else if(mix_addr2[5:4] == 2'b10) begin
            rdata2_d <= ram2[addr2];
        end
        else if(mix_addr3[5:4] == 2'b10) begin
            rdata2_d <= ram3[addr3];
        end
        else begin
            rdata2_d <= rdata2_d;
        end
    end
    else if (state == READ_136) begin
        if((12'h110 <= mix_addr0) && (mix_addr0 < 12'h198)) begin
            rdata2_d <= ram0[addr0];
        end
        else if((12'h110 <= mix_addr1) && (mix_addr1 < 12'h198)) begin
            rdata2_d <= ram1[addr1];
        end
        else if((12'h110 <= mix_addr2) && (mix_addr2 < 12'h198)) begin
            rdata2_d <= ram2[addr2];
        end
        else if((12'h110 <= mix_addr3) && (mix_addr3 < 12'h198)) begin
            rdata2_d <= ram3[addr3];
        end
        else begin
            rdata2_d <= rdata2_d;
        end
    end
    else if (state == READ_520) begin
        if((12'h410 <= mix_addr0) && (mix_addr0 < 12'h618)) begin
            rdata2_d <= ram0[addr0];
        end
        else if((12'h410 <= mix_addr1) && (mix_addr1 < 12'h618)) begin
            rdata2_d <= ram1[addr1];
        end
        else if((12'h410 <= mix_addr2) && (mix_addr2 < 12'h618)) begin
            rdata2_d <= ram2[addr2];
        end
        else if((12'h410 <= mix_addr3) && (mix_addr3 < 12'h618)) begin
            rdata2_d <= ram3[addr3];
        end
        else begin
            rdata2_d <= rdata2_d;
        end
    end
    else begin
        rdata2_d <= rdata2_d;
    end
end

always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        rdata3_d <= {(D_WIDTH){1'b0}}; 
    end
    else if (state == READ_16) begin
        if(mix_addr0[5:4] == 2'b11) begin
            rdata3_d <= ram0[addr0];
        end
        else if(mix_addr1[5:4] == 2'b11) begin
            rdata3_d <= ram1[addr1];
        end
        else if(mix_addr2[5:4] == 2'b11) begin
            rdata3_d <= ram2[addr2];
        end
        else if(mix_addr3[5:4] == 2'b11) begin
            rdata3_d <= ram3[addr3];
        end
        else begin
            rdata3_d <= rdata3_d;
        end
    end
    else if (state == READ_136) begin
        if(mix_addr0 >= 12'h198) begin
            rdata3_d <= ram0[addr0];
        end
        else if(mix_addr1 >= 12'h198) begin
            rdata3_d <= ram1[addr1];
        end
        else if(mix_addr2 >= 12'h198) begin
            rdata3_d <= ram2[addr2];
        end
        else if(mix_addr3 >= 12'h198) begin
            rdata3_d <= ram3[addr3];
        end
        else begin
            rdata3_d <= rdata3_d;
        end
    end
    else if (state == READ_520) begin
        if(mix_addr0 >= 12'h618) begin
            rdata3_d <= ram0[addr0];
        end
        else if(mix_addr1 >= 12'h618) begin
            rdata3_d <= ram1[addr1];
        end
        else if(mix_addr2 >= 12'h618) begin
            rdata3_d <= ram2[addr2];
        end
        else if(mix_addr3 >= 12'h618) begin
            rdata3_d <= ram3[addr3];
        end
        else begin
            rdata3_d <= rdata3_d;
        end
    end
    else begin
        rdata3_d <= rdata3_d;
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



assign rdata0 = rdata0_d;
assign rdata1 = rdata1_d;
assign rdata2 = rdata2_d;
assign rdata3 = rdata3_d;
assign dout_vld = dout_vld_d;

endmodule