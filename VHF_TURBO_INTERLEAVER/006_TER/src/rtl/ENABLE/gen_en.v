`timescale 1ps/1ps
// enable signal according to m_len
///////////////////////////////////////
///////////TER INTERLEAVER/////////////
///////////////////////////////////////

module gen_en (
    input           clk,
    input           n_rst,
    input           din_vld, //din_vld
    input           request,
    input  [12:0]   m_len,
    output [15:0]   enable, //ram address
    output [15:0]   id_offset,
    output          wen,
    output reg      dout_vld
);
    parameter       STATE_LEN = 3;
    parameter       ADDRESS = 16;
    
    localparam      IDLE = 2'h0;
    localparam      START = 2'h1;
    localparam      RAM = 2'h2;
    localparam      REQUEST = 2'h3;

    reg [STATE_LEN-1 : 0]  state, n_state;
    reg [ADDRESS-1 : 0]    cnt_id;
    reg [ADDRESS-1 : 0]    cnt_en;

    ////////         TER        ///////////
    wire [ADDRESS-1 : 0]   id11, id17, id19;
    wire [ADDRESS-1 : 0]   id12, id13, id14, id15, id16, id18;
    assign id11 = 16'h0000; //[0:~]
    assign id12 = 16'h01b6; //[+432+6:~]
    assign id13 = 16'h0588; //[+972+6:~]
    assign id14 = 16'h0a9e; //[+1296+6:~]
    assign id15 = 16'h0e24; //[+896+6:~]
    assign id16 = 16'h160a; //[+2016+6:~]
    assign id17 = 16'h2090; //[+2688+6:~]
    assign id18 = 16'h27e6; //[+1872+6:~]
    assign id19 = 16'h37ac; //[+4032+6:~]

    /*
    assign id11 = 16'h0000; //[0:~]
    assign id17 = 16'h01b6; //[+432+6:~]
    assign id19 = 16'h090c; //[+1872+6:~]
    */

    always @(posedge clk or negedge n_rst) begin
        if(!n_rst) begin
            state <= IDLE;
        end
        else begin
            state <= n_state;
        end
    end

    reg [12:0] m_len_d;
    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            m_len_d <= 13'h0000;
        end
        else begin
            m_len_d <= m_len;
        end
    end

    //FSM
    always @(*)
        case (state)
            IDLE    : n_state = (din_vld == 1'b1) ? START : state;
            START   : n_state = (cnt_en + 16'h1 == m_len) ? RAM : state;
            RAM     : n_state = REQUEST;
            REQUEST : n_state = (cnt_en + 16'h1 == m_len) ? IDLE : state;
            default: n_state = IDLE;
        endcase

    //cnt_id
    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            cnt_id <= {(ADDRESS){1'b0}};
        end
        else if (m_len == 13'h01b0) begin //Link_id 11
            cnt_id <= id11;
        end
        else if (m_len == 13'h03cc) begin //Link_id 12
            cnt_id <= id12;
        end
        else if (m_len == 13'h0510) begin //Link_id 13
            cnt_id <= id13;
        end
        else if (m_len == 13'h0380) begin //Link_id 14
            cnt_id <= id14;
        end
        else if (m_len == 13'h07e0) begin //Link_id 15
            cnt_id <= id15;
        end
        else if (m_len == 13'h0a80) begin //Link_id 16
            cnt_id <= id16;
        end
        else if (m_len == 13'h0750) begin //Link_id 17
            cnt_id <= id17;
        end
        else if (m_len == 13'h0fc0) begin //Link_id 18
            cnt_id <= id18;
        end
        else if (m_len == 13'h15f0) begin //Link_id 19
            cnt_id <= id19;
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
            cnt_en <= cnt_en + 16'h0001;
        end
        else if (state == REQUEST) begin
            cnt_en <= (request == 1'b1) ? cnt_en + 16'h0001 : cnt_en;
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
            wen_d <= ((din_vld == 1'b1) || (state == START)) ? 1'b1 : 1'b0;
        end
    end
    
    //dout_vld
    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            dout_vld <= 1'b0;
        end
        else begin
            dout_vld <= (request == 1'b1) ? 1'b1 : 1'b0;
        end
    end

    assign enable = cnt_en;
    assign id_offset = cnt_id;
    assign wen = wen_d;
endmodule
