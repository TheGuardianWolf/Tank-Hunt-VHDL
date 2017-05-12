library ieee;
use ieee.std_logic_1164.all;

entity clk_s is
    port(
        clk_50M: in std_logic;
        reset: in std_logic;
        enable: in std_logic;
        clk_s: out std_logic := '1';
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
    signal half_s: std_logic_vector(24 downto 0) := "1011111010111100001000000";
    begin
    
    clk_time: counter 
    generic map (
        25
    )    
    port map(
        clk_50M,
        reset,
        enable,
        half_s,
        clk_s
    );

    process(clk_50M)
    begin
        if (rising_edge(clk_50M)) then
            if (enable='1') then
                if (clk_50M_period = clk_time_c) then
                    clk_s <= not clk_s;
                end if;
            end if;
        end if;
    end process;
end architecture;