library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bin_2_bcd_4 is
    Port ( 
        binary: in  std_logic_vector(15 downto 0) := (others => '0');
        bcd: out std_logic_vector(15 downto 0) := (others => '0')
    );
end entity;

architecture behavior of bin_2_bcd_4 is
begin
   bin_to_bcd : process (binary)
      -- Internal variable for storing bits
      variable shift : unsigned(31 downto 0);
      
	  -- Alias for parts of shift register
      alias num is shift(15 downto 0);
      alias dig is shift(31 downto 16);
   begin
      -- Clear previous binary and store new binary in shift register
      num := unsigned(binary);
      dig := (others => '0');
      
	  -- Loop eight times
      for i in 1 to num'Length loop
	     -- Check if any digit is greater than or equal to 5
         if dig(31 downto 28) >= 5 then
            dig(31 downto 28) := dig(31 downto 28) + 3;
         end if;
         
         if dig(27 downto 24) >= 5 then
            dig(27 downto 24) := dig(27 downto 24) + 3;
         end if;
         
         if dig(23 downto 20) >= 5 then
            dig(23 downto 20) := dig(23 downto 20) + 3;
         end if;

         if dig(19 downto 16) >= 5 then
            dig(19 downto 16) := dig(19 downto 16) + 3;
         end if;
		 -- Shift entire register left once
         shift := shift_left(shift, 1);
      end loop;
      
	  -- Push decimal binarys to output
      bcd <= std_logic_vector(dig);
   end process;

end architecture;