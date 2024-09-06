library verilog;
use verilog.vl_types.all;
entity top is
    port(
        clk             : in     vl_logic;
        n_rst           : in     vl_logic;
        pb_size         : in     vl_logic_vector(1 downto 0);
        din             : in     vl_logic_vector(1 downto 0);
        din_vld         : in     vl_logic;
        rdata           : out    vl_logic_vector(1 downto 0);
        rdata_ditl      : out    vl_logic_vector(1 downto 0);
        dout_vld        : out    vl_logic
    );
end top;
