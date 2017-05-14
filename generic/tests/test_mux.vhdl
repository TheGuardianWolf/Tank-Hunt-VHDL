library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_mux is
end entity;

architecture test of test_mux is
    component mux is
        generic(
            input_count: integer;
            input_width: integer;
            sel_size: integer
        );
        port (
            sel: in std_logic_vector(sel_size-1 downto 0);
            inputs: in std_logic_vector(input_count*input_width-1 downto 0);
            r: out std_logic_vector(input_width-1 downto 0)
        );
    end component;
    signal result: std_logic_vector(2 downto 0);
    signal s: std_logic_vector(1 downto 0);
begin
    mux_sel_0: mux
    generic map(
        4,
        3,
        2
    )
    port map(
        s,
        "111100011000",
        result
    );

    s <= "00", "01" after 50 ps, "10" after 100 ps, "11" after 150 ps;
end architecture;