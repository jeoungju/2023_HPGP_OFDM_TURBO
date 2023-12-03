library verilog;
use verilog.vl_types.all;
entity top is
    port(
        clk             : in     vl_logic;
        n_rst           : in     vl_logic;
        id_enable       : in     vl_logic;
        link_id         : in     vl_logic_vector(5 downto 0);
        data            : out    vl_logic_vector(12 downto 0)
    );
end top;
