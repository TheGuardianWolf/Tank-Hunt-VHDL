library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_comparator_u is
end entity;

architecture test of test_comparator_u is
    component comparator_u
        generic(
            size: integer
        );
        port (
            a: in std_logic_vector(size-1 downto 0);
            b: in std_logic_vector(size-1 downto 0);
            lt: out std_logic := '0';
            eq: out std_logic := '0';
            gt: out std_logic := '0'
        );
    end component;
    signal result_lt: std_logic_vector(2 downto 0);
    signal result_eq: std_logic_vector(2 downto 0);
    signal result_gt: std_logic_vector(2 downto 0);
begin
    comp_lt: comparator_u 
    generic map(
        2
    )
    port map(
        "00",
        "11",
        result_lt(0),
        result_eq(0),
        result_gt(0)
    );

    comp_eq: comparator_u 
    generic map(
        2
    )
    port map(
        "01",
        "01",
        result_lt(1),
        result_eq(1),
        result_gt(1)
    );

    comp_gt: comparator_u 
    generic map(
        2
    )
    port map(
        "10",
        "00",
        result_lt(2),
        result_eq(2),
        result_gt(2)
    );
end architecture;