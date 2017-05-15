library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_var_clk_div is
end entity test_var_clk_div;

architecture test of test_var_clk_div is
    signal t_clk: std_logic := '0';
    signal t_clk_div: std_logic_vector(19 downto 0) := (others => '0');

    component var_clk_div
        generic(
            size: integer
        );
        port( 
            clk: in std_logic;
            clk_div: out std_logic_vector(size downto 0)
        );
    end component;

begin
    div: var_clk_div 
    generic map(
        20
    )
    port map(
        t_clk,
        t_clk_div
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