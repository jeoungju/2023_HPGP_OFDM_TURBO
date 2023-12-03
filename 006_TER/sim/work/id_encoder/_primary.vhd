library verilog;
use verilog.vl_types.all;
entity id_encoder is
    port(
        clk             : in     vl_logic;
        n_rst           : in     vl_logic;
        link_id         : in     vl_logic_vector(5 downto 0);
        m_len           : out    vl_logic_vector(12 downto 0)
    );
end id_encoder;
