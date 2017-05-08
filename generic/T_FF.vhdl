library ieee;
use ieee.std_logic_1164.all;

entity T_FF is
    port( 
        T: in std_logic;
        Q: out std_logic := '0';
        NQ: out std_logic := '1'
    );
end T_FF;

architecture behavior of T_FF is
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