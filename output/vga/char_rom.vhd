

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
		pregame				: 	IN STD_LOGIC ;
		midgame				: 	IN STD_LOGIC ;
		endgame				: 	IN STD_LOGIC ;
		game_mode				: 	IN STD_LOGIC ;
		mouse_hor : IN STD_LOGIC_VECTOR (9 downto 0); -- horizontal position of the mouse
		ai_hor    : IN STD_LOGIC_VECTOR (9 downto 0);
		ai_show : IN STD_LOGIC;
		time_in   : IN STD_LOGIC_VECTOR (7 downto 0);
		game_pause : IN STD_LOGIC;
		current_kills : IN STD_LOGIC_VECTOR (7 downto 0);
		total_kills : IN STD_LOGIC_VECTOR (7 downto 0);
		current_level : IN STD_LOGIC_VECTOR (1 downto 0);
		ai_vert   : IN STD_LOGIC_VECTOR (9 downto 0);
		bullet_x  :  IN STD_LOGIC_VECTOR (9 downto 0);
		bullet_y  :  IN STD_LOGIC_VECTOR (9 downto 0);
		bullet_show : IN STD_LOGIC;
		ai1_hor	: IN STD_LOGIC_VECTOR (9 downto 0);
		ai1_vert : IN STD_LOGIC_VECTOR (9 downto 0);
		ai1_show : IN STD_LOGIC;
		rom_mux_output_red		:	OUT STD_LOGIC;--bit value for the current pixel red
		rom_mux_output_green		:	OUT STD_LOGIC;--bit value for the current pixel green
		rom_mux_output_blue		:	OUT STD_LOGIC--bit value for the current pixel blue
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
	--rom_mux_output_red	<= sub_wire0(7 DOWNTO 0);

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
	rom_mux_output_red <= '0';
	rom_mux_output_green <= '0';
	rom_mux_output_blue <= '0';
	IF(midgame = '1' or (game_pause = '1' and endgame = '0' and pregame = '0')) THEN
			--tank display, with mouse x position as input for reference
			IF (("0110011" <= vga_row(9 downto 3)) and (vga_row(9 downto 3) <= "0111011")) THEN
				IF ((mouse_hor(9 downto 3) < vga_col(9 downto 3)) and (vga_col(9 downto 3) <= std_logic_vector(unsigned(mouse_hor(9 downto 3))+ 8))) THEN
					--concatenate character address and font row address into a 9 bit address
					rom_address <= "111101" & std_logic_vector(unsigned(vga_row(5 downto 3))-3);
					--select of the mux for which column in the row the pixel data is chosen from
					rom_mux_output_blue <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(5 DOWNTO 3))-(unsigned(mouse_hor(5 downto 3))+1)))));
				END IF;	
				
			ELSIF ((std_logic_vector(unsigned(bullet_y(9 downto 0))-0) <= vga_row(9 downto 0)) and (vga_row(9 downto 0) <= (std_logic_vector(unsigned(bullet_y(9 downto 0))+7)))) AND
				 ((std_logic_vector(unsigned(bullet_x(9 downto 0))-4) <= vga_col(9 downto 0)) and (vga_col(9 downto 0) <= std_logic_vector(unsigned(bullet_x(9 downto 0))+4))) THEN
					--concatenate character address and font row address into a 9 bit address
					rom_address <= "111101" & std_logic_vector(unsigned(vga_row(2 downto 0))-(unsigned(bullet_y(2 downto 0))+ 0));
					--select of the mux for which column in the row the pixel data is chosen from
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(2 DOWNTO 0))-(unsigned(bullet_x(2 downto 0))-3)))));
					rom_mux_output_green <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(2 DOWNTO 0))-(unsigned(bullet_x(2 downto 0))-3)))));
					rom_mux_output_blue <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(2 DOWNTO 0))-(unsigned(bullet_x(2 downto 0))-3)))));
					
			--ai tank display
			ELSIF (((std_logic_vector(unsigned(ai_vert(9 downto 0))) <= vga_row(9 downto 0)) and (vga_row(9 downto 0) <= (std_logic_vector(unsigned(ai_vert(9 downto 0))+ 64)))) and ai_show = '1') and
				 ((ai_hor(9 downto 3) < vga_col(9 downto 3)) and (vga_col(9 downto 3) <= std_logic_vector(unsigned(ai_hor(9 downto 3))+ 8))) THEN
					--concatenate character address and font row address into a 9 bit address
					rom_address <= "111110" & std_logic_vector(unsigned(vga_row(5 downto 3))-(unsigned(ai_vert(5 downto 3))+1));
					--select of the mux for which column in the row the pixel data is chosen from
					rom_mux_output_green <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(5 DOWNTO 3))-(unsigned(ai_hor(5 downto 3))+1)))));
				
				
			--ai1 tank display
			ELSIF (((std_logic_vector(unsigned(ai1_vert(9 downto 0))+ 0) <= vga_row(9 downto 0)) and (vga_row(9 downto 0) <= (std_logic_vector(unsigned(ai1_vert(9 downto 0))+ 64)))) and (ai1_show = '1')) THEN
				IF ((ai1_hor(9 downto 3) < vga_col(9 downto 3)) and (vga_col(9 downto 3) <= std_logic_vector(unsigned(ai1_hor(9 downto 3))+ 8))) THEN
					--concatenate character address and font row address into a 9 bit address
					rom_address <= "111110" & std_logic_vector(unsigned(vga_row(5 downto 3))-(unsigned(ai1_vert(5 downto 3))+1));
					--select of the mux for which column in the row the pixel data is chosen from
					rom_mux_output_green <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(5 DOWNTO 3))-(unsigned(ai1_hor(5 downto 3))+0)))));
				END IF;	
				
			ELSIF (("00000000" < vga_row(9 downto 2)) and (vga_row(9 downto 2) <= "00001000")) THEN
				--score:x/y
				IF (("00000000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "00001000")) THEN
					rom_address <= "010011" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("00001000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "00010000")) THEN
					rom_address <= "000011" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("00010000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "00011000")) THEN
					rom_address <= "001111" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("00011000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "00100000")) THEN
					rom_address <= "010010" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("00100000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "00101000")) THEN
					rom_address <= "000101" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
					
				ELSIF (("00101000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "00110000")) THEN
					rom_address <= "101110" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));

				-- time: xy
				ELSIF (("01101000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01110000")) THEN
					rom_address <= "010100" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("01110000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01111000")) THEN
					rom_address <= "001001" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("01111000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "10000000")) THEN
					rom_address <= "001101" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("10000000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "10001000")) THEN
					rom_address <= "000101" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
					
				ELSIF (("10001000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "10010000")) THEN
					rom_address <= "101110" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
					
				ELSIF (("10010000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "10011000")) THEN
					IF (game_mode = '0') THEN
						rom_address <= std_logic_vector(48 + ((90-unsigned(time_in(5 downto 0)))/10)) & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					ELSE
						rom_address <= std_logic_vector(48 + ((60-unsigned(time_in(5 downto 0)))/10)) & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					END IF;
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("10011000" < vga_col(9 downto 2)) and (vga_col(9 downto 0) <= "1001111110")) THEN
					IF(game_mode = '0') THEN
						rom_address <= std_logic_vector(48 +((90-unsigned(time_in(5 downto 0))) rem 10)) & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					ELSE
						rom_address <= std_logic_vector(48 +((60-unsigned(time_in(5 downto 0))) rem 10)) & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					END IF;
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				
				ELSIF (game_mode = '0') THEN
					IF (("00110000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "00111000")) THEN
						rom_address <= std_logic_vector(48 + (unsigned(current_kills(5 downto 0))/10)) & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
						rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
					ELSIF (("00111000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01000000")) THEN
						rom_address <= std_logic_vector(48 + (unsigned(current_kills(5 downto 0)) rem 10)) & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
						rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
					END IF;
					
				ELSIF (game_mode = '1') THEN
					IF (("00110000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "00111000")) THEN
						rom_address <= std_logic_vector(48 + (unsigned(current_kills(5 downto 0))/10)) & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
						rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
					ELSIF (("00111000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01000000")) THEN
						rom_address <= std_logic_vector(48 + (unsigned(current_kills(5 downto 0)) rem 10)) & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
						rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
					ELSIF (("01000000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01001000")) THEN
						rom_address <= "101111" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
						rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
					ELSIF (("01001000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01010000")) THEN
						rom_address <= std_logic_vector(48 + (unsigned(total_kills(5 downto 0))/10)) & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
						rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
					ELSIF (("01010000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01011000")) THEN
						rom_address <= std_logic_vector(48 + (unsigned(total_kills(5 downto 0)) rem 10)) & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
						rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
					END IF;
				END IF;
			END IF;
			
		--below code displays "TANK GAME"
		ELSIF (pregame = '1') THEN
			IF (("0001000" < vga_row(9 downto 3)) and (vga_row(9 downto 3) <= "0010000")) THEN
				--T
				IF(("0000100" < vga_col(9 downto 3)) and (vga_col(9 downto 3) <= "0001100")) THEN 
					rom_address <= "010100" & std_logic_vector(unsigned(vga_row(5 downto 3))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(5 DOWNTO 3))-5))));
				ELSIF(("0001100" < vga_col(9 downto 3)) and (vga_col(9 downto 3) <= "0010100")) THEN
				--A
					rom_address <= "000001" & std_logic_vector(unsigned(vga_row(5 downto 3))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(5 DOWNTO 3))-5))));
				ELSIF(("0010100" < vga_col(9 downto 3)) and (vga_col(9 downto 3) <= "0011100")) THEN
				--N
					rom_address <= "001110" & std_logic_vector(unsigned(vga_row(5 downto 3))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(5 DOWNTO 3))-5))));
				ELSIF(("0011100" < vga_col(9 downto 3)) and (vga_col(9 downto 3) <= "0100100")) THEN
				--K
					rom_address <= "001011" & std_logic_vector(unsigned(vga_row(5 downto 3))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(5 DOWNTO 3))-5))));
					
				--G
				ELSIF(("0101100" < vga_col(9 downto 3)) and (vga_col(9 downto 3) <= "0110100")) THEN 
					rom_address <= "000111" & std_logic_vector(unsigned(vga_row(5 downto 3))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(5 DOWNTO 3))-5))));
				--A
				ELSIF(("0110100" < vga_col(9 downto 3)) and (vga_col(9 downto 3) <= "0111100")) THEN
					rom_address <= "000001" & std_logic_vector(unsigned(vga_row(5 downto 3))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(5 DOWNTO 3))-5))));
				--M
				ELSIF(("0111100" < vga_col(9 downto 3)) and (vga_col(9 downto 3) <= "1000100")) THEN
					rom_address <= "001101" & std_logic_vector(unsigned(vga_row(5 downto 3))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(5 DOWNTO 3))-5))));
				--E
				ELSIF(("1000100" < vga_col(9 downto 3)) and (vga_col(9 downto 3) <= "1001100")) THEN
					rom_address <= "000101" & std_logic_vector(unsigned(vga_row(5 downto 3))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(5 DOWNTO 3))-5))));
				END IF;
			--start - btn0
			ELSIF (("00101000" < vga_row(9 downto 2)) and (vga_row(9 downto 2) <= "00110000")) THEN
				IF (("00100000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "00101000")) THEN
					rom_address <= "010011" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("00101000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "00110000")) THEN
					rom_address <= "010100" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("00110000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "00111000")) THEN
					rom_address <= "000001" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("00111000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01000000")) THEN
					rom_address <= "010010" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("01000000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01001000")) THEN
					rom_address <= "010100" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
					
				ELSIF (("01010000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01011000")) THEN
					rom_address <= "101101" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));

				ELSIF (("01100000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01101000")) THEN
					rom_address <= "000010" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("01101000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01110000")) THEN
					rom_address <= "010100" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("01110000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01111000")) THEN
					rom_address <= "001110" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("01111000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "10000000")) THEN
					rom_address <= "110000" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				END IF;
			--practice - sw0 dwn	
			ELSIF (("01000000" < vga_row(9 downto 2)) and (vga_row(9 downto 2) <= "01001000")) THEN
				IF (("00001000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "00010000")) THEN
					rom_address <= "010000" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("00010000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "00011000")) THEN
					rom_address <= "010010" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("00011000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "00100000")) THEN
					rom_address <= "000001" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("00100000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "00101000")) THEN
					rom_address <= "000011" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("00101000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "00110000")) THEN
					rom_address <= "010100" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("00110000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "00111000")) THEN
					rom_address <= "001001" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("00111000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01000000")) THEN
					rom_address <= "000011" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("01000000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01001000")) THEN
					rom_address <= "000101" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));

					
				ELSIF (("01010000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01011000")) THEN
					rom_address <= "101101" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
					
				ELSIF (("01100000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01101000")) THEN
					rom_address <= "010011" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("01101000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01110000")) THEN
					rom_address <= "010111" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("01110000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01111000")) THEN
					rom_address <= "110000" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
					
				ELSIF (("01111100" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "10000100")) THEN
					rom_address <= "000100" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-5))));
				ELSIF (("10000100" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "10001100")) THEN
					rom_address <= "001111" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-5))));
				ELSIF (("10001100" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "10010100")) THEN
					rom_address <= "010111" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-5))));
				ELSIF (("10010100" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "10011100")) THEN
					rom_address <= "001110" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-5))));
				END IF;
				
			--hunt - sw0 up	
			ELSIF (("00110100" < vga_row(9 downto 2)) and (vga_row(9 downto 2) <= "00111100")) THEN
				IF (("00101000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "00110000")) THEN
					rom_address <= "001000" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("00110000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "00111000")) THEN
					rom_address <= "010101" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("00111000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01000000")) THEN
					rom_address <= "001110" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("01000000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01001000")) THEN
					rom_address <= "010100" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));

					
				ELSIF (("01010000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01011000")) THEN
					rom_address <= "101101" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
					
				ELSIF (("01100000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01101000")) THEN
					rom_address <= "010011" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("01101000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01110000")) THEN
					rom_address <= "010111" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("01110000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01111000")) THEN
					rom_address <= "110000" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
					
				ELSIF (("01111100" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "10000100")) THEN
					rom_address <= "010101" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-5))));
				ELSIF (("10000100" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "10001100")) THEN
					rom_address <= "010000" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-5))));
				END IF;
				
			-- pause - btn1
			ELSIF (("01001100" < vga_row(9 downto 2)) and (vga_row(9 downto 2) <= "01010100")) THEN
				IF (("00100000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "00101000")) THEN
					rom_address <= "010000" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("00101000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "00110000")) THEN
					rom_address <= "000001" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("00110000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "00111000")) THEN
					rom_address <= "010101" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("00111000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01000000")) THEN
					rom_address <= "010011" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("01000000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01001000")) THEN
					rom_address <= "000101" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));

					
				ELSIF (("01010000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01011000")) THEN
					rom_address <= "101101" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
					
				ELSIF (("01100000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01101000")) THEN
					rom_address <= "000010" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("01101000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01110000")) THEN
					rom_address <= "010100" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("01110000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01111000")) THEN
					rom_address <= "001110" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("01111000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "10000000")) THEN
					rom_address <= "110001" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				END IF;
				
			-- reset - btn2
			ELSIF (("01011000" < vga_row(9 downto 2)) and (vga_row(9 downto 2) <= "01100000")) THEN
				IF (("00100000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "00101000")) THEN
					rom_address <= "010010" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("00101000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "00110000")) THEN
					rom_address <= "000101" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("00110000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "00111000")) THEN
					rom_address <= "010011" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("00111000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01000000")) THEN
					rom_address <= "000101" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("01000000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01001000")) THEN
					rom_address <= "010100" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));

					
				ELSIF (("01010000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01011000")) THEN
					rom_address <= "101101" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
					
				ELSIF (("01100000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01101000")) THEN
					rom_address <= "000010" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("01101000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01110000")) THEN
					rom_address <= "010100" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("01110000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01111000")) THEN
					rom_address <= "001110" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("01111000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "10000000")) THEN
					rom_address <= "110010" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				END IF;
			--mode now - practice/hunt
			ELSIF (("01100100" < vga_row(9 downto 2)) and (vga_row(9 downto 2) <= "01101100")) THEN
				IF (("00001000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "00010000")) THEN
					rom_address <= "001101" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("00010000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "00011000")) THEN
					rom_address <= "001111" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("00011000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "00100000")) THEN
					rom_address <= "000100" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("00100000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "00101000")) THEN
					rom_address <= "000101" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));

					
				ELSIF (("00110000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "00111000")) THEN
					rom_address <= "001110" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("00111000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01000000")) THEN
					rom_address <= "001111" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("01000000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01001000")) THEN
					rom_address <= "010111" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));

					
				ELSIF (("01010000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01011000")) THEN
					rom_address <= "101101" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				END IF;
				
			IF (game_mode = '0') THEN	
				IF (("01100000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01101000")) THEN
					rom_address <= "010000" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("01101000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01110000")) THEN
					rom_address <= "010010" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("01110000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01111000")) THEN
					rom_address <= "000001" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("01111000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "10000000")) THEN
					rom_address <= "000011" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("10000000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "10001000")) THEN
					rom_address <= "010100" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("10001000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "10010000")) THEN
					rom_address <= "001001" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("10010000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "10011000")) THEN
					rom_address <= "000011" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("10011000" < vga_col(9 downto 2)) and (vga_col(9 downto 0) <= "1001111100")) THEN
					rom_address <= "000101" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				END IF;
			ELSE
				IF (("01100000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01101000")) THEN
					rom_address <= "001000" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("01101000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01110000")) THEN
					rom_address <= "010101" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("01110000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01111000")) THEN
					rom_address <= "001110" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("01111000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "10000000")) THEN
					rom_address <= "010100" & std_logic_vector(unsigned(vga_row(4 downto 2))-5);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				END IF;	
			END IF;		
		END IF;
	ELSIF (endgame = '1') THEN
		IF (("0001100" < vga_row(9 downto 3)) and (vga_row(9 downto 3) <= "0010100")) THEN
			IF(("0001100" < vga_col(9 downto 3)) and (vga_col(9 downto 3) <= "0010100")) THEN 
				rom_address <= "010111" & std_logic_vector(unsigned(vga_row(5 downto 3))-5);
				rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(5 DOWNTO 3))-5))));
			ELSIF(("0010100" < vga_col(9 downto 3)) and (vga_col(9 downto 3) <= "0011100")) THEN 
				rom_address <= "001001" & std_logic_vector(unsigned(vga_row(5 downto 3))-5);
				rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(5 DOWNTO 3))-5))));
			ELSIF(("0011100" < vga_col(9 downto 3)) and (vga_col(9 downto 3) <= "0100100")) THEN 
				rom_address <= "001110" & std_logic_vector(unsigned(vga_row(5 downto 3))-5);
				rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(5 DOWNTO 3))-5))));
			ELSIF(("0100100" < vga_col(9 downto 3)) and (vga_col(9 downto 3) <= "0101100")) THEN 
				rom_address <= "001110" & std_logic_vector(unsigned(vga_row(5 downto 3))-5);
				rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(5 DOWNTO 3))-5))));
			ELSIF(("0101100" < vga_col(9 downto 3)) and (vga_col(9 downto 3) <= "0110100")) THEN 
				rom_address <= "000101" & std_logic_vector(unsigned(vga_row(5 downto 3))-5);
				rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(5 DOWNTO 3))-5))));
			ELSIF(("0110100" < vga_col(9 downto 3)) and (vga_col(9 downto 3) <= "0111100")) THEN 
				rom_address <= "010010" & std_logic_vector(unsigned(vga_row(5 downto 3))-5);
				rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(5 DOWNTO 3))-5))));
			ELSIF(("0111100" < vga_col(9 downto 3)) and (vga_col(9 downto 3) <= "1000100")) THEN 
				rom_address <= "100001" & std_logic_vector(unsigned(vga_row(5 downto 3))-5);
				rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(5 DOWNTO 3))-5))));
			END IF;
			
		--Score:total score		
		ELSIF (("01000000" < vga_row(9 downto 2)) and (vga_row(9 downto 2) <= "01001000")) THEN
				IF (("00100000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "00101000")) THEN
					rom_address <= "010011" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("00101000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "00110000")) THEN
					rom_address <= "000011" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("00110000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "00111000")) THEN
					rom_address <= "001111" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("00111000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01000000")) THEN
					rom_address <= "010010" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("01000000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01001000")) THEN
					rom_address <= "000101" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));

					
				ELSIF (("01010000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01011000")) THEN
					rom_address <= "101101" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
					
				ELSIF (("01100000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01101000")) THEN
					rom_address <= "000001" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("01101000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01110000")) THEN
					rom_address <= "000001" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("01110000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01111000")) THEN
					rom_address <= "000001" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				END IF;	
			-- reset - btn2
		ELSIF (("01011000" < vga_row(9 downto 2)) and (vga_row(9 downto 2) <= "01100000")) THEN
				IF (("00100000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "00101000")) THEN
					rom_address <= "010010" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("00101000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "00110000")) THEN
					rom_address <= "000101" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("00110000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "00111000")) THEN
					rom_address <= "010011" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("00111000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01000000")) THEN
					rom_address <= "000101" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("01000000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01001000")) THEN
					rom_address <= "010100" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));

					
				ELSIF (("01010000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01011000")) THEN
					rom_address <= "101101" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
					
				ELSIF (("01100000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01101000")) THEN
					rom_address <= "000010" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("01101000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01110000")) THEN
					rom_address <= "010100" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("01110000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "01111000")) THEN
					rom_address <= "001110" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				ELSIF (("01111000" < vga_col(9 downto 2)) and (vga_col(9 downto 2) <= "10000000")) THEN
					rom_address <= "110010" & std_logic_vector(unsigned(vga_row(4 downto 2))-1);
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(4 DOWNTO 2))-1))));
				END IF;				
		END IF;
	IF (midgame = '1') THEN
--		IF (((std_logic_vector(unsigned(ai_vert(9 downto 0))) <= vga_row(9 downto 0)) and (vga_row(9 downto 0) <= (std_logic_vector(unsigned(ai_vert(9 downto 0))+ 64)))) and ai_show = '1') and
--				 ((ai_hor(9 downto 3) < vga_col(9 downto 3)) and (vga_col(9 downto 3) <= std_logic_vector(unsigned(ai_hor(9 downto 3))+ 8))) THEN
--					--concatenate character address and font row address into a 9 bit address
--					rom_address <= "111110" & std_logic_vector(unsigned(vga_row(5 downto 3))-(unsigned(ai_vert(5 downto 3))+1));
--					--select of the mux for which column in the row the pixel data is chosen from
--					rom_mux_output_green <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(5 DOWNTO 3))-(unsigned(ai_hor(5 downto 3))+1)))));
--			END IF;

		
			--bullet display
			IF ((std_logic_vector(unsigned(bullet_y(9 downto 0))-0) <= vga_row(9 downto 0)) and (vga_row(9 downto 0) <= (std_logic_vector(unsigned(bullet_y(9 downto 0))+7)))) AND
				 ((std_logic_vector(unsigned(bullet_x(9 downto 0))-4) <= vga_col(9 downto 0)) and (vga_col(9 downto 0) <= std_logic_vector(unsigned(bullet_x(9 downto 0))+4))) THEN
					--concatenate character address and font row address into a 9 bit address
					rom_address <= "111101" & std_logic_vector(unsigned(vga_row(2 downto 0))-(unsigned(bullet_y(2 downto 0))+ 0));
					--select of the mux for which column in the row the pixel data is chosen from
					rom_mux_output_red <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(2 DOWNTO 0))-(unsigned(bullet_x(2 downto 0))-3)))));
					rom_mux_output_green <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(2 DOWNTO 0))-(unsigned(bullet_x(2 downto 0))-3)))));
					rom_mux_output_blue <= rom_data (to_integer(unsigned(NOT std_logic_vector(unsigned(vga_col(2 DOWNTO 0))-(unsigned(bullet_x(2 downto 0))-3)))));
			END IF;
		END IF;
	END IF;
	END IF;
	end process;

END SYN;