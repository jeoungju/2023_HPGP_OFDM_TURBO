library verilog;
use verilog.vl_types.all;
entity top is
    port(
        clk             : in     vl_logic;
        n_rst           : in     vl_logic;
        link_id         : in     vl_logic_vector(5 downto 0);
        din             : in     vl_logic;
        din_vld         : in     vl_logic;
        request         : in     vl_logic;
        rdata           : out    vl_logic;
        rdata_itl       : out    vl_logic;
        rdata_ditl      : out    vl_logic;
        dout_vld        : out    vl_logic
    );
end top;
