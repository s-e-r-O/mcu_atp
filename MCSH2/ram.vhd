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
		0 => X"68",
		1 => X"7B",
		2 => X"00",		
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
