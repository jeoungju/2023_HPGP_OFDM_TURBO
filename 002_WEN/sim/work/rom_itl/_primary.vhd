library verilog;
use verilog.vl_types.all;
entity rom_itl is
    generic(
        A_WIDTH         : integer := 16
    );
    port(
        clk             : in     vl_logic;
        n_rst           : in     vl_logic;
        waddr           : in     vl_logic_vector(15 downto 0);
        id_jump         : in     vl_logic_vector(15 downto 0);
        itl_addr        : out    vl_logic_vector(15 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of A_WIDTH : constant is 1;
end rom_itl;
