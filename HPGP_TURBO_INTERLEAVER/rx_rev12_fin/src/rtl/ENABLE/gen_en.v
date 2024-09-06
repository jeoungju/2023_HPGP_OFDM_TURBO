`timescale 1ps/1ps

module gen_en (
    input           clk,
    input           n_rst,
    input           din_vld, //din_vld
    input  [11:0]   len_l,
    output [11:0]   enable, //ram address
    output [11:0]   pb_len,
    output [11:0]   pb_offset,
    output          wen,
    output          dout_vld
);
    parameter       STATE_LEN = 2;
    parameter       ADDRESS = 12;
    
    localparam      IDLE = 2'h0;
    localparam      START = 2'h1;
    localparam      CHECK = 2'h2;
    localparam      REQUEST = 2'h3;

    reg [STATE_LEN-1 : 0]  state, n_state;
    reg [ADDRESS-1 : 0]    cnt_id;
    reg [ADDRESS-1 : 0]    cnt_en;

    ////////         Offset        ///////////
    wire [ADDRESS-1 : 0]   pb_16, pb_136, pb_520;
    assign pb_16 = 12'h000; //[0:~]
    assign pb_136 = 12'h040; //[+64:~]
    assign pb_520 = 12'h260; //[+64+544:~]

    //Example
    wire [ADDRESS-1 : 0]   pb_3;
    assign pb_3 = 12'h000;

    always @(posedge clk or negedge n_rst) begin
        if(!n_rst) begin
            state <= IDLE;
        end
        else begin
            state <= n_state;
        end
    end

    reg [11:0] len_l_d;
    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            len_l_d <= 12'h000;
        end
        else begin
            len_l_d <= len_l;
        end
    end

    wire [11:0] len_l_1_4;
    assign len_l_1_4 = {2'b00,len_l[11:2]};
    //FSM
    always @(*)
        case (state)
            IDLE    : n_state = (din_vld == 1'b1) ? START : state;
            START   : n_state = (cnt_en + 12'h1 == len_l) ? CHECK : state;
            CHECK   : n_state = REQUEST;
            REQUEST : n_state = (cnt_en + 12'h1 == len_l_1_4) ? IDLE : state;
            default: n_state = IDLE;
        endcase

    //cnt_id
    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            cnt_id <= {(ADDRESS){1'b0}};
        end
        else if (len_l == 12'h040) begin //PB 16
            cnt_id <= pb_16;
        end
        else if (len_l == 12'h220) begin //PB 136
            cnt_id <= pb_136;
        end
        else if (len_l == 12'h820) begin //PB 520
            cnt_id <= pb_520;
        end
        else if (len_l == 12'h00a) begin //EX
            cnt_id <= pb_3;
        end
        else begin
            cnt_id <= {(ADDRESS){1'b0}};
        end
    end

    //count en 
    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            cnt_en <= {(ADDRESS){1'b0}};
        end
        else if (state == START) begin
            cnt_en <= cnt_en + 12'h001;
        end
        else if (state == CHECK) begin
            cnt_en <= {(ADDRESS){1'b0}};
        end
        else if (state == REQUEST) begin
            cnt_en <= cnt_en + 12'h001;
        end
        else begin
            cnt_en <= {(ADDRESS){1'b0}};
        end
    end

    //write enable
    
    reg wen_d;
    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            wen_d <= 1'b0;
        end
        else begin
            wen_d <= ((din_vld == 1'b1) || (cnt_en + 12'h1 < len_l) && (state == START)) ? 1'b1 : 1'b0;
        end
    end
    

    assign enable = cnt_en;
    assign pb_offset = cnt_id;
    assign pb_len = len_l;
    assign wen = wen_d;
    assign dout_vld = (state == REQUEST) ? 1'b1 : 1'b0;
endmodule
