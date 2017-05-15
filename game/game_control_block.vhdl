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
        next_level: in std_logic := '0';
        game_won: out std_logic := '0';
        game_mode: out std_logic := '0';
        game_pause: out std_logic := '0';
        max_level: out std_logic := '0';
        timeout: out std_logic := '0';
        kills_reached: out std_logic := '0'
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

    signal level_count: std_logic_vector(1 downto 0) := (others => '0');
    
    signal time_comp_a: std_logic_vector(5 downto 0) := (others => '0');
    signal time_comp_b: std_logic_vector(5 downto 0) := (others => '0');
    signal time_comp_r: std_logic_vector(2 downto 0) := (others => '0');

    signal kill_comp_a: std_logic_vector(7 downto 0) := (others => '0');
    signal kill_comp_b: std_logic_vector(7 downto 0) := (others => '0');
    signal kill_comp_r: std_logic_vector(2 downto 0) := (others => '0');

    signal sel_time_limit: std_logic := '0';
    signal sel_kill_thresh: std_logic_vector(1 downto 0) := (others => '0');

    signal buffer_timeout: std_logic := '0';
    signal buffer_kills_reached: std_logic := '0';
begin
    timer: counter 
    generic map (
        6
    )    
    port map(
        clk_s,
        pregame or next_level,
        midgame,
        (others => '1'),
        time_comp_a
    );

    l_count: counter generic map(
        2
    ) port map(
        clk_50M,
        pregame,
        next_level,
        (others => '1'),
        level_count
    );

    k_count: counter generic map(
        8
    ) port map(
        clk_50M,
        pregame,
        '0',
        (others => '1'),
        kill_comp_a
    );

    max_level_comp: comparator_u generic map(
        2
    ) port map(
        level_count,
        "11",
        open,
        max_level,
        open
    );
    
    time_comp: comparator_u generic map(
        6
    ) port map(
        time_comp_a,
        time_comp_b,
        time_comp_r(0),
        time_comp_r(1),
        time_comp_r(2)
    );
    time_comp_b <= "111100" when level_count="00" else "011110";
    buffer_timeout <= time_comp_r(2) or time_comp_r(1);

    kill_comp: comparator_u generic map(
        8
    ) port map(
        kill_comp_a,
        kill_comp_b,
        kill_comp_r(0),
        kill_comp_r(1),
        kill_comp_r(2)
    );
    with level_count select kill_comp_b <=
        (others => '1') when "00",
        "00000101" when "01",
        "00001100" when "10",
        "00010100" when "11";
    buffer_kills_reached <= kill_comp_r(2) or kill_comp_r(1);

    g_mode: register_d generic map(
        1
    ) port map(
        clk_50M,
        '0',
        pregame,
        D(0) => switch,
        Q(0) => game_mode
    );
    
    g_pause: T_FF port map(
        btn1,
        pregame,
        game_pause,
        open
    );

    g_won: T_FF port map(
        win,
        pregame,
        game_won,
        open
    );

    t_out: register_d generic map(
        1
    ) port map(
        clk_50M,
        pregame,
        midgame,
        D(0) => buffer_timeout,
        Q(0) => timeout
    );

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