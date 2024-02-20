library verilog;
use verilog.vl_types.all;
entity testbench is
    generic(
        D_WIDTH         : integer := 4;
        A_WIDTH         : integer := 9;
        COS_SIN         : integer := 16
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of D_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of A_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of COS_SIN : constant is 1;
end testbench;
