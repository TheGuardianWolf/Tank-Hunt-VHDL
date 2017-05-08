LIBRARY ieee;
USE ieee.std_logic_1164.all;

-- Inputs: 		b 		(binary input)
-- Outputs: 	s 		(seven segment output)

ENTITY binary2sevenseg is
  port( b : in	STD_LOGIC_VECTOR (3 downto 0);
        s : out STD_LOGIC_VECTOR (7 downto 0)
  );
END binary2sevenseg;

-- This describes the functionality of the binary converter.
architecture converter of binary2sevenseg is
  begin
    -- Map truth table
    with b select
      s <= "11000000" when "0000",
           "11111001" when "0001",
           "10100100" when "0010",
           "10110000" when "0011",
           "10011001" when "0100",
           "10010010" when "0101",
           "10000010" when "0110",
           "11111000" when "0111",
           "10000000" when "1000",
           "10011000" when "1001",
           "10001000" when "1010",
           "10000011" when "1011",
           "11000110" when "1100",
           "10100001" when "1101",
           "10000110" when "1110",
           "10001110" when "1111",
           "11111111" when others;
end converter;
