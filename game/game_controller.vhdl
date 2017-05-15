-- Finite state machine to control game progression.

library ieee;
use ieee.std_logic_1164.all;

entity game_controller is
  port(
    clk_50M: in std_logic := '0';

    ready: in std_logic := '0';
    game_start: in std_logic := '0';
    game_mode: in std_logic := '0';
    game_reset: in std_logic := '0';
    game_pause: in std_logic := '0';
    timeout: in std_logic := '0';
    max_level: in std_logic := '0';
    kills_reached: in std_logic := '0';

    pregame: out std_logic := '0';
    midgame: out std_logic := '0';
    endgame: out std_logic := '0';
    mouse_pos_reset: out std_logic := '0';
    win: out std_logic := '0';
    next_level: out std_logic := '0';
    state_debug: out std_logic_vector(2 downto 0) := (others => '0')
  );
end entity;

architecture behaviour of game_controller is
  type states is (
    init, -- Initialise any peripherals
    menu, -- In main menu
    train, -- In training mode
    hunt, -- In tank hunt game mode
    ended -- In game end screen
  );
  signal CurrentState, NextState : states:= init;

  begin
    -- Changes the state to NextState
    StateProcess: process(clk_50M)
    begin
      if rising_edge(clk_50M) then
        CurrentState <= NextState;
      end if;
    end process;

    -- Determines what the next state is
    NextStateLogic: process(
      CurrentState,
      ready,
      game_start,
      game_mode,
      game_reset,
      kills_reached,
      timeout,
      game_pause,
      max_level
    )
    begin
      case CurrentState is
        when init =>
          if (ready = '1') then
            -- If initialised, go to menu
            NextState <= menu;
          else
            -- Otherwise continue as before
            NextState <= init;
          end if;

        when menu =>
          if (game_start = '1') then
            if (game_mode = '1') then
              -- If start button pressed, and game mode is set to 1
              NextState <= hunt;
            else
              -- If start button pressed, and game mode is 0
              NextState <= train;
            end if;
          else
            -- Nothing of significance happened
            NextState <= menu;
          end if;

        when train =>
          if (game_reset = '1') then
            -- Go back to menu if reset is pressed
            NextState <= menu;
          else
            if ((game_pause = '0') and (timeout = '1')) then
              -- End game after timeout
              NextState <= ended;
            else
              -- Otherwise continue in current state
              NextState <= train;
            end if;
          end if;

        when hunt =>
        if (game_reset = '1') then
          -- If reset is pressed, go back to menu
          NextState <= menu;
        else
          if ((game_pause = '0') and ((timeout = '1') and ((max_level = '1') or (kills_reached = '0')))) then
            -- If game is not paused and has timed out, and it's max level or kills have not been reached, end game
            NextState <= ended;
          else
            -- Otherwise stay in hunt state
            NextState <= hunt;
          end if;
        end if;

        when ended =>
          if (game_reset = '1') then
            -- If reset is pressed, go to menu
            NextState <= menu;
          else
            -- Otherwise stay in game end screen
            NextState <= ended;
          end if;
      end case;
    end process;

    -- Sets output values
    OutputLogic: process(
        CurrentState,
        ready,
        game_start,
        game_reset,
        game_mode,
        kills_reached,
        timeout,
        game_pause,
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
      mouse_pos_reset <= '0';

      -- State conditional outputs
      case CurrentState is
        when init =>
          state_debug <= "000";
          if (ready = '1') then
            pregame <= '1';
          end if;

        when menu =>
          state_debug <= "001";
          if (game_start = '1') then
            midgame <= '1';
            mouse_pos_reset <= '1';
            if (game_mode = '1') then
              next_level <= '1';
            end if;
          else
            pregame <= '1';
          end if;

        when train =>
        state_debug <= "010";
        if (game_reset = '1') then
          pregame <= '1';
        else
          if (game_pause = '0') then
            if (timeout = '0') then
              midgame <= '1';
            else
              endgame <= '1';
            end if;
          end if;
        end if;

        when hunt =>
        state_debug <= "011";
        if (game_reset = '1') then
          pregame <= '1';
        else
          if (game_pause = '0') then
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
        end if;

        when ended =>
        state_debug <= "100";
        if (game_reset = '1') then
          pregame <= '1';
        else
          endgame <= '1';
        end if;
      end case;
    end process;
end architecture;