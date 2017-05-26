-- Seeder
-- Provides a time based seed for lfsr operation

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seeder is
    port(
        clk_50M: in std_logic;
        lfsr_seed: out std_logic_vector(15 downto 0) := (others => '0')
    );
end entity;

architecture behavior of seeder is
    component lfsr_g is
        port (
            Clk: in std_logic;
            Reset: in std_logic;
            Enable: in std_logic;
            Seed: in std_logic_vector(15 downto 0);
            Q: out std_logic_vector(15 downto 0) := (others => '0')
        );
    end component;
begin
    rand_seeder: lfsr_g port map(
        clk_50M,
        '0',
        '1',
        "1010010110101000",
        lfsr_seed
    );
end architecture;
