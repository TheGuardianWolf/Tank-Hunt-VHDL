library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_game_ai_block is
end entity;

architecture test of test_game_ai_block is
    component game_ai_block is
        port(
            clk_50M: in std_logic;
            clk_48: in std_logic;
            clk_s: in std_logic;
            pregame: in std_logic;
            midgame: in std_logic;
            endgame: in std_logic;
            enable: in std_logic;
            current_level: in std_logic_vector(1 downto 0) := (others => '0');
            next_level: in std_logic;
            collision: in std_logic;
            lfsr_seed: in std_logic_vector(15 downto 0);
            enable_next: out std_logic := '0';
            ai_x: out std_logic_vector(9 downto 0) := (others => '0');
            ai_y: out std_logic_vector(9 downto 0) := (others => '0');
            ai_show: out std_logic := '0'
        );
    end component;

    component seeder is
        port(
            clk_50M: in std_logic;
            lfsr_seed: out std_logic_vector(15 downto 0)
        );
    end component;

    signal t_clk_50M: std_logic := '0';
    signal t_clk_40: std_logic := '0';
    signal t_clk_s: std_logic := '0';
    signal seed: std_logic_vector(15 downto 0) := (others => '0');
    signal t_enable: std_logic := '0';
    signal t_next_level: std_logic := '0';
    signal t_collision: std_logic := '0';
    signal t_pregame: std_logic := '0';
    signal t_endgame: std_logic := '0';
    signal t_midgame: std_logic := '0';
    signal t_current_level: std_logic_vector(1 downto 0) := "00";
begin
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
        t_clk_40 <= '1';
        wait for 100 ps;
        t_clk_40 <= '0';
    end process;

    -- clock generation
    process
    begin
        wait for 200 ps;
        t_clk_s <= '1';
        wait for 200 ps;
        t_clk_s <= '0';
    end process;

    process(t_clk)
        if (not started) then
            started <= '1';
        end if;
    end process;

    sd: seeder
    port map(
        clk_50M,
        seed
    );

    g_ai0: game_ai_block port map(

    );

    g_ai1: game_ai_block port map(

    );

end architecture;