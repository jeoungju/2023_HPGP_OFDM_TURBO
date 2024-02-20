library verilog;
use verilog.vl_types.all;
entity gen_en is
    generic(
        STATE_LEN       : integer := 2;
        ADDRESS         : integer := 12
    );
    port(
        clk             : in     vl_logic;
        n_rst           : in     vl_logic;
        din_vld         : in     vl_logic;
        len_l           : in     vl_logic_vector(11 downto 0);
        enable          : out    vl_logic_vector(11 downto 0);
        pb_offset       : out    vl_logic_vector(11 downto 0);
        wen             : out    vl_logic;
        dout_vld        : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of STATE_LEN : constant is 1;
    attribute mti_svvh_generic_type of ADDRESS : constant is 1;
end gen_en;
