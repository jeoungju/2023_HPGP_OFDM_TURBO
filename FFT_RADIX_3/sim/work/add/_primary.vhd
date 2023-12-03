library verilog;
use verilog.vl_types.all;
entity add is
    generic(
        SIGN_BIT        : integer := 1;
        INT_BIT         : integer := 6;
        FLT_BIT         : integer := 6
    );
    port(
        din_a           : in     vl_logic_vector;
        din_b           : in     vl_logic_vector;
        dout            : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of SIGN_BIT : constant is 1;
    attribute mti_svvh_generic_type of INT_BIT : constant is 1;
    attribute mti_svvh_generic_type of FLT_BIT : constant is 1;
end add;
