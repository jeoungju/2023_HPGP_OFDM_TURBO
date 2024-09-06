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
    parameter       OFFSET = 8;

    parameter       ADDR_OFFSET = A_WIDTH + OFFSET;


reg	[D_WIDTH-1:0]           rdata_d;      //original data
reg	[D_WIDTH-1:0]           rdata_itl_d;  //interleaver data
wire [D_WIDTH-1:0]           rdata_itl_mod;

// din store ram
reg [D_WIDTH-1:0]           ram [0 : 2**A_WIDTH-1];


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
            READ_16     : n_state = (cnt0 == raddr_1_4) ? IDLE : state;
            READ_136    : n_state = (cnt0 == raddr_1_4) ? IDLE : state;
            READ_520    : n_state = (cnt0 == raddr_1_4) ? IDLE : state;
            default     : n_state = IDLE;
        endcase

//read enable
wire ren;
assign ren = (state == READ_16) ? 1'b1 : 
                (state == READ_136) ? 1'b1 :
                (state == READ_520) ? 1'b1 : (start == 1'b1) ? 1'b1 : 1'b0;


//read address
always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        cnt0 <= 10'h000;
    end
    else if (start == 1'b1) begin
        cnt0 <= raddr_0 + 10'h1;
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
//ram addr
wire [ADDR_OFFSET-1:0] ram_addr;

rom_addr #(
    .D_WIDTH(2),
    .A_WIDTH(12)
) dut_rom_addr (
	.clk(clk),
    .n_rst(n_rst),
	.raddr(addr),
    .mod_int_dint(mod_int_dint),
	.data_out(ram_addr)
);

// ram addr 1 clock delay
reg [ADDR_OFFSET-1:0] ram_addr_d;
always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        ram_addr_d <= {(ADDR_OFFSET){1'b0}};
    end
    else begin
        ram_addr_d <= ram_addr;
    end
end

wire [A_WIDTH-1:0] mix_addr;
wire [OFFSET-1:0]  mix_offset;

assign mix_addr = ram_addr[19:8];
assign mix_offset = ram_addr_d[7:0];

wire [A_WIDTH-1:0]  raddr;
assign              raddr = mix_addr + pb_offset_addr;

//output data
wire [D_WIDTH-1:0] rdata0_d; // addr 0 ~ 1/4 -1's data
wire [D_WIDTH-1:0] rdata1_d; // addr 1/4 ~ 1/2 -1's data
wire [D_WIDTH-1:0] rdata2_d; // addr 1/2 ~ 3/4 -1's data
wire [D_WIDTH-1:0] rdata3_d; // addr 3/4 ~ pb_len -1's data

ram #(
    .D_WIDTH(D_WIDTH),
    .A_WIDTH(A_WIDTH),
    .SELECT(0)
    ) ram_0 (
	.clk(clk),
    .n_rst(n_rst),
    .ren(ren),
    .raddr(raddr),
    .rdata(rdata0_d),
    .wen(1'b0),
    .waddr(waddr),
    .wdata(wdata)
);

ram #(
    .D_WIDTH(D_WIDTH),
    .A_WIDTH(A_WIDTH),
    .SELECT(1)
    ) ram_1 (
	.clk(clk),
    .n_rst(n_rst),
    .ren(ren),
    .raddr(raddr),
    .rdata(rdata1_d),
    .wen(1'b0),
    .waddr(waddr),
    .wdata(wdata)
);

ram #(
    .D_WIDTH(D_WIDTH),
    .A_WIDTH(A_WIDTH),
    .SELECT(2)
    ) ram_2 (
	.clk(clk),
    .n_rst(n_rst),
    .ren(ren),
    .raddr(raddr),
    .rdata(rdata2_d),
    .wen(1'b0),
    .waddr(waddr),
    .wdata(wdata)
);

ram #(
    .D_WIDTH(D_WIDTH),
    .A_WIDTH(A_WIDTH),
    .SELECT(3)
    ) ram_3 (
	.clk(clk),
    .n_rst(n_rst),
    .ren(ren),
    .raddr(raddr),
    .rdata(rdata3_d),
    .wen(1'b0),
    .waddr(waddr),
    .wdata(wdata)
);

reg [D_WIDTH-1:0] rdata0_dd;
reg [D_WIDTH-1:0] rdata1_dd;
reg [D_WIDTH-1:0] rdata2_dd;
reg [D_WIDTH-1:0] rdata3_dd;
always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        rdata0_dd <= {(D_WIDTH){1'b0}};
    end
    else begin
        if (mix_offset[7:6] == 2'b00) begin
            rdata0_dd <= rdata0_d;
        end
        else if (mix_offset[7:6] == 2'b01) begin
            rdata0_dd <= rdata1_d;
        end
        else if (mix_offset[7:6] == 2'b10) begin
            rdata0_dd <= rdata2_d;
        end
        else if (mix_offset[7:6] == 2'b11) begin
            rdata0_dd <= rdata3_d;
        end
        else begin
            rdata0_dd <= {(D_WIDTH){1'b0}};
        end
    end
end

always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        rdata1_dd <= {(D_WIDTH){1'b0}};
    end
    else begin
        if (mix_offset[5:4] == 2'b00) begin
            rdata1_dd <= rdata0_d;
        end
        else if (mix_offset[5:4] == 2'b01) begin
            rdata1_dd <= rdata1_d;
        end
        else if (mix_offset[5:4] == 2'b10) begin
            rdata1_dd <= rdata2_d;
        end
        else if (mix_offset[5:4] == 2'b11) begin
            rdata1_dd <= rdata3_d;
        end
        else begin
            rdata1_dd <= {(D_WIDTH){1'b0}};
        end
    end
end

always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        rdata2_dd <= {(D_WIDTH){1'b0}};
    end
    else begin
        if (mix_offset[3:2] == 2'b00) begin
            rdata2_dd <= rdata0_d;
        end
        else if (mix_offset[3:2] == 2'b01) begin
            rdata2_dd <= rdata1_d;
        end
        else if (mix_offset[3:2] == 2'b10) begin
            rdata2_dd <= rdata2_d;
        end
        else if (mix_offset[3:2] == 2'b11) begin
            rdata2_dd <= rdata3_d;
        end
        else begin
            rdata2_dd <= {(D_WIDTH){1'b0}};
        end
    end
end

always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        rdata3_dd <= {(D_WIDTH){1'b0}};
    end
    else begin
        if (mix_offset[1:0] == 2'b00) begin
            rdata3_dd <= rdata0_d;
        end
        else if (mix_offset[1:0] == 2'b01) begin
            rdata3_dd <= rdata1_d;
        end
        else if (mix_offset[1:0] == 2'b10) begin
            rdata3_dd <= rdata2_d;
        end
        else if (mix_offset[1:0] == 2'b11) begin
            rdata3_dd <= rdata3_d;
        end
        else begin
            rdata3_dd <= {(D_WIDTH){1'b0}};
        end
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



assign rdata0 = rdata0_dd;
assign rdata1 = rdata1_dd;
assign rdata2 = rdata2_dd;
assign rdata3 = rdata3_dd;
assign dout_vld = dout_vld_d;

endmodule