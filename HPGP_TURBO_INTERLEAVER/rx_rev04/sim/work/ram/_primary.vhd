library verilog;
use verilog.vl_types.all;
entity ram is
    generic(
        D_WIDTH         : integer := 2;
        A_WIDTH         : integer := 12
    );
    port(
        clk             : in     vl_logic;
        n_rst           : in     vl_logic;
        wdata           : in     vl_logic_vector;
        raddr           : in     vl_logic_vector;
        waddr           : in     vl_logic_vector;
        wen             : in     vl_logic;
        ren             : in     vl_logic;
        rdata           : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of D_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of A_WIDTH : constant is 1;
end ram;
