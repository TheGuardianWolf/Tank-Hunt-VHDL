library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bin_2_bcd is
    generic(
        digits: integer := 4
    );
    Port ( 
        binary: in  std_logic_vector(4*digits-1 downto 0) := (others => '0');
        bcd: out std_logic_vector(4*digits-1 downto 0) := (others => '0')
    );
end entity;

architecture behavior of bin_2_bcd is

begin

   bin_to_bcd : process (binary)
      -- Internal variable for storing bits
      variable shift : unsigned(8*digits-1 downto 0);
      
	  -- Alias for parts of shift register
      alias num is shift(4*digits-1 downto 0);
      alias dig is shift(8*digits-1 downto 4*digits);
   begin
      -- Clear previous binary and store new binary in shift register
      num := unsigned(binary);
      dig := (others => '0');
      
	  -- Loop eight times
      for i in 1 to num'Length loop
	     -- Check if any digit is greater than or equal to 5
         for j in 0 to digits-1 loop 
            if (dig(j*digits+3 downto j*digits) >= 5) then
                dig(j*digits+3 downto j*digits) := dig(j*digits+3 downto j*digits) + 3;
            end if;
         end loop;
		 -- Shift entire register left once
         shift := shift_left(shift, 1);
      end loop;
      
	  -- Push decimal binarys to output
      bcd <= std_logic_vector(dig);
   end process;

end architecture;