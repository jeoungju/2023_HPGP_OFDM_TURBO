`timescale 1ps/1ps
// enable signal according to m_len
///////////////////////////////////////
/////////SAT-DOUNLINK INTERLEAVER//////
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

    ////////        SAT_DOWN        ///////////
    wire [ADDRESS-1 : 0]   id25, id26, id27, id28, id29;
    wire [ADDRESS-1 : 0]   id32, id33, id34;
    assign id25 = 16'h0000; //[0:~]
    assign id26 = 16'h12ae; //[+4776+6:~]
    assign id27 = 16'h2804; //[+5456+6:~]
    assign id28 = 16'h3f9a; //[+6032+6:~]
    assign id29 = 16'h5440; //[+5280+6:~]
    // id30, id31 no use
    assign id32 = 16'h939a; //[+5552+6:~]
    assign id33 = 16'h94d8; //[+312+6:~]
    assign id34 = 16'ha596; //[+4280+6:~]

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
        else if (m_len == 13'h12a8) begin //Link_id 25
            cnt_id <= id25;
        end
        else if (m_len == 13'h1550) begin //Link_id 26
            cnt_id <= id26;
        end
        else if (m_len == 13'h1790) begin //Link_id 27
            cnt_id <= id27;
        end
        else if (m_len == 13'h14a0) begin //Link_id 28
            cnt_id <= id28;
        end
        else if (m_len == 13'h15b0) begin //Link_id 29
            cnt_id <= id29;
        end
        else if (m_len == 13'h0138) begin //Link_id 32
            cnt_id <= id32;
        end
        else if (m_len == 13'h10b8) begin //Link_id 33
            cnt_id <= id33;
        end
        else if (m_len == 13'h1040) begin //Link_id 34
            cnt_id <= id34;
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
    
/*
    reg request_d;
    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            request_d <= 1'b0;
        end
        else begin
            request_d <= request;
        end
    end
*/
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
