-- Collision detection component for square components
-- Place anywhere to enable object collision detection

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

architecture behavior of collision_detect is
    signal top_left, top_right, bottom_left, bottom_right: std_logic := '0';
begin
    top_left <= unsigned(a_x) < (unsigned(b_x) + to_unsigned(b_length, size));
    top_right <= (unsigned(a_x) + to_unsigned(a_length, size)) > unsigned(b_x);
    bottom_left <= unsigned(a_y) < (unsigned(b_Y) - to_unsigned(b_length, size));
    bottom_right <= (unsigned(a_y) - to_unsigned(a_length, size)) > unsigned(b_x);

    collision <= top_left and top_right and bottom_left and bottom_right;
end architecture;