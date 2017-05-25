-- Linear Feedback Shift Register

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lfsr_g is
    port (
        Clk: in std_logic;
        Reset: in std_logic;
        Enable: in std_logic;
        Seed: in std_logic_vector(15 downto 0);
        Q: out std_logic_vector(15 downto 0) := (others => '0')
    );
end entity;

architecture behavior of lfsr_g is
    signal sig_q: std_logic_vector(15 downto 0) := (others => '0');
begin
    process(clk, Reset, Seed)
        variable seeded: std_logic := '0';
    begin
        if (Reset = '1') then
            seeded := '0';
            sig_q <= Seed;
        elsif(rising_edge(clk)) then
            if (Enable = '1') then
                if (seeded = '0') then
                    seeded := '1';
                    sig_q(15) <= Seed(0);
                    sig_q(9 downto 0) <= Seed(10 downto 1);
                    sig_q(10) <= Seed(0) xor Seed(11);
                    sig_q(11) <= Seed(12);
                    sig_q(12) <= Seed(0) xor Seed(13);
                    sig_q(13) <= Seed(0) xor Seed(14);
                    sig_q(14) <= Seed(15);
                else
                    sig_q(15) <= sig_q(0);
                    sig_q(9 downto 0) <= sig_q(10 downto 1);
                    sig_q(10) <= sig_q(0) xor sig_q(11);
                    sig_q(11) <= sig_q(12);
                    sig_q(12) <= sig_q(0) xor sig_q(13);
                    sig_q(13) <= sig_q(0) xor sig_q(14);
                    sig_q(14) <= sig_q(15);
                end if;
            end if;
        end if;
    end process;

    Q <= sig_q;
end architecture;