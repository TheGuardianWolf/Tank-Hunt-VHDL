-- Register made with D flip flops

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_d is
    generic(
        size: integer := 1
    );
    port (
        Clk: in std_logic;
        Reset: in std_logic;
        Enable: in std_logic;
        D: in std_logic_vector(size-1 downto 0);
        Q: out std_logic_vector(size-1 downto 0) := (others => '0')
    );
end entity;

architecture behavior of register_d is
begin
    process(clk, Reset)
    begin
        if (Reset = '1') then
            Q <= (others => '0');
        elsif(rising_edge(clk)) then
            if (Enable = '1') then
                Q <= D;
            end if;
        end if;
    end process;
end architecture;