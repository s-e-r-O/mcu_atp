----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:42:24 03/16/2018 
-- Design Name: 
-- Module Name:    cpu - Behavioral 
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

entity CPU is
	Port (
		ADDRESS : out STD_LOGIC_VECTOR(7 downto 0);
		READ_RAM : out STD_LOGIC;
		WRITE_RAM : out STD_LOGIC;
		DATA : in STD_LOGIC_VECTOR(7 downto 0);
		DATA_OUT : out STD_LOGIC_VECTOR(7 downto 0);
		CLK : in STD_LOGIC;
		RESET : in STD_LOGIC;
		REGISTER_A : out STD_LOGIC_VECTOR(7 downto 0)
	);
end CPU;

architecture Behavioral of CPU is

constant ADDR_SIZE : integer := 8;
constant DATA_SIZE : integer := 8;
constant INSTR_SIZE : integer := 24;

signal PC, MAR : STD_LOGIC_VECTOR(ADDR_SIZE - 1 downto 0) := (others => '0');
signal MBR : STD_LOGIC_VECTOR(DATA_SIZE - 1 downto 0) := (others => '0');
signal IR : STD_LOGIC_VECTOR(INSTR_SIZE - 1 downto 0) := (others => '0');

type arr_of_arr is array(7 downto 0) of STD_LOGIC_VECTOR(DATA_SIZE - 1 downto 0);
signal REGISTERS : arr_of_arr := (others => ( others => '0'));

signal state : integer := 0;
signal carry : STD_LOGIC := '0';
signal zero : STD_LOGIC := '0';

begin

ADDRESS <= MAR;
DATA_OUT <= MBR;
REGISTER_A <= REGISTERS(0);

process (clk, DATA) 
variable pc_int : integer;
variable instr_offset : integer := 0;
variable instr_length : integer := 0;
variable cur_state : integer := 0;
begin
	if (RESET = '1') then
		PC <= (others => '0');
		MAR <= (others => '0');
		MBR <= (others => '0');
		IR <= (others => '0');
		REGISTERS <= (others => (others => '0'));
		state <= 0;
		instr_offset := 0;
		instr_length := 0;
		cur_state := 0;
	elsif (clk'event and clk='1') then
		case state is 
			when 0 =>
				MAR <= PC;
				READ_RAM <= '1';
				state <= 1;
				cur_state := 5;
			when 1 =>
				state <= 2;
			when 2 => 
				MBR <= DATA;
				READ_RAM <= '1';
				state <= cur_state;
			
			when 3 => 
				
				WRITE_RAM <= '1';
				
				state <= 4;
						
			when 4 =>
				WRITE_RAM <= '0';
				state <= cur_state;
				
				
			when 5 =>
				IR(INSTR_SIZE - 1 -(ADDR_SIZE * instr_offset) downto INSTR_SIZE - (ADDR_SIZE * (instr_offset +1))) <= MBR; 
				instr_offset := instr_offset + 1;
				pc_int := to_integer(unsigned(PC)) + 1;
				PC <= std_logic_vector(to_unsigned(pc_int, ADDR_SIZE));

				state <= 6;
			when 6 =>
				if (IR(INSTR_SIZE - 4 downto INSTR_SIZE - ADDR_SIZE) = "00000" ) then
					instr_length:= 1;
				elsif (IR(INSTR_SIZE - 4 downto INSTR_SIZE - ADDR_SIZE) = "00001" ) then
					instr_length := 3;
				elsif (IR(INSTR_SIZE - 4 downto INSTR_SIZE - ADDR_SIZE) = "00010" ) then
					instr_length := 3;
				elsif (IR(INSTR_SIZE - 4 downto INSTR_SIZE - ADDR_SIZE) = "00011" ) then
					instr_length := 3;
				elsif (IR(INSTR_SIZE - 4 downto INSTR_SIZE - ADDR_SIZE) = "00100" ) then
					instr_length := 3;
				elsif (IR(INSTR_SIZE - 4 downto INSTR_SIZE - ADDR_SIZE) = "00101" ) then
					instr_length := 3;
				elsif (IR(INSTR_SIZE - 4 downto INSTR_SIZE - ADDR_SIZE) = "00110" ) then
					instr_length := 2;
				elsif (IR(INSTR_SIZE - 4 downto INSTR_SIZE - ADDR_SIZE) = "00111" ) then
					instr_length := 2;
				elsif (IR(INSTR_SIZE - 4 downto INSTR_SIZE - ADDR_SIZE) = "01000" ) then
					instr_length := 2;
				elsif (IR(INSTR_SIZE - 4 downto INSTR_SIZE - ADDR_SIZE) = "01001" ) then
					instr_length := 3;
				end if;
				
				if (instr_offset = instr_length	) then
						instr_offset := 0;
						state <= 7;
				else
						state <= 0;
				end if;
				
				
			when 7 =>				
				if (IR(INSTR_SIZE - 4 downto INSTR_SIZE - ADDR_SIZE) = "00000" ) then --HLT DONE
					state <= 8; 
				elsif (IR(INSTR_SIZE - 4 downto INSTR_SIZE - ADDR_SIZE) = "00001" ) then  -- MOV DONE
					if (IR(INSTR_SIZE - 1 downto INSTR_SIZE - 3) = "000") then
						REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE)))) <= REGISTERS(to_integer(unsigned(IR(ADDR_SIZE-1 downto 0))));
 						state<= 0;						
					elsif (IR(INSTR_SIZE - 1 downto INSTR_SIZE - 3) = "001") then
						MAR <= IR(ADDR_SIZE-1 downto 0);
						READ_RAM <= '1';
						cur_state := 9;
						state <= 1;
					elsif (IR(INSTR_SIZE - 1 downto INSTR_SIZE - 3) = "010") then
						MAR <= REGISTERS(to_integer(unsigned(IR(ADDR_SIZE-1 downto 0))));
						READ_RAM <= '1';
						cur_state := 9;
						state <= 1;
					elsif (IR(INSTR_SIZE - 1 downto INSTR_SIZE - 3) = "011") then
						REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE)))) <= IR(ADDR_SIZE-1 downto 0);
						state<=0;
					elsif (IR(INSTR_SIZE - 1 downto INSTR_SIZE - 3) = "100") then
						MAR <= REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE))));
						MBR <= REGISTERS(to_integer(unsigned(IR(ADDR_SIZE-1 downto 0))));
						cur_state := 0;
						state <= 3;
					elsif (IR(INSTR_SIZE - 1 downto INSTR_SIZE - 3) = "101") then
						MAR <= IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE);
						MBR <= REGISTERS(to_integer(unsigned(IR(ADDR_SIZE-1 downto 0))));
						cur_state := 0;
						state <= 3;
					elsif (IR(INSTR_SIZE - 1 downto INSTR_SIZE - 3) = "110") then
						MAR <= IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE);
						MBR <= IR(ADDR_SIZE-1 downto 0);
						cur_state := 0;
						state <= 3;
					elsif (IR(INSTR_SIZE - 1 downto INSTR_SIZE - 3) = "111") then
						MAR <= REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE))));
						MBR <= IR(ADDR_SIZE-1 downto 0);
						cur_state := 0;
						state <= 3;
	
					end if;
				elsif (IR(INSTR_SIZE - 4 downto INSTR_SIZE - ADDR_SIZE) = "00010" ) then --ADD
					if (IR(INSTR_SIZE - 1 downto INSTR_SIZE - 3) = "000") then
							REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE))))<= std_logic_vector(to_unsigned(to_integer(unsigned(REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE))))))+ to_integer(unsigned(REGISTERS(to_integer(unsigned(IR(ADDR_SIZE-1 downto 0)))))),DATA_SIZE));
							state <= 0;
					elsif (IR(INSTR_SIZE - 1 downto INSTR_SIZE - 3) = "001") then
							MAR <= IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE);
							READ_RAM <= '1';
							cur_state := 10;
							state <= 1;
					elsif (IR(INSTR_SIZE - 1 downto INSTR_SIZE - 3) = "010") then
							MAR <= REGISTERS(to_integer(unsigned(IR(ADDR_SIZE-1 downto 0))));
							READ_RAM <= '1';
							cur_state := 10;
							state <= 1;
					elsif (IR(INSTR_SIZE - 1 downto INSTR_SIZE - 3) = "011") then
							REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE))))<= std_logic_vector(to_unsigned(to_integer(unsigned(REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE))))))+ to_integer(unsigned(IR(ADDR_SIZE-1 downto 0))),DATA_SIZE));
							state <= 0;
					end if;
					
					
					
				elsif (IR(INSTR_SIZE - 4 downto INSTR_SIZE - ADDR_SIZE) = "00011" ) then --SUB
					if (IR(INSTR_SIZE - 1 downto INSTR_SIZE - 3) = "000") then
							REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE))))<= std_logic_vector(to_unsigned(to_integer(unsigned(REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE)))))) - to_integer(unsigned(REGISTERS(to_integer(unsigned(IR(ADDR_SIZE-1 downto 0)))))),DATA_SIZE));
							state <= 0;
					elsif (IR(INSTR_SIZE - 1 downto INSTR_SIZE - 3) = "001") then
							MAR <= IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE);
							READ_RAM <= '1';
							cur_state := 11;
							state <= 1;
					elsif (IR(INSTR_SIZE - 1 downto INSTR_SIZE - 3) = "010") then
							MAR <= REGISTERS(to_integer(unsigned(IR(ADDR_SIZE-1 downto 0))));
							READ_RAM <= '1';
							cur_state := 11;
							state <= 1;
					elsif (IR(INSTR_SIZE - 1 downto INSTR_SIZE - 3) = "011") then
							REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE))))<= std_logic_vector(to_unsigned(to_integer(unsigned(REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE)))))) - to_integer(unsigned(IR(ADDR_SIZE-1 downto 0))),DATA_SIZE));
							state <= 0;
					end if;
				elsif (IR(INSTR_SIZE - 4 downto INSTR_SIZE - ADDR_SIZE) = "00100" ) then --AND
				
					if (IR(INSTR_SIZE - 1 downto INSTR_SIZE - 3) = "000") then
							REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE))))<= REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE)))) AND REGISTERS(to_integer(unsigned(IR(ADDR_SIZE-1 downto 0))));
							state <= 0;
					elsif (IR(INSTR_SIZE - 1 downto INSTR_SIZE - 3) = "001") then
							MAR <= IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE);
							READ_RAM <= '1';
							cur_state := 12;
							state <= 1;
					elsif (IR(INSTR_SIZE - 1 downto INSTR_SIZE - 3) = "010") then
							MAR <= REGISTERS(to_integer(unsigned(IR(ADDR_SIZE-1 downto 0))));
							READ_RAM <= '1';
							cur_state := 12;
							state <= 1;
					elsif (IR(INSTR_SIZE - 1 downto INSTR_SIZE - 3) = "011") then
							REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE))))<= REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE)))) AND REGISTERS(to_integer(unsigned(IR(ADDR_SIZE-1 downto 0))));
							state <= 0;
					end if;
					
				elsif (IR(INSTR_SIZE - 4 downto INSTR_SIZE - ADDR_SIZE) = "00101" ) then --OR
					if (IR(INSTR_SIZE - 1 downto INSTR_SIZE - 3) = "000") then
							REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE))))<= REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE)))) OR REGISTERS(to_integer(unsigned(IR(ADDR_SIZE-1 downto 0))));
							state <= 0;
					elsif (IR(INSTR_SIZE - 1 downto INSTR_SIZE - 3) = "001") then
							MAR <= IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE);
							READ_RAM <= '1';
							cur_state := 13;
							state <= 1;
					elsif (IR(INSTR_SIZE - 1 downto INSTR_SIZE - 3) = "010") then
							MAR <= REGISTERS(to_integer(unsigned(IR(ADDR_SIZE-1 downto 0))));
							READ_RAM <= '1';
							cur_state := 13;
							state <= 1;
					elsif (IR(INSTR_SIZE - 1 downto INSTR_SIZE - 3) = "011") then
							REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE))))<= REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE)))) OR REGISTERS(to_integer(unsigned(IR(ADDR_SIZE-1 downto 0))));
							state <= 0;
					end if;
					
				elsif (IR(INSTR_SIZE - 4 downto INSTR_SIZE - ADDR_SIZE) = "00110" ) then --NOT
					REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE))))<= NOT REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE))));
					state <= 0; 
				elsif (IR(INSTR_SIZE - 4 downto INSTR_SIZE - ADDR_SIZE) = "00111" ) then --JMP
					if (IR(INSTR_SIZE - 1 downto INSTR_SIZE - 3) = "000") then
							PC<=REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE))));
							state <= 0;
					elsif (IR(INSTR_SIZE - 1 downto INSTR_SIZE - 3) = "001") then
							MAR <= IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE);
							READ_RAM <= '1';
							cur_state := 14;
							state <= 1;
					elsif (IR(INSTR_SIZE - 1 downto INSTR_SIZE - 3) = "010") then
							MAR <= REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE))));
							READ_RAM <= '1';
							cur_state := 14;
							state <= 1;
					elsif (IR(INSTR_SIZE - 1 downto INSTR_SIZE - 3) = "011") then
							PC<=IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE);
							state <= 0;
					end if;
					
					
				elsif (IR(INSTR_SIZE - 4 downto INSTR_SIZE - ADDR_SIZE) = "01000" ) then --PRNT
					state <= 0; 
				elsif (IR(INSTR_SIZE - 4 downto INSTR_SIZE - ADDR_SIZE) = "01001" ) then --CMP
					if (IR(INSTR_SIZE - 1 downto INSTR_SIZE - 3) = "000") then
						if (REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE)))) = REGISTERS(to_integer(unsigned(IR(ADDR_SIZE-1 downto 0))))) then
							zero <= '1';
						else
							zero <= '0';
							if (to_integer(unsigned(REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE)))))) > to_integer(unsigned(REGISTERS(to_integer(unsigned(IR(ADDR_SIZE-1 downto 0))))))) then
								carry <= '1';
							else
								carry <= '0';
							end if;
						end if;
						state <= 0;
					elsif (IR(INSTR_SIZE - 1 downto INSTR_SIZE - 3) = "001") then
						MAR <= IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE);
						READ_RAM <= '1';
						cur_state := 15;
						state <= 1;
					elsif (IR(INSTR_SIZE - 1 downto INSTR_SIZE - 3) = "010") then
						MAR <= REGISTERS(to_integer(unsigned(IR(ADDR_SIZE-1 downto 0))));
						READ_RAM <= '1';
						cur_state := 15;
						state <= 1;
					elsif (IR(INSTR_SIZE - 1 downto INSTR_SIZE - 3) = "011") then
						if (REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE)))) = IR(ADDR_SIZE-1 downto 0)) then
							zero <= '1';
						else
							zero <= '0';
							if (to_integer(unsigned(REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE)))))) > to_integer(unsigned(IR(ADDR_SIZE-1 downto 0)))) then
								carry <= '1';
							else
								carry <= '0';
							end if;
						end if;
						state <= 0;
					end if;
				end if;		
				
			when 8 =>				--HLT
				 state<= 8;	
				 
			when 9 =>				--MOV
				REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE))))<=MBR;
				state <=0;
				
			when 10 =>				--ADD
				REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE))))<= std_logic_vector(to_unsigned(to_integer(unsigned(REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE))))))+ to_integer(unsigned(MBR)),DATA_SIZE));
				state <= 0;
				
			when 11 =>				--SUB
				REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE))))<= std_logic_vector(to_unsigned(to_integer(unsigned(REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE))))))- to_integer(unsigned(MBR)),DATA_SIZE));
				state <= 0;
			
			when 12 =>				--AND
				REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE))))<= REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE)))) AND MBR;
				state <= 0;
			when 13 =>				--OR
				REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE))))<= REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE)))) OR MBR;
				state <= 0;
				
			when 14 =>				--JMP
				PC<=MBR;
				state <= 0;
			when 15 =>				--CMP
				if (REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE)))) = MBR) then
					zero <= '1';
				else
					zero <= '0';
					if (to_integer(unsigned(REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE)))))) > to_integer(unsigned(MBR))) then
						carry <= '1';
					else
						carry <= '0';
					end if;
				end if;
				state <= 0;
			when others  =>
				state <= 8;
			
		end case;
	end if;
end process;

end Behavioral;
