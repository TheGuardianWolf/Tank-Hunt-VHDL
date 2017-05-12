library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity game_ai_block is
    port(
        clk_50M: in std_logic;
        clk_48: in std_logic;
        pregame: in std_logic;
        midgame: in std_logic;
        endgame: in std_logic;
        next_level: in std_logic;
        collision: in std_logic;
        ai_x: out std_logic_vector(9 downto 0) := (others => '0');
        ai_y: out std_logic_vector(9 downto 0) := (others => '0');
        ai_hidden: out std_logic;
    );
end entity;

architecture behavior of game_ai_block is
    component T_FF is
        port (
            T: in std_logic;
            Q: out std_logic;
            NQ: out std_logic
        );
    end component;

    component D_FF is
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

    -- signal mux_ai_y_b: std_logic_vector(9 downto 0) := (others => '0');
    -- signal mux_ai_y_r: std_logic_vector(9 downto 0) := (others => '0');
    signal sig_ai_y: std_logic_vector(9 downto 0) := (others => '0');

    signal sig_spawn: std_logic_vector(2 downto 0) := (others => '0');
begin
    reset_ai <= (pregame='1') or (next_level='1') or (not (sig_spawn="11"));
    reset_spawn <= (pregame='1') or (next_level='1') or (collision='1');

    ai_x: D_FF generic map(
        10
    )
    port map(
        clk48,
        '0',
        pregame or midgame,
        mux_ai_x_r,
        sig_ai_x
    );
    mux_ai_x_b <= std_logic_vector(unsigned(sig_ai_x) + 1) when mux_ai_x_sel='1' else
                    std_logic_vector(unsigned(sig_ai_x) - 1);
    mux_ai_x_r <= mux_ai_x_b when reset_ai='1' else
                    mux_ai_x_a;
    
    comp_ai_x_max: comparator_u generic map(
        10
    )
    port map(
        sig_ai_x,
        "1001001111", --639-48
        open,
        is_ai_x_max,
        open
    );

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

    ai_x_dir: T_FF port map(
        is_ai_x_max or is_ai_x_min,
        mux_ai_x_sel,
        open
    );

    ai_y: D_FF generic map(
        10
    )
    port map(
        clk48,
        reset_ai,
        is_ai_x_max or is_ai_x_min,
        std_logic_vector(unsigned(sig_ai_y) + 48),
        -- mux_ai_y_r,
        sig_ai_y
    );
    -- mux_ai_y_b <= std_logic_vector(unsigned(sig_ai_y) - 48);
    -- mux_ai_y_r <= (others => '1') when reset_ai='1' else
    --                 mux_ai_x_b;

    ai_x <= sig_ai_x;
    ai_y <= sig_ai_y;

    -- destroyed: D_FF generic map(
    --     1
    -- )
    -- port map(
    --     clk_50M,
    --     '0',

    -- ); 

    spawn: counter generic map(
        2
    )
    port map(
        clk_s,
        reset_spawn,
        reset_ai,
        (others => '1'),
        sig_spawn
    )

    ai_h: D_FF genetic map(
        1
    ) port map(
        clk_50M,
        '0',
        '1',
        reset_ai,
        ai_hidden
    );
end architecture;