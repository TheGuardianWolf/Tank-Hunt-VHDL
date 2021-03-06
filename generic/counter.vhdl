-- Counter for keeping track of increasing values

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
    generic(
        size: integer := 1
    );
    port (
        Clk: in std_logic;
        Reset: in std_logic;
        Enable: in std_logic;
        Limit: in std_logic_vector(size-1 downto 0) := (others => '1');
        C: out std_logic_vector(size-1 downto 0) := (others => '0')
    );
end entity;

architecture behavior of counter is
begin
    process(clk, Reset)
        variable count: std_logic_vector(size-1 downto 0) := (others => '0');
    begin
        if (Reset='1') then
            count := (others => '0');
        elsif(rising_edge(clk)) then
            if (Enable = '1') then
                if (count = Limit) then
                    count := (others => '0');
                else
                    count := std_logic_vector(unsigned(count) + 1);
                end if; 
            end if;
        end if;
        C <= count;
    end process;
end architecture;