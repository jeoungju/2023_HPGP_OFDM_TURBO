library verilog;
use verilog.vl_types.all;
entity complex_signed_mult is
    generic(
        D1_SIZE         : integer := 13;
        D2_SIZE         : integer := 11
    );
    port(
        clk             : in     vl_logic;
        n_rst           : in     vl_logic;
        di_vld          : in     vl_logic;
        d1_re           : in     vl_logic_vector;
        d1_im           : in     vl_logic_vector;
        d2_re           : in     vl_logic_vector;
        d2_im           : in     vl_logic_vector;
        do_vld          : out    vl_logic;
        do_re           : out    vl_logic_vector;
        do_im           : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of D1_SIZE : constant is 1;
    attribute mti_svvh_generic_type of D2_SIZE : constant is 1;
end complex_signed_mult;
