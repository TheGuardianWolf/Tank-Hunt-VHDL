-- Provides logic components for the controller

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity game_control_block is
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
end entity;

architecture behavior of game_control_block is
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

    signal reset_control: std_logic := '0';
    signal level_count: std_logic_vector(1 downto 0) := (others => '0');
    
    signal time_comp_a: std_logic_vector(7 downto 0) := (others => '0');
    signal time_comp_b: std_logic_vector(7 downto 0) := (others => '0');
    signal time_comp_r: std_logic_vector(2 downto 0) := (others => '0');

    signal mux_k_reg: std_logic_vector(7 downto 0) := (others => '0'); 

    signal kill_comp_a: std_logic_vector(7 downto 0) := (others => '0');
    signal kill_comp_b: std_logic_vector(7 downto 0) := (others => '0');
    signal kill_comp_r: std_logic_vector(2 downto 0) := (others => '0');

    signal sig_kill_total: std_logic_vector(7 downto 0) := (others => '0');

    signal sel_time_limit: std_logic := '0';
    signal sel_kill_thresh: std_logic_vector(1 downto 0) := (others => '0');

    signal buffer_timeout: std_logic := '0';
    signal buffer_kills_reached: std_logic := '0';

    signal previous_kills: std_logic_vector(7 downto 0) := (others => '0');

    signal collision_toggle: std_logic := '0';
begin
    reset_control <= pregame or next_level;

    -- Main timer to count seconds from the seconds clock input
    timer: counter 
    generic map (
        8
    )    
    port map(
        clk_s,
        reset_control,
        midgame,
        (others => '1'),
        time_comp_a
    );
	game_time <= time_comp_a;

    -- Counter to store current level
    -- 0 is a training level
    -- Others are game levels
    l_count: counter generic map(
        2
    ) port map(
        clk_50M,
        pregame,
        next_level,
        (others => '1'),
        level_count
    );
    current_level <= level_count;


    -- k_ff: T_FF port map(
    --     bullet_collision,
    --     '0',
    --     collision_toggle,
    --     open
    -- );
    -- current_kills <= kill_comp_a;

    mux_k_reg <= std_logic_vector(unsigned(kill_comp_a) + 1) when (bullet_collision = '1') else
                kill_comp_a;
    -- Counter to store current kills
    k_reg: register_d generic map(
        8
    ) port map(
        clk_50M,
        reset_control,
        midgame,
        mux_k_reg,
        kill_comp_a
    );
    current_kills <= kill_comp_a;
    -- k_count: counter generic map(
    --     8
    -- ) port map(
    --     clk_50M,
    --     reset_control,
    --     bullet_collision, -- Connect this to the impact detection signal from the bullet
    --     (others => '1'),
    --     kill_comp_a
    -- );
    -- current_kills <= kill_comp_a;

    sig_kill_total <= std_logic_vector(unsigned(kill_comp_a) + unsigned(previous_kills));

    -- Register to store previous kill count
    k_previous: register_d generic map(
        8
    ) port map(
        clk_50M,
        pregame,
        next_level,
        sig_kill_total,
        previous_kills
    );

    -- Register to store total kill count
    k_total: register_d generic map(
        8
    ) port map(
        clk_50M,
        pregame,
        midgame,
        sig_kill_total,
        total_kills
    );

    -- Comparator to generate max level signal
    max_level_comp: comparator_u generic map(
        2
    ) port map(
        level_count,
        "11",
        open,
        max_level,
        open
    );
    
    -- Comparator to generate timeout signal
    time_comp: comparator_u generic map(
        8
    ) port map(
        time_comp_a,
        time_comp_b,
        time_comp_r(0),
        time_comp_r(1),
        time_comp_r(2)
    );
    -- Timeout differs depending on the current level
    time_comp_b <= std_logic_vector(to_unsigned(90,8)) when level_count="00" else 
                    std_logic_vector(to_unsigned(60,8));
    buffer_timeout <= time_comp_r(2) or time_comp_r(1);

    -- Comparator to check if kill threshold is reached
    kill_comp: comparator_u generic map(
        8
    ) port map(
        kill_comp_a,
        kill_comp_b,
        kill_comp_r(0),
        kill_comp_r(1),
        kill_comp_r(2)
    );
    -- Kill threshold increases based on current level
    with level_count select kill_comp_b <=
        std_logic_vector(to_unsigned(10,8)) when "01",
        std_logic_vector(to_unsigned(15,8)) when "10",
        std_logic_vector(to_unsigned(20,8)) when "11",
        (others => '1') when others; -- Set to max for training
        
    buffer_kills_reached <= kill_comp_r(2) or kill_comp_r(1);

    -- Register stores game mode independant from sw0 input
    g_mode: register_d generic map(
        1
    ) port map(
        clk_50M,
        '0',
        pregame,
        D(0) => switch,
        Q(0) => game_mode
    );
    
    -- Toggles pause mode on button press
    g_pause: T_FF port map(
        btn1,
        pregame,
        game_pause,
        open
    );

    -- Toggles game victory on signal from FSM
    g_won: T_FF port map(
        win,
        pregame,
        game_won,
        open
    );

    -- Clock syncs the timeout signal
    t_out: register_d generic map(
        1
    ) port map(
        clk_50M,
        pregame,
        midgame,
        D(0) => buffer_timeout,
        Q(0) => timeout
    );

    -- Clock syncs the kills reached signal
    k_reached: register_d generic map(
        1
    ) port map(
        clk_50M,
        pregame,
        midgame,
        D(0) => buffer_kills_reached,
        Q(0) => kills_reached
    );
end architecture;