library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux is
    generic(
        input_count: integer := 2;
        input_width: integer := 1;
        sel_size: integer := 1
    );
    port (
        sel: in std_logic_vector(sel_size-1 downto 0);
        inputs: in std_logic_vector(input_count*input_width-1 downto 0);
        r: out std_logic_vector(input_width-1 downto 0) := (others => '0');
    );
end entity;

architecture behavior of mux is
begin
    r <= inputs(to_integer((unsigned(sel))+1)*input_width-1 downto to_integer(unsigned(sel))*input_width); 
end architecture;