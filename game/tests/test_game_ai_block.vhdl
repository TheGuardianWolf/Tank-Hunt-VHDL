library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_game_ai_block is
end entity;

architecture test of test_game_ai_block is
    component game_ai_block is
        port(
            clk_50M: in std_logic;
            clk_move: in std_logic_vector(2 downto 0);
            clk_s: in std_logic;
            pregame: in std_logic;
            midgame: in std_logic;
            endgame: in std_logic;
            enable: in std_logic := '0';
            current_level: in std_logic_vector(1 downto 0) := (others => '0');
            next_level: in std_logic;
            lfsr_seed: in std_logic_vector(15 downto 0);
            bullet_x: in std_logic_vector(9 downto 0);
            bullet_y: in std_logic_vector(9 downto 0);
            player_x: in std_logic_vector(9 downto 0);
            player_y: in std_logic_vector(9 downto 0);
            enable_next: out std_logic := '0';
            ai_x: out std_logic_vector(9 downto 0) := (others => '0');
            ai_y: out std_logic_vector(9 downto 0) := (others => '0');
            ai_show: out std_logic := '0';
            bullet_collision: out std_logic := '0';
            player_collision: out std_logic := '0'
        );
    end component;

    component seeder is
        port(
            clk_50M: in std_logic;
            lfsr_seed: out std_logic_vector(15 downto 0)
        );
    end component;

    signal t_clk_50M: std_logic := '0';
    signal t_clk_move: std_logic_vector(2 downto 0) := (others => '0');
    signal t_clk_s: std_logic := '0';
    signal seed: std_logic_vector(15 downto 0) := (others => '0');
    signal t_next_level: std_logic := '0';
    signal t_collision: std_logic := '0';
    signal t_pregame: std_logic := '0';
    signal t_endgame: std_logic := '0';
    signal t_midgame: std_logic := '0';
    signal t_current_level: std_logic_vector(1 downto 0) := "00";
    signal t_delayed_enable: std_logic := '0';
begin
    t_next_level <= '0';
    t_collision <= '0';
    t_pregame <= '0';
    t_midgame <= '0', '1' after 3000 ps;
    t_current_level <= "00";

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
        wait for 100 ps;
        t_clk_move(2) <= '1';
        wait for 100 ps;
        t_clk_move(2) <= '0';
    end process;

     -- clock generation
    process
    begin
        wait for 125 ps;
        t_clk_move(1) <= '1';
        wait for 125 ps;
        t_clk_move(1) <= '0';
    end process;

     -- clock generation
    process
    begin
        wait for 150 ps;
        t_clk_move(0) <= '1';
        wait for 150 ps;
        t_clk_move(0) <= '0';
    end process;

    -- clock generation
    process
    begin
        wait for 200 ps;
        t_clk_s <= '1';
        wait for 200 ps;
        t_clk_s <= '0';
    end process;

    sd: seeder
    port map(
        t_clk_50M,
        seed
    );

    g_ai0: game_ai_block port map(
        t_clk_50M,
        t_clk_move,
        t_clk_s,
        t_pregame,
        t_midgame,
        t_endgame,
        t_midgame,
        t_current_level,
        t_next_level,
        seed,
        (others => '0'),
        (others => '1'),
        (others => '0'),
        (others => '1'),
        t_delayed_enable,
        open,
        open,
        open,
        open,
        open
    );

    g_ai1: game_ai_block port map(
        t_clk_50M,
        t_clk_move,
        t_clk_s,
        t_pregame,
        t_midgame,
        t_endgame,
        t_delayed_enable,
        t_current_level,
        t_next_level,
        seed,
        (others => '0'),
        (others => '1'),
        (others => '0'),
        (others => '1'),
        open,
        open,
        open,
        open,
        open,
        open
    );

end architecture;