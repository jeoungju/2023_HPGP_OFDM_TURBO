library verilog;
use verilog.vl_types.all;
entity full_384 is
    generic(
        IDLE            : vl_logic_vector(0 to 1) := (Hi0, Hi0);
        MODE_384        : vl_logic_vector(0 to 1) := (Hi0, Hi1);
        MODE_3072       : vl_logic_vector(0 to 1) := (Hi1, Hi0);
        D1_SIZE         : integer := 6;
        D2_SIZE         : integer := 4;
        SIGN_BIT        : integer := 1;
        INT_BIT         : integer := 6;
        FLT_BIT         : integer := 6
    );
    port(
        clk             : in     vl_logic;
        n_rst           : in     vl_logic;
        start           : in     vl_logic;
        mode_3072_384   : in     vl_logic;
        in_vld          : in     vl_logic;
        in_re           : in     vl_logic_vector;
        in_im           : in     vl_logic_vector;
        out_re          : out    vl_logic_vector;
        out_im          : out    vl_logic_vector;
        out_vld         : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of IDLE : constant is 1;
    attribute mti_svvh_generic_type of MODE_384 : constant is 1;
    attribute mti_svvh_generic_type of MODE_3072 : constant is 1;
    attribute mti_svvh_generic_type of D1_SIZE : constant is 1;
    attribute mti_svvh_generic_type of D2_SIZE : constant is 1;
    attribute mti_svvh_generic_type of SIGN_BIT : constant is 1;
    attribute mti_svvh_generic_type of INT_BIT : constant is 1;
    attribute mti_svvh_generic_type of FLT_BIT : constant is 1;
end full_384;
