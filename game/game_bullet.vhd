--bullet shot from tank, responds to player tank 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity game_bullet is
    port(
        clk_50M: in std_logic;
        clk_48: in std_logic;
        clk_s: in std_logic;
        midgame: in std_logic;
        bullet_collision: in std_logic;
        m_l : in std_logic;
        player_x: in std_logic_vector(9 downto 0);
        show_bullet: out std_logic;
        x_out: out std_logic_vector(9 downto 0);
        y_out: out std_logic_vector(9 downto 0)
    );
end entity;

architecture behavior of game_bullet is
    component register_d is
        generic(
            size: integer := 1
        );
        port (
            Clk: in std_logic;
            Reset: in std_logic;
            Enable: in std_logic;
            D: in std_logic_vector(size-1 downto 0);
            Q: out std_logic_vector(size-1 downto 0) := (others => '0')
        );
    end component;

    component comparator_u is
        generic(
            size: integer := 1
        );
        port (
            a: in std_logic_vector(size-1 downto 0);
            b: in std_logic_vector(size-1 downto 0);
            lt: out std_logic := '0';
            eq: out std_logic := '0';
            gt: out std_logic := '0'
        );
    end component;
	 
	 signal bullet_x, bullet_y : std_logic_vector(9 downto 0) := (others => '0');

     signal bullet_fired: std_logic := '0';
     signal bullet_show: std_logic := '0';
     signal bullet_limit: std_logic := '0';
     signal reset_bullet: std_logic := '0';

     signal mux_b_x, mux_b_y: std_logic_vector(9 downto 0) := (others => '0');
begin
    b_x: register_d generic map(
        10
    ) port map(
        clk_50M,
        '0',
        midgame,
        mux_b_x,
        bullet_x
    );

    with bullet_fired select mux_b_x <= 
        std_logic_vector(unsigned(player_x) + 32) when '0',
        bullet_x when others;
	 
	-- Store bullet Y position
    b_y: register_d generic map(
        10
    ) port map(
        clk_48,
        '0',
        midgame,
        mux_b_y,
        bullet_y
    );

    mux_b_y <= std_logic_vector(to_unsigned(419, 10)) when (bullet_fired='0') else
                std_logic_vector(unsigned(bullet_y) - 1);

    b_limit: comparator_u generic map(
        10
    ) port map(
        bullet_y,
        std_logic_vector(to_unsigned(32, 10)),
        open,
        bullet_limit,
        open
    );

    bullet_fired <= '1' when ((m_l = '1') or (bullet_show = '1')) else
                    '0'; 

    reset_bullet <= bullet_collision or bullet_limit;
    b_show: register_d generic map(
        1
    ) port map(
        clk_50M,
        reset_bullet,
        midgame,
        D(0) => bullet_fired,
        Q(0) => bullet_show
    );

	 y_out <= bullet_y;
	 x_out <= bullet_x;
     show_bullet <= bullet_show;
end architecture;