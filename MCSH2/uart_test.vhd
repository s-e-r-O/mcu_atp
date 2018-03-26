-----------------------------------------------------------
--               UART | Test application
-----------------------------------------------------------
--
-- Copyright (c) 2008, Thijs van As <t.vanas@gmail.com>
--
-----------------------------------------------------------
-- Input:      clk        | System clock
--             reset      | System reset
--             rx         | RX signal
--
-- Output:     tx         | TX signal
-----------------------------------------------------------
-- UART test application which echoes received signal back
-- via transmitter.
-----------------------------------------------------------
-- uart.vhd
-----------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity uart is
    port (clk   : in std_logic;
          reset : in std_logic;
          rx    : in std_logic;
          tx : out std_logic;
			 data : out STD_LOGIC_VECTOR(7 downto 0));
end entity uart;

architecture behavioural of uart is
    component clk_18432 is
        port (clk   : in std_logic;
              reset : in std_logic;

              clk_18432 : out std_logic);
    end component clk_18432;

    component uart_tx is
        port (clk      : in std_logic;
              reset    : in std_logic;
              data_in  : in std_logic_vector(7 downto 0);
              in_valid : in std_logic;

              tx        : out std_logic;
              accept_in : out std_logic);
    end component uart_tx;

    component uart_rx is
        port (clk   : in std_logic;
              reset : in std_logic;
              rx    : in std_logic;

              data_out  : out std_logic_vector(7 downto 0);
              out_valid : out std_logic);
    end component uart_rx;
	 
	 component debounce IS
		PORT(
		 clk     : IN  STD_LOGIC;  --input clock
		 button  : IN  STD_LOGIC;  --input signal to be debounced
		 result  : OUT STD_LOGIC); --debounced signal
	end component debounce;

    signal clk_18432_s : std_logic                    := '0';
    signal data_s      : std_logic_vector(7 downto 0) := x"00";
    signal data_r      : std_logic_vector(7 downto 0) := x"00";
    signal in_valid_s  : std_logic                    := '0';
    signal out_valid_s : std_logic                    := '0';
    signal accept_s    : std_logic                    := '0';
begin
	 DATA <= data_r;
    in_valid_s <= accept_s and out_valid_s;
    
    clk_gen : clk_18432 port map (clk   => clk,
                                  reset => reset,

                                  clk_18432 => clk_18432_s);

    tx_0 : uart_tx port map (clk      => clk_18432_s,
                             reset    => reset,
                             data_in  => data_r,
                             in_valid => in_valid_s,

                             tx        => tx,
                             accept_in => accept_s);
	 
    rx_0 : uart_rx port map (clk   => clk_18432_s,
                             reset => reset,
                             rx    => rx,

                             data_out  => data_s,
                             out_valid => out_valid_s);
	d_0 : debounce port map(clk => clk_18432_s,
									button => data_s(0),
									result => data_r(0));
	d_1 : debounce port map(clk => clk_18432_s,
									button => data_s(1),
									result => data_r(1));
	d_2 : debounce port map(clk => clk_18432_s,
									button => data_s(2),
									result => data_r(2));
	d_3 : debounce port map(clk => clk_18432_s,
									button => data_s(3),
									result => data_r(3));
	d_4 : debounce port map(clk => clk_18432_s,
									button => data_s(4),
									result => data_r(4));
	d_5 : debounce port map(clk => clk_18432_s,
									button => data_s(5),
									result => data_r(5));
	d_6 : debounce port map(clk => clk_18432_s,
									button => data_s(6),
									result => data_r(6));
	d_7 : debounce port map(clk => clk_18432_s,
									button => data_s(7),
									result => data_r(7));
end architecture behavioural;
