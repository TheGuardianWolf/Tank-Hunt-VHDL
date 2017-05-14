library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_game_controller is
end entity test_game_controller;

architecture test of test_game_controller is
    signal t_clk: std_logic := '0'

    component game_controller is
        port(
            clk_50M: in std_logic := '0';

            ready: in std_logic := '0';
            game_start: in std_logic := '0';
            game_mode: in std_logic := '0';
            game_reset: in std_logic := '0';
            game_pause: in std_logic := '0';
            timeout: in std_logic := '0';
            max_level: in std_logic := '0';
            kills_reached: in std_logic := '0';

            pregame: out std_logic := '0';
            midgame: out std_logic := '0';
            endgame: out std_logic := '0';
            mouse_pos_reset: out std_logic := '0';
            win: out std_logic := '0';
            next_level: out std_logic := '0';
            state_debug: out std_logic_vector(2 downto 0) := (others => '0')
        );
    end component;

    signal t_game_start: std_logic := '0';
    signal t_game_mode: std_logic := '0';
    signal t_game_reset: std_logic := '0';
    signal t_timeout: std_logic := '0';
    signal t_max_level: std_logic := '0';
    signal t_kills_reached: std_logic := '0';
begin
    fsm: game_controller 
    port map(
        t_clk,
        '1',
        t_game_start,
        t_game_mode,
        t_game_reset,
        t_game_pause,
        t_timeout,
        t_max_level,
        kills_reached,
        pregame: out std_logic := '0';
        midgame: out std_logic := '0';
        endgame: out std_logic := '0';
        mouse_pos_reset: out std_logic := '0';
        win: out std_logic := '0';
        next_level: out std_logic := '0';
        state_debug: out std_logic_vector(2 downto 0) := (others => '0')
    );

    -- clock generation
    process
    begin
        wait for 50 ps;
        t_clk <= '1';
        wait for 50 ps;
        t_clk <= '0';
    end process;
end architecture;