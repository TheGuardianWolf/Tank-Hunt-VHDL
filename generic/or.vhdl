library ieee;
use ieee.std_logic_1164.all;

entity or is
    generic(
        size: integer := 1;
    );
    port (
        Clk: in std_logic;
        Reset: in std_logic;
        Enable: in std_logic;
        Limit: in unsigned(size-1 downto 0) := (others => '1');
        C: out unsigned(size-1 downto 0) := (others => '0')
    );
end entity;

architecture behavior of or is
begin
    process(clk)
        variable count: unsigned(size-1 downto 0) := (others => '0');
    begin
        if(rising_edge(clk)) then
            if (count = Limit) then
                count := 0;
            else
                count := count + 1;
            end if;
            C <= count;
        end if;
    end process;
end architecture;