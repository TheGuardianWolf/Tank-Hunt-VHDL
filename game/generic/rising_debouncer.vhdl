-- Debouncer that triggers on rising edge for one clock cycle

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity collision_detect_u is
    generic(
        size: integer := 10;
        a_length: integer := 64;
        b_length: integer := 64
    );
    port(
        clk_50M: in std_logic;
        a_x: in std_logic_vector(size-1 downto 0);
        a_y: in std_logic_vector(size-1 downto 0);
        b_x: in std_logic_vector(size-1 downto 0);
        b_y: in std_logic_vector(size-1 downto 0);
        collision: out std_logic := '0'
    );
end entity;

architecture behavior of collision_detect_u is
    signal top_left, top_right, bottom_left, bottom_right: std_logic := '0';
begin
    top_left <= '1' when unsigned(a_x) < (unsigned(b_x) + to_unsigned(b_length, size)) else '0';
    top_right <= '1' when (unsigned(a_x) + to_unsigned(a_length, size)) > unsigned(b_x) else '0';
    bottom_left <= '1' when unsigned(a_y) < (unsigned(b_Y) + to_unsigned(b_length, size)) else '0';
    bottom_right <= '1' when (unsigned(a_y) + to_unsigned(a_length, size)) > unsigned(b_y) else '0';

    process(clk_50M)
    begin
        if (rising_edge(clk_50M)) then
            collision <= top_left and top_right and bottom_left and bottom_right;
        end if;
    end process;
end architecture;