library verilog;
use verilog.vl_types.all;
entity turbo_rx is
    generic(
        D_WIDTH         : integer := 2;
        A_WIDTH         : integer := 12
    );
    port(
        clk             : in     vl_logic;
        n_rst           : in     vl_logic;
        wdata           : in     vl_logic_vector;
        waddr           : in     vl_logic_vector;
        pb_offset       : in     vl_logic_vector;
        pb_len          : in     vl_logic_vector;
        wen             : in     vl_logic;
        start           : in     vl_logic;
        mod_int_dint    : in     vl_logic;
        rdata0          : out    vl_logic_vector;
        rdata1          : out    vl_logic_vector;
        rdata2          : out    vl_logic_vector;
        rdata3          : out    vl_logic_vector;
        din_vld         : in     vl_logic;
        dout_vld        : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of D_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of A_WIDTH : constant is 1;
end turbo_rx;
