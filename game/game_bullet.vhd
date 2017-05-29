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
        game_paused: in std_logic;
		  m_l : in std_logic;
		  player_x: in std_logic_vector (9 downto 0);
		  ai0_x: in std_logic_vector (9 downto 0);
		  ai0_y: in std_logic_vector (9 downto 0);
		  collide: out std_logic;
		  show_bullet: out std_logic;
		  x_out: out std_logic_vector (9 downto 0);
		  y_out: out std_logic_vector (9 downto 0)
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
	 
	 signal bullet_x, bullet_y : std_logic_vector(9 downto 0);
	 signal collide_temp : std_logic;
	 signal show : std_logic;
	 signal alive : std_logic;
	 signal y_pos_mux_out : std_logic_vector(9 downto 0) := "0110011000";
	 signal y_pos_mux_in : std_logic_vector(9 downto 0) := "0110011000";
	 signal comp_max_eq, max_collide, comp_tank_left_gt, comp_tank_left_eq, tank_left_collide, comp_tank_right_lt,
			  comp_tank_right_eq, tank_right_collide, comp_tank_bot_lt, comp_tank_bot_eq, tank_bot_collide,
			  comp_tank_top_gt, comp_tank_top_eq, tank_top_collide: std_logic;
begin
--process(clk_50M)
	--begin
	--if(rising_edge(clk_50M)) then
    -- Store bullet X position
    b_x: register_d generic map(
        10
    ) port map(
        clk_50M,
        '0',
        midgame,
        std_logic_vector(unsigned(player_x)+32),
        bullet_x
    );
	 
	-- Store bullet Y position
    b_y: register_d generic map(
        10
    ) port map(
        clk_48,
        '0',
        midgame,
        y_pos_mux_out,
        bullet_y
    );
	 
    b_m: register_d generic map(
        1
    ) port map(
        clk_50M,
        '0',
        m_l,
        D(0) => m_l,
        Q(0) => alive
    );
	 
--	 comp_max: comparator_u generic map(
--        10
--    ) port map(
--        bullet_y,
--        "0000100000",
--        open,
--        comp_max_eq,
--        open
--    );
--	 
--	 comp_top: comparator_u generic map(
--        10
--    ) port map(
--        bullet_y,
--        ai0_y,
--        open,
--        comp_tank_top_eq,
--        comp_tank_top_gt
--    );
--	 
--	 comp_bot: comparator_u generic map(
--        10
--    ) port map(
--        bullet_y,
--        std_logic_vector(unsigned(ai0_y)+64),
--        comp_tank_bot_lt,
--        comp_tank_bot_eq,
--        open
--    );
--	 
--	 comp_right: comparator_u generic map(
--        10
--    ) port map(
--        bullet_x,
--        std_logic_vector(unsigned(ai0_x)+64),
--        comp_tank_right_lt,
--        comp_tank_right_eq,
--        open
--    );
--	 
--	 comp_left: comparator_u generic map(
--        10
--    ) port map(
--        bullet_x,
--        ai0_x,
--        open,
--        comp_tank_left_eq,
--        comp_tank_left_gt
--    );
--	 
	 
	 y_pos_mux_in <= std_logic_vector((unsigned(bullet_y) - 2)) when (midgame = '1');
	--  else "0110011000" when others;
	 
	 
	 with show select y_pos_mux_out <=
		"0110011000" when '0',
		y_pos_mux_in when '1';
		
--	 max_collide <= comp_max_eq;
--	 tank_top_collide <= comp_tank_top_eq or comp_tank_top_gt;
--	 tank_bot_collide <= comp_tank_bot_eq or comp_tank_bot_lt;
--	 tank_left_collide <= comp_tank_left_eq or comp_tank_left_gt;
--	 tank_right_collide <= comp_tank_right_eq or comp_tank_right_lt;
--	 collide_temp <= max_collide or (tank_bot_collide and tank_top_collide and tank_left_collide and tank_right_collide);
	 
	 show <= '1' when ((midgame ='1' or game_paused = '1') and alive = '1') else 
				'0' when (collide_temp = '1');			 

--	 collide <= collide_temp;
	 show_bullet <= show;
	 y_out <= bullet_y;
	 x_out <= bullet_x;
	-- end if;
	-- end process;
end architecture;