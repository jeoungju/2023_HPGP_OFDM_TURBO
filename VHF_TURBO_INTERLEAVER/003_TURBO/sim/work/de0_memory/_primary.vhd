library verilog;
use verilog.vl_types.all;
entity de0_memory is
    generic(
        D_WIDTH         : integer := 13;
        A_WIDTH         : integer := 16
    );
    port(
        clk             : in     vl_logic;
        n_rst           : in     vl_logic;
        sw              : in     vl_logic_vector(5 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of D_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of A_WIDTH : constant is 1;
end de0_memory;
