-- Finite state machine design
-- EE 209 - Group 10

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
    reset_level: out std_logic := '0';
    reset_time: out std_logic := '0';
    reset_kills: out std_logic := '0';
    reset_win: out std_logic := '0'
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
          if ((pause = '0') and (timeout = '1')) then
            NextState <= ended;
          else
            NextState <= train;
          end if;

        when hunt =>
          if (sample_13 = '1') then
            NextState <= data_vote;
          else
            NextState <= data;
          end if;

        when ended =>
          if (bit_9 = '1' and vote_3 = '1') then
            NextState <= validate;
          elsif (vote_3 = '1') then
            NextState <= data;
          else
            NextState <= data_vote;
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
      sample_increment <= '0';
      sample_reset <= '0';
      bits_shift <= '0';
      bits_increment <= '0';
      bits_reset <= '0';
      vote_shift <= '0';
      vote_increment <= '0';
      vote_reset <= '0';
      display_update <= '0';
      display_select_reset <= '0';
      desync <= '0';

      -- State conditional outputs
      case CurrentState is
        -- Idle state behavior:
        -- When a logic low is detected on incoming Rx, the state starts the
        -- read process by resetting all counters to 0.
        when idle =>
        -- state <= "000";
        if (Rx = '0') then
          sample_reset <= '1';
          bits_reset <= '1';
          vote_reset <= '1';
        end if;

        -- Start state behavior:
        -- This state doesn't do much until sample_5 is recieved. This signal
        -- begins the voting process, as start will go to the start_vote state.
        -- In all cases, the sample count is incremented.
        when start =>
        -- state <= "001";
        if (sample_5 = '1') then
          sample_increment <= '1';
          vote_shift <= '1';
          vote_increment <= '1';
        else
          sample_increment <= '1';
        end if;

        -- Start Voting state behavior:
        -- The start vote state will decide whether the start bit is valid or
        -- is caused by noise. In any case, if sample_7 is reached, this causes
        -- a sample reset to prepare for the data state. The state waits for
        -- the results from the three votes, and will issue a desync if the
        -- majority_Rx turns out to be a false start. If waiting for votes,
        -- vote shifting and counter incrementing occurs, and sample is also
        -- incremented. If successful, vote counter will be reset.
        when start_vote =>
        -- state <= "010";
        if (sample_7 = '1') then
          sample_reset <= '1';
        end if;
        if (vote_3 = '1' and majority_Rx = '0') then
          vote_reset <= '1';
          sample_increment <= '1';
        elsif (vote_3 = '1') then
          desync <= '1';
        else
          vote_shift <= '1';
          vote_increment <= '1';
          sample_increment <= '1';
        end if;

        -- Data state behavior:
        -- This state doesn't do much until sample_13 is recieved. This signal
        -- begins the voting process, as data will go to the data_vote state.
        -- In all cases, the sample count is incremented.
        when data =>
        -- state <= "011";
        if (sample_13 = '1') then
          sample_increment <= '1';
          vote_shift <= '1';
          vote_increment <= '1';
        else
          sample_increment <= '1';
        end if;

        -- Data Voting state behavior:
        -- The data voting state will tell the datapath when the votes are ready
        -- to be accounted for in the bits storage. It also handles the
        -- transition once all ten bits are accounted for.
        when data_vote =>
        -- state <= "100";
        if (bit_9 = '1' and vote_3 = '1') then
          bits_shift <= '1';
          sample_increment <= '1';
          vote_reset <= '1';
        elsif (vote_3 = '1') then
          bits_shift <= '1';
          bits_increment <= '1';
          sample_increment <= '1';
          vote_reset <= '1';
        else
          vote_shift <= '1';
          vote_increment <= '1';
          sample_increment <= '1';
        end if;

        -- Validate state behavior:
        -- The validation state handles the display updates should there be no
        -- validation error reported from the datapath checks. If a sync packet
        -- is detected, then a display select reset signal is asserted. This
        -- state also asserts a desync if a validation_error occurs and delays
        -- state transition in an attempt to automatically sync with the UART
        -- frame.
        when validate =>
        -- state <= "101";
        if (validation_error = '0') then
          display_update <= '1';
          if (sync = '1') then
            display_select_reset <= '1';
          end if;
        else
          desync <= '1';
          sample_increment <= '1';
          if (resync_delay = '0' and sample_15 = '1') then
            sample_increment <= '1';
            bits_increment <= '1';
          end if;
        end if;
      end case;
    end process;
end architecture;
