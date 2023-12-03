library verilog;
use verilog.vl_types.all;
entity ram_dual is
    generic(
        D_WIDTH         : integer := 1;
        A_WIDTH         : integer := 16
    );
    port(
        clk             : in     vl_logic;
        n_rst           : in     vl_logic;
        wdata           : in     vl_logic;
        waddr           : in     vl_logic_vector(15 downto 0);
        id_jump         : in     vl_logic_vector(15 downto 0);
        rdata           : out    vl_logic;
        rdata_itl       : out    vl_logic;
        wen             : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of D_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of A_WIDTH : constant is 1;
end ram_dual;
