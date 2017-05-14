library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_counter is
end entity;

architecture test of test_counter is
    component counter
        generic(
            size: integer
        );
        port( 
            Clk: in std_logic;
            Reset: in std_logic;
            Enable: in std_logic;
            Limit: in std_logic_vector(size-1 downto 0);
            C: out std_logic_vector(size-1 downto 0)
        );
    end component;
    signal t_clk: std_logic := '0';
    signal t_C: std_logic_vector(1 downto 0) := "00";
begin
    div: counter
    generic map(
        2
    )
    port map(
        t_clk,
        '0',
        '1',
        "10",
        t_C
    );

    -- clock generation
    process
    begin
        wait for 50 ps;
        t_clk <= '1';
        wait for 50 ps;
        t_clk <= '0';
    end process;
end architecture;