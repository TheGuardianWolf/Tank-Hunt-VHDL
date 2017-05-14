LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity input_live_test is
    port
    (
        r_sw0		    :	 in std_logic;
        r_button1		:	 in std_logic;
        r_button2		:	 in std_logic;
        clk 		:	 in std_logic;
        led_0		:	 out std_logic;
        led_1		:	 out std_logic;
        led_2		:	 out std_logic;
        led_3		:	 out std_logic;
        led_4		:	 out std_logic;
        seg_out     :   out std_logic_vector(31 downto 0);
        mouse_data : inout std_logic;
        mouse_clk : inout std_logic
    );
end entity;

architecture behavior of input_live_test is
    signal sig_x: std_logic_vector(9 downto 0);
    signal sig_btn: std_logic_vector(1 downto 0);
    signal sig_clk_div: std_logic_vector(0 downto 0);
    signal sig_seg_in: std_logic_vector(15 downto 0);

    component input
        port
        (
            sw0		    :	 in std_logic;
            button1		:	 in std_logic;
            button2		:	 in std_logic;
            clk_50M		:	 in std_logic;
            clk_25M		:	 in std_logic;
            m_btn_l		:	 out std_logic;
            m_btn_r		:	 out std_logic;
            switch		:	 out std_logic;
            btn_1		:	 out std_logic;
            btn_2		:	 out std_logic;
            m_x		    :	 out std_logic_vector(9 downto 0);
            m_data		:	 inout std_logic;
            m_clk		:	 inout std_logic
        );
    end component;
    component bin_2_seven_seg
        port (
            b : in	std_logic_vector (3 downto 0);
            s : out std_logic_vector (7 downto 0)
        );
    end component;
    component var_clk_div
        generic(
            size: integer
        );
        port(
            clk: in std_logic;
            clk_div: out std_logic_vector(size-1 downto 0)
        );
    end component;
begin
    sys: input port map (
			r_sw0,
			r_button1,
			r_button2,
			clk,
			sig_clk_div(0),
			led_3,
			led_4,
			led_0,
			sig_btn(0),
			sig_btn(1),
			sig_x,
			mouse_data,
			mouse_clk
    );
    div: var_clk_div 
    generic map(
        1
    )
    port map(
        clk, sig_clk_div
    );
    converter: for i in 0 to 3 generate
        converterx: bin_2_seven_seg port map(
            sig_seg_in(3+(i*4) downto 0+(i*4)),
            seg_out(7+(i*8) downto 0+(i*8))
        );
    end generate;
    sig_seg_in <= "000000" & sig_x;

    process(clk)
        variable toggle_led: std_logic_vector(1 downto 0) := (others => '0');
    begin
  --      if(rising_edge(clk)) then
            for i in 0 to 1 loop
                if(rising_edge(sig_btn(i))) then
                    toggle_led(i) := not toggle_led(i);
                end if;
            end loop;
 --       end if;

        led_1 <= toggle_led(0);
        led_2 <= toggle_led(1);
    end process;
end architecture;