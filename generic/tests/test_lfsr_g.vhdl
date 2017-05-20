library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_lfsr_g is
end entity;

architecture test of test_lfsr_g is
    component lfsr_g
        port( 
            Clk: in std_logic;
            Reset: in std_logic;
            Enable: in std_logic;
            Seed: in std_logic_vector(15 downto 0);
            Q: out std_logic_vector(15 downto 0) := (others => '0')
        );
    end component;
    signal t_clk: std_logic := '0';
    signal t_Q: std_logic_vector(15 downto 0) := (others => '0');
begin
    rand: lfsr_g
    port map(
        t_clk,
        '0',
        '1',
        x"F1A6",
        t_Q
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