library ieee;
use ieee.std_logic_1164.all;

entity game_datapath is
    port(
        clk: in std_logic;
        btn1: in std_logic;
        btn2: in std_logic;
        switch: in std_logic;
        pregame: in std_logic;
        midgame: in std_logic;
        endgame: in std_logic;
        win: in std_logic;
        next_level: in std_logic;
        game_mode: out std_logic;
        pause: out std_logic;
        timeout: out std_logic;
        kills_reached: out std_logic;
    );
end entity;