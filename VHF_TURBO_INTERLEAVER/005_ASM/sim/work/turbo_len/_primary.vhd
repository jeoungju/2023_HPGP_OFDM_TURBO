library verilog;
use verilog.vl_types.all;
entity turbo_len is
    port(
        clk             : in     vl_logic;
        n_rst           : in     vl_logic;
        din_vld         : in     vl_logic;
        request         : in     vl_logic;
        link_id         : in     vl_logic_vector(5 downto 0);
        enable          : out    vl_logic_vector(15 downto 0);
        id_offset       : out    vl_logic_vector(15 downto 0);
        wen             : out    vl_logic;
        dout_vld        : out    vl_logic
    );
end turbo_len;
