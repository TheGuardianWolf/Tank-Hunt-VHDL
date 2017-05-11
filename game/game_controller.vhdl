-- Finite state machine design

library ieee;
use ieee.std_logic_1164.all;

entity game_controller is
  port(
    clk: in std_logic := '0';

    ready: in std_logic := '0';
    game_start: in std_logic := '0';
    game_mode: in std_logic := '0';
    timeout: in std_logic := '0';
    pause: in std_logic := '0';
    max_level: in std_logic := '0';
    kills_reached: in std_logic := '0';

    pregame: out std_logic := '0';
    midgame: out std_logic := '0';
    endgame: out std_logic := '0';
    win: out std_logic := '0';
    next_level: out std_logic := '0';
    --reset_level: out std_logic := '0';
    --reset_time: out std_logic := '0';
    --reset_kills: out std_logic := '0';
    --reset_win: out std_logic := '0';
    --reset_pause: out std_logic := '0';
  );
end entity;

architecture behaviour of game_controller is
  type states is (
    init,
    menu,
    train,
    hunt,
    ended
  );
  signal CurrentState, NextState : states:= init;

  begin
    -- Changes the state to NextState
    StateProcess: process(clk)
    begin
      if rising_edge(clk) then
        CurrentState <= NextState;
      end if;
    end process;

    -- Determines what the next state is
    NextStateLogic: process(
      CurrentState,
      ready,
      game_start,
      game_mode,
      kills_reached,
      timeout,
      pause,
      max_level
    )
    begin
      case CurrentState is
        when init =>
          if (ready = '1') then
            NextState <= menu;
          else
            NextState <= init;
          end if;

        when menu =>
          if (start = '1') then
            if (game_mode = '1') then
              NextState <= hunt;
            else
              NextState <= train;
            end if;
          else
            NextState <= menu;
          end if;

        when train =>
          if (reset = '1') then
            if ((pause = '0') and (timeout = '1')) then
              NextState <= ended;
            else
              NextState <= train;
            end if;
          else
            NextState <= menu;
          end if;

        when hunt =>
        if (reset = '1') then
          if ((pause = '0') and ((timeout = '1') and ((max_level = '1') or (kills_reached = '0')))) then
            NextState <= ended;
          else
            NextState <= hunt;
          end if;
        else
          NextState <= menu;
        end if;

        when ended =>
          if (reset = '1') then
            NextState <= menu;
          else
            NextState <= ended;
          end if;
      end case;
    end process;

    -- Sets output values
    OutputLogic: process(
        CurrentState,
        ready,
        game_start,
        game_mode,
        kills_reached,
        timeout,
        pause,
        max_level
    )
    begin
      -- Default outputs:
      -- These are asserted always to prevent latch behavior.
      pregame <= '0';
      midgame <= '0';
      endgame <= '0';
      win <= '0';
      next_level <= '0';

      -- State conditional outputs
      case CurrentState is
        when init =>
          -- state <= "000";
          if (ready = '1') then
            pregame <= '1';
          end if;

        when menu =>
          -- state <= "001";
          if (start = '1') then
            midgame <= '1';
            if (game_mode = '1') then
              next_level <= '1';
            end if;
          else
            pregame <= '1';
          end if;

        when train =>
        -- state <= "010";
        if (reset = '1') then
          pregame <= '1';
        else
          if (pause = '0') then
            if (timeout = '0') then
              midgame <= '1';
            else
              endgame <= '1';
            end if;
          end if;
        end if;

        when hunt =>
        -- state <= "011";
        if (pause = '0') then
          if (timeout = '1') then
            if (kills_reached = '1') then
              if (max_level = '1') then
                win <= '1';
                endgame <= '1';
              else
                next_level <= '1';
                midgame <= '1';
              end if;
            else
              endgame <= '1';
            end if;
          else
            midgame <= '1';
          end if;
        end if;

        when ended =>
        -- state <= "100";
        if (reset = '1')
          pregame <= '1';
        else
          endgame <= '1';
        end if;
      end case;
    end process;
end architecture;
