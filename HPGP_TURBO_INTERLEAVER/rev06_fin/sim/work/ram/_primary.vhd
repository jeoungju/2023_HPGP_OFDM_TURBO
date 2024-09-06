library verilog;
use verilog.vl_types.all;
entity ram is
    generic(
        D_WIDTH         : vl_notype;
        A_WIDTH         : vl_notype
    );
    port(
        clk             : in     vl_logic;
        n_rst           : in     vl_logic;
        waddr           : in     vl_logic_vector;
        wdata           : in     vl_logic_vector;
        wen             : in     vl_logic;
        raddr           : in     vl_logic_vector;
        rdata           : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of D_WIDTH : constant is 5;
    attribute mti_svvh_generic_type of A_WIDTH : constant is 5;
end ram;
