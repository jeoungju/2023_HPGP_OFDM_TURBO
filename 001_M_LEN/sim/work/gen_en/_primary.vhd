library verilog;
use verilog.vl_types.all;
entity gen_en is
    generic(
        STATE_LEN       : integer := 2;
        ADDRESS         : integer := 16
    );
    port(
        clk             : in     vl_logic;
        n_rst           : in     vl_logic;
        m_len           : in     vl_logic_vector(12 downto 0);
        enable          : out    vl_logic_vector(15 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of STATE_LEN : constant is 1;
    attribute mti_svvh_generic_type of ADDRESS : constant is 1;
end gen_en;
