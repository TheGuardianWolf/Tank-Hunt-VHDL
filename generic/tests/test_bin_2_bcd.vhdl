LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY TB_bcd IS
END TB_bcd;
 
ARCHITECTURE behavior OF TB_bcd IS 
 
   -- Component Declaration for the Unit Under Test (UUT)
   component bin_2_bcd is
        generic(
            digits: integer := 4
        );
        Port ( 
            binary: in  std_logic_vector(4*digits-1 downto 0);
            bcd: out std_logic_vector(4*digits-1 downto 0)
        );
    end component;
   
    --Inputs
    signal number   : std_logic_vector(15 downto 0) := (others => '0');

    --Outputs
    signal thousands: std_logic_vector(3 downto 0);
    signal hundreds : std_logic_vector(3 downto 0);
    signal tens     : std_logic_vector(3 downto 0);
    signal ones     : std_logic_vector(3 downto 0);
 
BEGIN
 
   -- Instantiate the Unit Under Test (UUT)
   uut: bin_2_bcd
    generic map(4)
      port map (
         binary   => number,
         bcd(15 downto 12) => thousands,
         bcd(11 downto 8) => hundreds,
         bcd(7 downto 4) => tens,
         bcd(3 downto 0) => ones
      );

   -- Stimulus process
   stim_proc: process
   begin      
      loop
         number <= std_logic_vector(unsigned(number) + 1);
         
         wait for 1 ns;
      end loop;
      
      wait;
   end process;

end;