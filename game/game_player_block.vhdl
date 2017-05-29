-- Player tank systems
-- Responds to game controller outputs

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity game_player_block is
    port(
        clk_50M: in std_logic;
        m_btn_l: in std_logic;
        m_btn_r: in std_logic;
        m_x: in std_logic_vector(9 downto 0);
        midgame: in std_logic;
        player_x: out std_logic_vector(9 downto 0) := (others => '0');
        player_y: out std_logic_vector(9 downto 0) := (others => '0');
        enemy_collision: out std_logic := '0'
    );
end entity;

architecture behavior of game_player_block is
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
begin
    -- Store player X position
    p_x: register_d generic map(
        10
    ) port map(
        clk_50M,
        '0',
        midgame,
        m_x,
        player_x
    );

    player_y <= "0110101111";

    -- -- Bullet X position
    -- b_x: register_d generic map(
    --     10
    -- ) port map(
    --     clk_50M,
    --     '0',
    --     open,
    --     open,
    --     open
    -- );

    -- -- Bullet Y position
    -- b_y: register_d generic map(
    --     10
    -- ) port map(
    --     clk_50M,
    --     '0',
    --     open,
    --     open,
    --     open
    -- );
end architecture;