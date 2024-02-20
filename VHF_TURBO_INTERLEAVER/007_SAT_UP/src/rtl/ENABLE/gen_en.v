`timescale 1ps/1ps
// enable signal according to m_len
///////////////////////////////////////
/////////SAT-UPLINK INTERLEAVER////////
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

    ////////         SAT_UP        ///////////
    wire [ADDRESS-1 : 0]   id20, id21, id22;
    wire [ADDRESS-1 : 0]   id23, id24;
    assign id20 = 16'h0000; //[0:~]
    assign id21 = 16'h0066; //[+96+6:~]
    assign id22 = 16'h034c; //[+736+6:~]
    assign id23 = 16'h0f82; //[+3120+6:~]
    assign id24 = 16'h2148; //[+4544+6:~]

    /*
    assign id20 = 16'h0000; //[0:~]
    assign id21 = 16'h0066; //[+96+6:~]
    assign id22 = 16'h034c; //[+736+6:~]
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
        else if (m_len == 13'h0060) begin //Link_id 20
            cnt_id <= id20;
        end
        else if (m_len == 13'h02e0) begin //Link_id 21
            cnt_id <= id21;
        end
        else if (m_len == 13'h0c30) begin //Link_id 22
            cnt_id <= id22;
        end
        else if (m_len == 13'h11c0) begin //Link_id 23
            cnt_id <= id23;
        end
        else if (m_len == 13'h0ecc) begin //Link_id 24
            cnt_id <= id24;
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
