-- Debouncer that triggers on rising edge for one clock cycle

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rising_debouncer is
    port(
        sig_in: in std_logic;
        sig_out: out std_logic := '0'
    );
end entity;

architecture behavior of rising_debouncer is
    signal debounced_output: std := '0';
begin
end architecture;