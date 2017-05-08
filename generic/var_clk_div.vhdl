library ieee;
use ieee.std_logic_1164.all;

entity var_clk_div is
    generic (
        size: integer := 2
    );
    port( 
        clk: in std_logic;
        clk_div: out std_logic_vector(size downto 0) := (others => '0')
    );
end entity;

architecture behavior of var_clk_div is
    signal tff_nq: std_logic_vector(size downto 0) := (others => '1');
    component TFF
        port(
            T: in std_logic;
            Q: out std_logic;
            NQ: out std_logic;
        );
    end component;
begin
    Toggle: for i in 0 to size generate
        Toggle_Init: if i = 0 generate
            T0: TFF port map(
                clk,
                clk_div(0),
                tff_nq(0)
            );
        end generate;

        Toggle_Seq: if i > 0 generate
            TX: TFF port map (
                tff_nq(i-1), 
                clk_div(i), 
                tff_nq(i), 
            );
        end generate;
    end generate;
end architecture;