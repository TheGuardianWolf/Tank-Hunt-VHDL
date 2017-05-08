library ieee;
use ieee.std_logic_1164.all;

entity TFF is
    port( 
        T: in std_logic;
        Q: out std_logic := '0';
        NQ: out std_logic := '1'
    );
end TFF;

architecture behavior of TFF is
begin
    process(T)
        variable value: std_logic := '0';
    begin
        if(rising_edge(T)) then
            NQ <= value;
            value := not value;
            Q <= value; 
        end if;
    end process;
end architecture;