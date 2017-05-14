library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity input_buffer is
    generic(
        size: integer := 1
    );
    port (
        Clk: in std_logic;
        D: in std_logic_vector(size-1 downto 0);
        Q: out std_logic_vector(size-1 downto 0) := (others => '0')
    );
end entity;

architecture behavior of input_buffer is
begin
    process(clk)
    begin
        if(rising_edge(clk)) then
            Q <= D;
        end if;
    end process;
end architecture;
