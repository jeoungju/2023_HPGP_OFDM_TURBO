library verilog;
use verilog.vl_types.all;
entity rd3bf is
    generic(
        SIGN_BIT        : integer := 1;
        INT_BIT         : integer := 6;
        FLT_BIT         : integer := 6
    );
    port(
        clk             : in     vl_logic;
        n_rst           : in     vl_logic;
        di_vld          : in     vl_logic;
        in1_re          : in     vl_logic_vector;
        in1_im          : in     vl_logic_vector;
        in2_re          : in     vl_logic_vector;
        in2_im          : in     vl_logic_vector;
        in3_re          : in     vl_logic_vector;
        in3_im          : in     vl_logic_vector;
        out1_re         : out    vl_logic_vector;
        out1_im         : out    vl_logic_vector;
        out2_re         : out    vl_logic_vector;
        out2_im         : out    vl_logic_vector;
        out3_re         : out    vl_logic_vector;
        out3_im         : out    vl_logic_vector;
        do_vld          : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of SIGN_BIT : constant is 1;
    attribute mti_svvh_generic_type of INT_BIT : constant is 1;
    attribute mti_svvh_generic_type of FLT_BIT : constant is 1;
end rd3bf;
