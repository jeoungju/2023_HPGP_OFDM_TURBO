library verilog;
use verilog.vl_types.all;
entity turbo_len is
    port(
        clk             : in     vl_logic;
        n_rst           : in     vl_logic;
        din_vld         : in     vl_logic;
        pb_size         : in     vl_logic_vector(1 downto 0);
        enable          : out    vl_logic_vector(11 downto 0);
        pb_offset       : out    vl_logic_vector(11 downto 0);
        dout_vld        : out    vl_logic
    );
end turbo_len;
