-- AI tank systems
-- Responds to game controller outputs

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity game_ai_block is
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

    component lfsr_g is
        port(
            Clk: in std_logic;
            Reset: in std_logic;
            Enable: in std_logic;
            Seed: in std_logic_vector(15 downto 0);
            Q: out std_logic_vector(15 downto 0) := (others => '0')
        );
    end component;

    component collision_detect_u is
        generic(
            size: integer := 10;
            a_length: integer := 64;
            b_length: integer := 64
        );
        port(
            clk_50M: in std_logic;
            a_x: in std_logic_vector(size-1 downto 0);
            a_y: in std_logic_vector(size-1 downto 0);
            b_x: in std_logic_vector(size-1 downto 0);
            b_y: in std_logic_vector(size-1 downto 0);
            collision: out std_logic := '0'
        );
    end component;

    signal reset_ai: std_logic := '0';
    signal reset_spawn: std_logic := '0';
    signal inv_reset_ai: std_logic := '1';

    signal ai_move_clk: std_logic := '0';

    signal ai_x_sel: std_logic := '1';
    signal mux_ai_x_a: std_logic_vector(9 downto 0) := (others => '0');
    signal mux_ai_x_b: std_logic_vector(9 downto 0) := (others => '0');
    signal mux_ai_x_r: std_logic_vector(9 downto 0) := (others => '0');

    signal ai_x_limit: std_logic := '0';
    signal rand_x_dir: std_logic := '0';
    signal mux_ai_x_dir: std_logic := '0';
    signal sig_ai_x: std_logic_vector(9 downto 0) := (others => '0');
    signal is_ai_x_max: std_logic := '0';
    signal is_ai_x_min: std_logic := '0';

    signal sig_ai_y: std_logic_vector(9 downto 0) := (others => '0');
    signal sig_ai_y_d: std_logic_vector(9 downto 0) := (others => '0');

    signal spawn_timer: std_logic_vector(1 downto 0) := (others => '0');
    signal spawned: std_logic := '0';
    signal enable_spawn: std_logic := '0';

    signal spawn_next: std_logic_vector(2 downto 0) := (others => '0');
    signal sig_delayed_enable: std_logic := '0';

    signal out_bullet_collision: std_logic := '0';
    signal out_player_collision: std_logic := '0';
    signal sig_bullet_collision: std_logic := '0';
    signal sig_player_collision: std_logic := '0';
	 
    signal random_number: std_logic_vector(15 downto 0) := (others => '0');
begin
    -- Signal to reset ai components
    reset_ai <= (pregame) or (next_level) or (not spawned);
    -- Signal to reset the spawn counter
    reset_spawn <= (pregame) or (next_level) or (out_bullet_collision);
    -- Signal to enable the spawn timer
    enable_spawn <= (midgame) and (not spawned) and (enable);
    -- Signal to start next tank in chain
    sig_delayed_enable <= spawn_next(1) or spawn_next(2);

    -- LFSR to randomise starting position
    random_start: lfsr_g port map(
        clk_50M,
        reset_ai,
        enable,
        lfsr_seed,
        random_number
    );
    mux_ai_x_a(8 downto 0) <= std_logic_vector(
        unsigned(random_number(15 downto 7)) + to_unsigned(32,9)
    ); -- Centers the distribution on screen, does not spawn tank at edge.
    -- Prevents edge glitching and removes need to re-roll if number is too big.
	 
    -- AI x position
    reg_ai_x: register_d generic map(
        10
    )
    port map(
        ai_move_clk,
        '0',
        enable,
        mux_ai_x_r,
        sig_ai_x
    );

    with current_level select ai_move_clk <=
        clk_move(2) when "00",
        clk_move(2) when "01",
        clk_move(1) when "10",
        clk_move(0) when "11",
        '0' when others;

    -- Use either an adder or subtractor based on the direction the AI tank is going
    -- to calculate next x position
    mux_ai_x_b <= std_logic_vector(unsigned(sig_ai_x) + 1) when ai_x_sel='1' else
                    std_logic_vector(unsigned(sig_ai_x) - 1);
    mux_ai_x_r <= mux_ai_x_a when reset_ai='1' else
                    mux_ai_x_b;
    
    -- Comparator to signal when ai reaches max X position
    comp_ai_x_max: comparator_u generic map(
        10
    )
    port map(
        sig_ai_x,
        std_logic_vector(to_unsigned(574,10)), --639-64
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
        std_logic_vector(to_unsigned(1,10)),
        open,
        is_ai_x_min,
        open
    );

    -- Multiplexer to switch directions randomly or based on X limits
    ai_x_limit <= is_ai_x_max or is_ai_x_min;
    rand_x_dir <= random_number(6);

    mux_ai_x_dir <= rand_x_dir when reset_ai='1' else
                    ai_x_limit;

    -- Toggles directions when max or min signals for x are asserted
    ai_x_dir: T_FF port map(
        mux_ai_x_dir,
        '0',
        ai_x_sel,
        open
    );

    -- Stores AI Y position
    sig_ai_y_d <=   std_logic_vector(to_unsigned(32,10)) when enable_spawn = '1' else
                    std_logic_vector(unsigned(sig_ai_y) + 64) when ai_x_limit = '1' else
                    sig_ai_y;
    
    reg_ai_y: register_d generic map(
        10
    )
    port map(
        ai_move_clk,
        reset_ai,
        enable,
        sig_ai_y_d,
        sig_ai_y
    );

    ai_x <= sig_ai_x;
    ai_y <= sig_ai_y;

    -- Detect collision with bullet
    bullet_collide: collision_detect_u 
    generic map(
        10, 64, 8
    )
    port map(
        clk_50M,
        sig_ai_x,
        sig_ai_y,
        bullet_x,
        bullet_y,
        sig_bullet_collision
    );

    -- Clocked signal for bullet collision detection output
    sig_bullet_collide: register_d generic map(
        1
    ) port map(
        clk_50M,
        reset_ai,
        enable,
        D(0) => sig_bullet_collision,
        Q(0) => out_bullet_collision
    );
    bullet_collision <= out_bullet_collision;

    -- Detect collision with player
    player_collide: collision_detect_u 
    generic map(
        10, 64, 64
    )
    port map(
        clk_50M,
        sig_ai_x,
        sig_ai_y,
        player_x,
        player_y,
        sig_player_collision
    );

    -- Clocked signal for player collision detection output
    sig_player_collide: register_d generic map(
        1
    ) port map(
        clk_50M,
        reset_ai,
        enable,
        D(0) => sig_player_collision,
        Q(0) => out_player_collision
    );
    player_collision <= out_player_collision;

    -- Counter to track AI tank spawn time
    spawn: counter generic map(
        2
    )
    port map(
        clk_s,
        reset_spawn,
        enable_spawn,
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

    inv_reset_ai <= not (reset_ai='1');

    -- Clocked signal for showing the ai tank (i.e. after spawn)
    ai_s: register_d generic map(
        1
    ) port map(
        clk_50M,
        '0',
        enable,
        D(0) => inv_reset_ai,
        Q(0) => ai_show
    );

    comp_spawn_next: comparator_u generic map(
        10
    ) port map(
        sig_ai_y,
        std_logic_vector(to_unsigned(64,10)),
        spawn_next(0),
        spawn_next(1),
        spawn_next(2)
    );

    -- Signal for next AI tank to start being active
    delayed_enable: register_d generic map(
        1
    ) port map(
        clk_50M,
        next_level or pregame,
        sig_delayed_enable,
        D(0) => sig_delayed_enable,
        Q(0) => enable_next
    );
end architecture;