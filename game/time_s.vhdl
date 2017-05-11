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
    signal clk_time_c: std_logic_vector(25 downto 0) := (others => '0');
    signal clk_50_period: std_logic_vector(25 downto 0) := "10111110101111000010000000";
    signal tick: std_logic := '0';
    begin;
    
    clk_time: counter 
    generic map (
        26
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
        5
    )    
    port map(
        clk_50,
        reset,
        tick,
        ,
        T
    );

    tick <= '1' when (rising_edge(clk) and (clk_time_c = clk_50_period)) else '0';

        
    end process;
    



end architecture;