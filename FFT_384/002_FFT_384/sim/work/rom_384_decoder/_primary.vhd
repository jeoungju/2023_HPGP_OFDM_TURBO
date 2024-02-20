library verilog;
use verilog.vl_types.all;
entity rom_384_decoder is
    generic(
        D_WIDTH         : integer := 4;
        A_WIDTH         : integer := 8;
        COS_SIN         : integer := 16
    );
    port(
        clk             : in     vl_logic;
        n_rst           : in     vl_logic;
        din_num         : in     vl_logic_vector(8 downto 0);
        din_vld         : in     vl_logic;
        dout            : out    vl_logic_vector;
        dout_vld        : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of D_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of A_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of COS_SIN : constant is 1;
end rom_384_decoder;
