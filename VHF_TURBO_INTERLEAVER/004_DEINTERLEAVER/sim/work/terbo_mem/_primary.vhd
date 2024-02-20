library verilog;
use verilog.vl_types.all;
entity terbo_mem is
    port(
        clk             : in     vl_logic;
        n_rst           : in     vl_logic;
        wen             : in     vl_logic;
        enable          : in     vl_logic_vector(15 downto 0);
        rdata           : out    vl_logic_vector(12 downto 0);
        rdata_itl       : out    vl_logic_vector(12 downto 0)
    );
end terbo_mem;
