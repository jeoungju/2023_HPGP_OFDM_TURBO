//https://aifpga.tistory.com/entry/Verilog-HDL-QA-2-readmemh-%EC%9D%98-%EC%82%AC%EC%9A%A9%EB%B0%A9%EB%B2%95%EA%B3%BC-%EC%82%AC%EC%9A%A9%EC%B2%98

module rom(
    input clk,
    input n_rst,
    input [15:0] addr,
    output [12:0] data
);
parameter D_WIDTH = 13; //
parameter A_WIDTH = 16; //46496 bin 1011_0101_1010_0000 2^16 = 65536



reg [D_WIDTH-1:0] rom [0 : 2**A_WIDTH-1];


initial  begin
    $readmemh("../src/rtl/MEMORY/ter_pi.txt", rom);
end

reg [12:0] data_d;
always @ (posedge clk or negedge n_rst)
    if (!n_rst) begin
        data_d <= 13'h0000;
    end
    else begin
        data_d <= rom[addr];
    end
	
    assign data = data_d;
endmodule

/*
Link Id 4 [0:951]       952
Link Id 5 [952:1239]    288
Link Id 6 [1240:1911]   672
Link Id 7 [1912:2967]   1056
Link Id 8 [2968:3159]   192
Link Id 9 [3160:3607]   448
Link Id 10 [3608:4311]  704
Link Id 11 [4312:4743]  432
Link Id 12 [4744:5715]  972
Link Id 13 [5716:7011]  1296
Link Id 14 [7012:7907]  896
Link Id 15 [7908:9923]  
Link Id 16 [9924:12611] 
Link Id 17 [12612:14483]
Link Id 18 [14484:18515]
Link Id 19 [18516:24131]
Link Id 20 [24132:24227]
Link Id 21 [24228:24963]
Link Id 22 [24964:28083]
Link Id 23 [28084:32627]
Link Id 24 [32628:36415]
Link Id 25 [36416:41191]
Link Id 26 [41192:46647]
Link Id 27 [46648:52679]
Link Id 28 [52680:57959]
Link Id 29 [57960:63511]
Link Id 30 [63512:68831]
Link Id 31 [68832:74159]
Link Id 32 [74160:74471]
Link Id 33 [74472:78751]
Link Id 34 [78752:82911]

always @ (posedge clk)
    begin
        data <= rom[addr];
    end
*/