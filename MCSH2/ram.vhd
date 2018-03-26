----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:41:30 03/16/2018 
-- Design Name: 
-- Module Name:    ram - Behavioral 
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

entity ram is
    Port ( ADDRESS : in  STD_LOGIC_VECTOR (7 downto 0);
           DATA_IN : in  STD_LOGIC_VECTOR (7 downto 0);
           READ : in  STD_LOGIC;
			  WRITE: in STD_LOGIC;
           CLK : in  STD_LOGIC;
           DATA_OUT : out  STD_LOGIC_VECTOR (7 downto 0));
end ram;

architecture Behavioral of ram is


type arr_of_arr is array(0 to 255) of STD_LOGIC_VECTOR(7 downto 0);

signal registers : arr_of_arr := (	
	0 => X"61",
	1 => X"00",
	2 => X"00",
	3 => X"61",
	4 => X"01",
	5 => X"14",
	6 => X"61",
	7 => X"02", 
	8 => X"03",
	9 => X"69",
	10 => X"02",
	11 => X"00",
	12 => X"6d",
	13 => X"16",
	14 => X"63",
	15 => X"02",
	16 => X"01",
	17 => X"02",
	18 => X"00",
	19 => X"01",
	20 => X"67",
	21 => X"09",
	22 => X"08",
	23 => X"00",
	24 => X"00",

	others => ( others => '0'));
begin
  process(CLK) 
  begin 
    if CLK = '1' then
		if WRITE = '1' then
			registers(to_integer(unsigned(ADDRESS))) <= DATA_IN;
		elsif READ = '1' then
			DATA_OUT <= registers(to_integer(unsigned(ADDRESS)));
		end if;
    end if;
  end process;

end Behavioral;
