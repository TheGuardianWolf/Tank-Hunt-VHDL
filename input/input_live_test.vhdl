entity input_test is
    port
    (
        sw0		:	 in std_logic;
        button1		:	 in std_logic;
        button0		:	 in std_logic;
        clk 		:	 in std_logic;
        led_0		:	 out std_logic;
        led_1		:	 out std_logic;
        led_2		:	 out std_logic;
        led_3		:	 out std_logic;
        led_4		:	 out std_logic
    );
end entity;

architecture behavior of input_test is
    component input
        port
        (
            sw0		:	 in std_logic;
            button1		:	 in std_logic;
            button0		:	 in std_logic;
            clk_50M		:	 in std_logic;
            clk_25M		:	 in std_logic;
            m_left		:	 out std_logic;
            m_right		:	 out std_logic;
            switch		:	 out std_logic;
            btn_1		:	 out std_logic;
            btn_2		:	 out std_logic;
            m_y		:	 out std_logic_vector(9 downto 0);
            m_x		:	 out std_logic_vector(9 downto 0);
            m_data		:	 inout std_logic;
            m_clk		:	 inout std_logic
        );
    end component;
    component bin_2_seven_seg
        port (
            b : in	STD_LOGIC_VECTOR (3 downto 0);
            s : out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component;
    component var_clk_div
        generic(
            size: integer
        );
        port(
            clk: in std_logic;
            clk_div: out std_logic_vector(size downto 0)
        );
    end component;
begin
end architecture;