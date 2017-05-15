-- Outputs a clock signal that can be used to count seconds

library ieee;
use ieee.std_logic_1164.all;

entity clk_s is
    port(
        clk_50M: in std_logic;
        clk_s: out std_logic := '1'
    );
end entity;

architecture behaviour of clk_s is
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
    signal half_s: std_logic_vector(24 downto 0) := "1011111010111100001000000";
    signal clk_time_c: std_logic_vector(24 downto 0) := (others => '0');
    signal sig_clk_s: std_logic := '1';
    begin
    
    clk_time: counter 
    generic map (
        25
    )    
    port map(
        clk_50M,
        '0',
        '1',
        half_s,
        clk_time_c
    );

    process(clk_50M)
    begin
        if (rising_edge(clk_50M)) then
				 if (half_s = clk_time_c) then
					  sig_clk_s <= not sig_clk_s;
				 end if;
            clk_s <= sig_clk_s;
        end if;
    end process;
end architecture;