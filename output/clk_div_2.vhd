Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity div_2 is
	port (
		clk : in std_logic;
		clk_out : out std_logic
	);
end entity;

architecture arch of div_2 is
signal clk_temp : std_logic;
begin
process(clk)
begin
	if (clk'event and clk = '1') then
		clk_temp <= not clk_temp;
	end if;
	clk_out <= clk_temp;
end process;
end architecture;
		