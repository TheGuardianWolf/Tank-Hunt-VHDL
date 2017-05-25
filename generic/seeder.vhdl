-- Seeder
-- Provides a time based seed for lfsr operation

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seeder is
    port(
        clk_50M: in std_logic;
        lfsr_seed: out std_logic_vector(15 downto 0) := "1010010110101000"
    );
end entity;

architecture behavior of seeder is

begin

end architecture;
