----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:43:36 03/16/2018 
-- Design Name: 
-- Module Name:    main - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity main is
	Port (
		CLK : in STD_LOGIC;
		RESET : in STD_LOGIC;
		E: inout std_logic;
		RS,RW,SF_CE0 : out std_logic;
		DB : out std_logic_vector(3 downto 0);
		REGISTER_A : out STD_LOGIC_VECTOR(7 downto 0)
	);
end main;

architecture Behavioral of main is

component CPU is
	Port (
		ADDRESS : out STD_LOGIC_VECTOR(7 downto 0);
		READ_RAM : out STD_LOGIC;
		WRITE_RAM : out STD_LOGIC;
		DATA : in STD_LOGIC_VECTOR(7 downto 0);
		DATA_OUT : out STD_LOGIC_VECTOR(7 downto 0);
		CLK : in STD_LOGIC;
		RESET : in STD_LOGIC;
		E: inout std_logic;
		RS,RW,SF_CE0 : out std_logic;
		DB : out std_logic_vector(3 downto 0);
		REGISTER_A : out STD_LOGIC_VECTOR(7 downto 0)
		
	);
end component;

component ram is
    Port ( ADDRESS : in  STD_LOGIC_VECTOR (7 downto 0);
           DATA_IN : in  STD_LOGIC_VECTOR (7 downto 0);
           READ : in  STD_LOGIC;
			  WRITE: in STD_LOGIC;
           CLK : in  STD_LOGIC;
           DATA_OUT : out  STD_LOGIC_VECTOR (7 downto 0)
	);
end component;

signal mem_bus : STD_LOGIC_VECTOR(7 downto 0);
signal data_bus_in_ram : STD_LOGIC_VECTOR(7 downto 0);
signal data_bus_out_ram : STD_LOGIC_VECTOR(7 downto 0);
signal read_ram : STD_LOGIC;
signal write_ram : STD_LOGIC;

begin
u1: CPU port map (mem_bus, read_ram, write_ram, data_bus_out_ram, data_bus_in_ram, CLK, RESET, E, RS, RW, SF_CE0, DB, REGISTER_A);
u2: ram port map (mem_bus, data_bus_in_ram, read_ram, write_ram, CLK, data_bus_out_ram);

end Behavioral;
