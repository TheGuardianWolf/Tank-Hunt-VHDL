library ieee;
use ieee.std_logic_1164.all;

entity time_s is
    port(
        clk_50: in std_logic;
        enable: in std_logic;
        reset: in std_logic;
        T: out std_logic_vector(5 downto 0) := (others => '0')
    );
end entity;

architecture behaviour of time_s is
    component counter
        generic(
            size: integer
        );
        port (
            Clk: in std_logic;
            Reset: in std_logic;
            Enable: in std_logic;
            Limit: in std_logic_vector(size-1 downto 0);
            C: out std_logic_vector(size-1 downto 0)
        );
    end component;
    signal clk_time_c: std_logic_vector(24 downto 0) := (others => '0');
    signal clk_50_period: std_logic_vector(24 downto 0) := "1011111010111100001000000";
    signal clk_s: std_logic := '1';
    signal tick: std_logic := '0';
    begin
    
    clk_time: counter 
    generic map (
        25
    )    
    port map(
        clk_50,
        reset,
        enable,
        clk_50_period,
        clk_time_c
    );

    time: counter 
    generic map (
        6
    )    
    port map(
        clk_s,
        reset,
        enable,
        (others => '1'),
        T
    );

    process(clk_50)
    begin
        if rising_edge(clk_50) then
            if (clk_50_period = clk_time_c) then
                clk_s <= not clk_s;
            end if;
        end if;
    end process;
end architecture;