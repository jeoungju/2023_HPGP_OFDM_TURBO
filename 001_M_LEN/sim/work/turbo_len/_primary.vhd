library verilog;
use verilog.vl_types.all;
entity turbo_len is
    port(
        clk             : in     vl_logic;
        n_rst           : in     vl_logic;
        id_enable       : in     vl_logic;
        link_id         : in     vl_logic_vector(5 downto 0);
        enable          : out    vl_logic_vector(15 downto 0)
    );
end turbo_len;
