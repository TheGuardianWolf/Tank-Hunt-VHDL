library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_time_s is
end entity;

architecture test of test_time_s is
    component time_s is
    port(
        clk_50: in std_logic;
        enable: in std_logic;
        reset: in std_logic;
        T: out std_logic_vector(5 downto 0) := (others => '0')
    );
    end component;
    signal t_clk: std_logic := '0';
    signal t_T: std_logic_vector(5 downto 0) := (others => '0');
    signal started: std_logic := '0';
begin
    div: time_s
    port map(
        t_clk,
        started,
        '0',
        t_T
    );

    -- clock generation
    process
    begin
        wait for 100 ps;
        t_clk <= '1';
        wait for 100 ps;
        t_clk <= '0';
    end process;

    process(t_clk)
        if (not started) then
            started <= '1';
        end if;
    end process;

end architecture;