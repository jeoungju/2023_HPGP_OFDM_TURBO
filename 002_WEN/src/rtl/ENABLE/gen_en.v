`timescale 1ps/1ps
// enable signal according to m_len

module gen_en (
    input clk,
    input n_rst,
    input din_vld, //din_vld
    input request,
    input [12:0] m_len,
    output [15:0] enable, //ram address
    output [15:0] id_jump,
    output wen
);
    parameter STATE_LEN = 2;
    parameter ADDRESS = 16;

    localparam IDLE = 2'h0;
    localparam START = 2'h1;
    localparam RAM = 2'h2;
    localparam REQUEST = 2'h3;

    reg [STATE_LEN-1 : 0]  state, n_state;
    reg [ADDRESS-1 : 0]    cnt_id;
    reg [ADDRESS-1 : 0]    cnt_en;

    wire [ADDRESS-1 : 0]   id5, id6, id7, id11, id17, id19;
    assign id5 = 16'h0000; //[0:~]
    assign id6 = 16'h0120; //[288:~]
    assign id7 = 16'h03c0; //[288+672:~]
    assign id11 = 16'h07e0; //[288+672+1056:~]
    assign id17 = 16'h0990; //[288+672+1056+432:~]
    assign id19 = 16'h10e0; //[288+672+1056+432+1872:~]
    wire [ADDRESS-1 : 0]    cnt_m_len;

    assign cnt_m_len = cnt_en - cnt_id + 16'h0001;

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
            IDLE : n_state = (din_vld == 1'b1) ? START : state;
            //START : n_state = (cnt_m_len == m_len) ? RAM : state;
            START : n_state = (cnt_en + 16'h1 == m_len) ? RAM : state;
            RAM : n_state = REQUEST;
            REQUEST : n_state = (cnt_en + 16'h1 == m_len) ? IDLE : state;
            default: n_state = IDLE;
        endcase

    //cnt_id
    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            cnt_id <= {(ADDRESS){1'b0}};
        end
        else if (m_len == 13'h0120) begin //Link_id 5
            cnt_id <= id5;
        end
        else if (m_len == 13'h02a0) begin //Link_id 6
            cnt_id <= id6;
        end
        else if (m_len == 13'h0420) begin //Link_id 7
            cnt_id <= id7;
        end
        else if (m_len == 13'h01b0) begin //Link_id 11
            cnt_id <= id11;
        end
        else if (m_len == 13'h0750) begin //Link_id 17
            cnt_id <= id17;
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
    

    assign enable = cnt_en;
    assign id_jump = cnt_id;
    assign wen = wen_d;
endmodule
