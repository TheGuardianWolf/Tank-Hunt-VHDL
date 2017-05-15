-- AI tank systems
-- Responds to game controller outputs

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity game_ai_block is
    port(
        clk_50M: in std_logic;
        clk_48: in std_logic;
        clk_s: in std_logic;
        pregame: in std_logic;
        midgame: in std_logic;
        endgame: in std_logic;
        next_level: in std_logic;
        collision: in std_logic;
        ai_x: out std_logic_vector(9 downto 0) := (others => '0');
        ai_y: out std_logic_vector(9 downto 0) := (others => '0');
        ai_hidden: out std_logic
    );
end entity;

architecture behavior of game_ai_block is
    component T_FF is
        port (
            T: in std_logic;
            Reset: in std_logic;
            Q: out std_logic;
            NQ: out std_logic
        );
    end component;

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

    component counter is
        generic(
            size: integer := 1
        );
        port (
            Clk: in std_logic;
            Reset: in std_logic;
            Enable: in std_logic;
            Limit: in std_logic_vector(size-1 downto 0) := (others => '1');
            C: out std_logic_vector(size-1 downto 0) := (others => '0')
        );
    end component;

    signal destroyed: std_logic := '0';
    signal reset_ai: std_logic := '0';
    signal reset_spawn: std_logic := '0';

    signal mux_ai_x_sel: std_logic := '1';
    signal mux_ai_x_a: std_logic_vector(9 downto 0) := (others => '0');
    signal mux_ai_x_b: std_logic_vector(9 downto 0) := (others => '0');
    signal mux_ai_x_r: std_logic_vector(9 downto 0) := (others => '0');

    signal sig_ai_x: std_logic_vector(9 downto 0) := (others => '0');
    signal is_ai_x_max: std_logic := '0';
    signal is_ai_x_min: std_logic := '0';

    signal sig_ai_y: std_logic_vector(9 downto 0) := (others => '0');

    signal spawn_timer: std_logic_vector(1 downto 0) := (others => '0');
    signal spawned: std_logic := '0';
begin
    -- Signal to reset ai
    reset_ai <= (pregame) or (next_level) or (not spawned);
    -- Signal to reset the spawn counter
    reset_spawn <= (pregame) or (next_level) or (collision);

    -- AI x position
    reg_ai_x: register_d generic map(
        10
    )
    port map(
        clk_48,
        '0',
        pregame or midgame,
        mux_ai_x_r,
        sig_ai_x
    );

    -- Use either an adder or subtractor based on the direction the AI tank is going
    -- to calculate next x position
    mux_ai_x_b <= std_logic_vector(unsigned(sig_ai_x) + 1) when mux_ai_x_sel='1' else
                    std_logic_vector(unsigned(sig_ai_x) - 1);
    mux_ai_x_r <= mux_ai_x_b when reset_ai='1' else
                    mux_ai_x_a;
    
    -- Comparator to signal when ai reaches max X position
    comp_ai_x_max: comparator_u generic map(
        10
    )
    port map(
        sig_ai_x,
        "1000111111", --639-64
        open,
        is_ai_x_max,
        open
    );

    -- Comparator to signal when ai reaches min X position
    comp_ai_x_min: comparator_u generic map(
        10
    )
    port map(
        sig_ai_x,
        (others => '0'),
        open,
        is_ai_x_min,
        open
    );

    -- Toggles directions when max or min signals for x are asserted
    ai_x_dir: T_FF port map(
        is_ai_x_max or is_ai_x_min,
        '0',
        mux_ai_x_sel,
        open
    );

    -- Stores AI Y position
    reg_ai_y: register_d generic map(
        10
    )
    port map(
        clk_48,
        reset_ai,
        is_ai_x_max or is_ai_x_min,
        std_logic_vector(unsigned(sig_ai_y) + 48),
        sig_ai_y
    );

    ai_x <= sig_ai_x;
    ai_y <= sig_ai_y;

    -- destroyed: register_d generic map(
    --     1
    -- )
    -- port map(
    --     clk_50M,
    --     '0',

    -- ); 

    -- Counter to track AI tank spawn time
    spawn: counter generic map(
        2
    )
    port map(
        clk_s,
        reset_spawn,
        reset_ai,
        (others => '1'),
        spawn_timer
    );
    
    -- Comparator to signal when spawn counter is finished
    comp_spawned: comparator_u generic map(
        2
    )
    port map(
        spawn_timer,
        (others => '1'),
        open,
        spawned,
        open
    );

    -- Clocked signal for hiding the ai tank (i.e. during spawn)
    ai_h: register_d generic map(
        1
    ) port map(
        clk_50M,
        '0',
        '1',
        D(0) => reset_ai,
        Q(0) => ai_hidden
    );
end architecture;