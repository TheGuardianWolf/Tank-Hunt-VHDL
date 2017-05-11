library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity D_FF is
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

architecture behavior of D_FF is
begin
    process(clk)
    begin
        if(rising_edge(clk)) then
            if (Reset = '1') then
                Q <= (others => '0');
            elsif (Enable = '1') then
                Q <= D;
            end if;
        end if;
    end process;
end architecture;