library verilog;
use verilog.vl_types.all;
entity testbench is
    generic(
        D1_SIZE         : integer := 13;
        D2_SIZE         : integer := 11;
        SIGN_BIT        : integer := 1;
        INT_BIT         : integer := 6;
        FLT_BIT         : integer := 6
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of D1_SIZE : constant is 1;
    attribute mti_svvh_generic_type of D2_SIZE : constant is 1;
    attribute mti_svvh_generic_type of SIGN_BIT : constant is 1;
    attribute mti_svvh_generic_type of INT_BIT : constant is 1;
    attribute mti_svvh_generic_type of FLT_BIT : constant is 1;
end testbench;
