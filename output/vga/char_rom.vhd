

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.NUMERIC_STD.all;

LIBRARY altera_mf;
USE altera_mf.all;

ENTITY char_rom IS
	PORT
	(
		vga_row			: 	IN STD_LOGIC_VECTOR (9 DOWNTO 0);--current pixel row of the VGA 
		vga_col			: 	IN STD_LOGIC_VECTOR (9 DOWNTO 0);--current pixel column of the VGA
		character_address	:	IN STD_LOGIC_VECTOR (5 DOWNTO 0);--address of the character needed
		font_row, font_col	:	IN STD_LOGIC_VECTOR (2 DOWNTO 0); 
		clock				: 	IN STD_LOGIC ;
		mouse_hor : IN STD_LOGIC_VECTOR (9 downto 0); -- horizontal position of the mouse
		--q					: 	OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
		rom_mux_output		:	OUT STD_LOGIC--bit value for the current pixel
	);
END char_rom;


ARCHITECTURE SYN OF char_rom IS

	SIGNAL rom_data		: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL rom_address	: STD_LOGIC_VECTOR (8 DOWNTO 0);

	COMPONENT altsyncram
	GENERIC (
		address_aclr_a			: STRING;
		clock_enable_input_a	: STRING;
		clock_enable_output_a	: STRING;
		init_file				: STRING;
		intended_device_family	: STRING;
		lpm_hint				: STRING;
		lpm_type				: STRING;
		numwords_a				: NATURAL;
		operation_mode			: STRING;
		outdata_aclr_a			: STRING;
		outdata_reg_a			: STRING;
		widthad_a				: NATURAL;
		width_a					: NATURAL;
		width_byteena_a			: NATURAL
	);
	PORT (
		clock0		: IN STD_LOGIC ;
		address_a	: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
		q_a			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
	END COMPONENT;

BEGIN
	--rom_mux_output	<= sub_wire0(7 DOWNTO 0);

	altsyncram_component : altsyncram
	GENERIC MAP (
		address_aclr_a => "NONE",
		clock_enable_input_a => "BYPASS",
		clock_enable_output_a => "BYPASS",
		init_file => "tcgrom.mif",
		intended_device_family => "Cyclone III",
		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
		lpm_type => "altsyncram",
		numwords_a => 512,
		operation_mode => "ROM",
		outdata_aclr_a => "NONE",
		outdata_reg_a => "UNREGISTERED",
		widthad_a => 9,
		width_a => 8,
		width_byteena_a => 1
	)
	PORT MAP (
		clock0 => clock,
		address_a => rom_address,
		q_a => rom_data
	);
	
	process(clock)
	begin
	if (rising_edge(clock)) then
		--tank display, with mouse x position as input for reference
		IF (("0110011" <= vga_row(9 downto 3)) and (vga_row(9 downto 3) <= "0111011")) THEN
			IF ((mouse_hor(9 downto 3) < vga_col(9 downto 3)) and (vga_col(9 downto 3) <= std_logic_vector(unsigned(mouse_hor(9 downto 3))+ 8))) THEN
				--concatenate character address and font row address into a 9 bit address
				rom_address <= "111111" & std_logic_vector(unsigned(vga_row(5 downto 3))-3);
				--select of the mux for which column in the row the pixel data is chosen from
				rom_mux_output <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(5 DOWNTO 3))-(unsigned(mouse_hor(5 downto 3))+1)))));
			ELSE 
				rom_mux_output <= '0';
			END IF;
		--below code displays "TANK GAME"
		ELSIF (("0001000" < vga_row(9 downto 3)) and (vga_row(9 downto 3) <= "0010000")) THEN
			--T
			IF(("0000100" < vga_col(9 downto 3)) and (vga_col(9 downto 3) <= "0001100")) THEN 
				rom_address <= "010100" & std_logic_vector(unsigned(vga_row(5 downto 3))-1);
				rom_mux_output <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(5 DOWNTO 3))-5))));
			ELSIF(("0001100" < vga_col(9 downto 3)) and (vga_col(9 downto 3) <= "0010100")) THEN
			--A
				rom_address <= "000001" & std_logic_vector(unsigned(vga_row(5 downto 3))-1);
				rom_mux_output <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(5 DOWNTO 3))-5))));
			ELSIF(("0010100" < vga_col(9 downto 3)) and (vga_col(9 downto 3) <= "0011100")) THEN
			--N
				rom_address <= "001110" & std_logic_vector(unsigned(vga_row(5 downto 3))-1);
				rom_mux_output <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(5 DOWNTO 3))-5))));
			ELSIF(("0011100" < vga_col(9 downto 3)) and (vga_col(9 downto 3) <= "0100100")) THEN
			--K
				rom_address <= "001011" & std_logic_vector(unsigned(vga_row(5 downto 3))-1);
				rom_mux_output <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(5 DOWNTO 3))-5))));
				
			--G
			ELSIF(("0101100" < vga_col(9 downto 3)) and (vga_col(9 downto 3) <= "0110100")) THEN 
				rom_address <= "000111" & std_logic_vector(unsigned(vga_row(5 downto 3))-1);
				rom_mux_output <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(5 DOWNTO 3))-5))));
			--A
			ELSIF(("0110100" < vga_col(9 downto 3)) and (vga_col(9 downto 3) <= "0111100")) THEN
				rom_address <= "000001" & std_logic_vector(unsigned(vga_row(5 downto 3))-1);
				rom_mux_output <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(5 DOWNTO 3))-5))));
			--M
			ELSIF(("0111100" < vga_col(9 downto 3)) and (vga_col(9 downto 3) <= "1000100")) THEN
				rom_address <= "001101" & std_logic_vector(unsigned(vga_row(5 downto 3))-1);
				rom_mux_output <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(5 DOWNTO 3))-5))));
			--E
			ELSIF(("1000100" < vga_col(9 downto 3)) and (vga_col(9 downto 3) <= "1001100")) THEN
				rom_address <= "000101" & std_logic_vector(unsigned(vga_row(5 downto 3))-1);
				rom_mux_output <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(5 DOWNTO 3))-5))));
			ELSE
				rom_mux_output <= '0';
			END IF;
		ELSE
			rom_mux_output <= '0';
		END IF;
	end if;
	end process;

END SYN;