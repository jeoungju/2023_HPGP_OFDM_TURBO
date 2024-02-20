library verilog;
use verilog.vl_types.all;
entity pb_encoder is
    port(
        clk             : in     vl_logic;
        n_rst           : in     vl_logic;
        pb_size         : in     vl_logic_vector(1 downto 0);
        len_l           : out    vl_logic_vector(11 downto 0)
    );
end pb_encoder;
