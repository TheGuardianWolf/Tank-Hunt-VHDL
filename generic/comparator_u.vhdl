library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comparator_u is
    generic(
        size: integer := 1
    );
    port (
        a: in std_logic_vector(size-1 downto 0);
        b: in std_logic_vector(size-1 downto 0);
        lt: out std_logic := '0';
        eq: out std_logic := '0';
        gt: out std_logic := '0'
    );
end entity;

architecture behavior of comparator_u is
begin
    lt <= '1' when a < b else '0';
    eq <= '1' when a = b else '0';
    gt <= '1' when a > b else '0';
end architecture;