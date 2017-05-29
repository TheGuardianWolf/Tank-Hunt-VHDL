library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_game_control_block is
end entity;

architecture test of test_game_control_block is
    component game_control_block is
        port(
            clk_50M: in std_logic;
            clk_s: in std_logic;
            btn1: in std_logic;
            switch: in std_logic;
            pregame: in std_logic;
            midgame: in std_logic;
            win: in std_logic;
            next_level: in std_logic;
            bullet_collision: in std_logic;
            game_won: out std_logic := '0';
            game_mode: out std_logic := '0';
            game_pause: out std_logic := '0';
            max_level: out std_logic := '0';
            timeout: out std_logic := '0';
            kills_reached: out std_logic := '0';
            game_time: out std_logic_vector(7 downto 0) := (others => '0');
            current_level: out std_logic_vector(1 downto 0) := (others => '0');
            current_kills: out std_logic_vector(7 downto 0) := (others => '0');
            total_kills: out std_logic_vector(7 downto 0) := (others => '0')
        );
    end component;

    signal t_clk_50M: std_logic := '0';
    signal t_clk_s: std_logic := '0';
    signal t_btn_1: std_logic := '0';
    signal t_switch: std_logic := '0';
    signal t_pregame: std_logic := '0';
    signal t_midgame: std_logic := '0';
    signal t_win: std_logic := '0';
    signal t_next_level: std_logic := '0';
    signal t_bullet_collision: std_logic := '0';
    signal t_game_time: std_logic_vector(7 downto 0) := (others => '0');
    signal t_current_kills: std_logic_vector(7 downto 0) := (others => '0');
    signal t_total_kills: std_logic_vector(7 downto 0) := (others => '0');
begin
    t_pregame <= '1', '0' after 100 ps;
    t_midgame <= '1' after 100 ps;
    t_bullet_collision <= '1' after 300 ps, '0' after 400 ps, '1' after 700 ps, '0' after 800 ps;

    -- clock generation
    process
    begin
        wait for 50 ps;
        t_clk_50M <= '1';
        wait for 50 ps;
        t_clk_50M <= '0';
    end process;

    -- clock generation
    process
    begin
        wait for 200 ps;
        t_clk_s <= '1';
        wait for 200 ps;
        t_clk_s <= '0';
    end process;

    g_control: game_control_block port map(
        t_clk_50M,
        t_clk_s,
        t_btn_1,
        t_switch,
        t_pregame,
        t_midgame,
        t_win,
        t_next_level,
        t_bullet_collision,
        open,
        open,
        open,
        open,
        open,
        open,
        t_game_time,
        open,
        t_current_kills,
        t_total_kills
    );
end architecture;