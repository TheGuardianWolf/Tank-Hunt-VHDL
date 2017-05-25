-- Seeder
-- Provides a time based seed for lfsr operation

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seeder is
    port(
        clk_50M: in std_logic;
        lfsr_seed: out std_logic_vector(15 downto 0)
    );
end entity;

architecture behavior of seeder is
    component counter is
        generic(
            size: integer := 1
        );
        port (
            Clk: in std_logic;
            Reset: in std_logic;
            Enable: in std_logic;
            Limit: in std_logic_vector(size-1 downto 0) := (others => '1');
            C: out std_logic_vector(size-1 downto 0) := (others => '0')
        );
    end component;

    signal sig_time_seed: std_logic_vector(15 downto 0) := (others => '0');
begin
    time_seed: counter generic map(
        16
    ) port map (
        clk_50M,
        '0',
        '1',
        (others => '1'),
        sig_time_seed
    );
end architecture;
