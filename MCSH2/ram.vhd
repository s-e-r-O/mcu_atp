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
	5 => X"03",
	6 => X"61",
	7 => X"02",
	8 => X"02",
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
	22 => X"61",
	23 => X"03",
	24 => X"01",
	25 => X"61",
	26 => X"01",
	27 => X"02",
	28 => X"01",
	29 => X"02",
	30 => X"00",
	31 => X"69",
	32 => X"02",
	33 => X"00",
	34 => X"6d",
	35 => X"3f",
	36 => X"61",
	37 => X"04",
	38 => X"00",
	39 => X"61",
	40 => X"05",
	41 => X"02",
	42 => X"69",
	43 => X"05",
	44 => X"00",
	45 => X"6d",
	46 => X"37",
	47 => X"02",
	48 => X"04",
	49 => X"03",
	50 => X"63",
	51 => X"05",
	52 => X"01",
	53 => X"67",
	54 => X"2a",
	55 => X"01",
	56 => X"03",
	57 => X"04",
	58 => X"63",
	59 => X"02",
	60 => X"01",
	61 => X"67",
	62 => X"1f",
	63 => X"08",
	64 => X"03",
	65 => X"00",
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
