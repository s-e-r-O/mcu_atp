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
		E: inout std_logic;
		RS,RW,SF_CE0 : out std_logic;
		DB : out std_logic_vector(3 downto 0);
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
signal print_init : STD_LOGIC := '0';
signal print_done : STD_LOGIC := '0';

type print_states is (HOLD,FI1A,FI1B,FI2A,FI2B,FI3A,FI3B,BOR1,BOR2,CONT1,CONT2,
	                 MOD1,MOD2,e1,e2, ret1, ret2);
signal print_state : print_states;

begin

ADDRESS <= MAR;
DATA_OUT <= MBR;
REGISTER_A <= REGISTERS(0);
SF_CE0 <='1';
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
		carry <= '0';
		zero <= '0';
		print_init <= '0';
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
				READ_RAM <= '0';
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
				elsif (IR(INSTR_SIZE - 4 downto INSTR_SIZE - ADDR_SIZE) = "01101" ) then
					instr_length := 2;
				elsif (IR(INSTR_SIZE - 4 downto INSTR_SIZE - ADDR_SIZE) = "01110" ) then
					instr_length := 2;
				elsif (IR(INSTR_SIZE - 4 downto INSTR_SIZE - ADDR_SIZE) = "01111" ) then
					instr_length := 2;
				elsif (IR(INSTR_SIZE - 4 downto INSTR_SIZE - ADDR_SIZE) = "10000" ) then
					instr_length := 2;
				elsif (IR(INSTR_SIZE - 4 downto INSTR_SIZE - ADDR_SIZE) = "10001" ) then
					instr_length := 2;
				elsif (IR(INSTR_SIZE - 4 downto INSTR_SIZE - ADDR_SIZE) = "10010" ) then
					instr_length := 2;
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
				elsif (IR(INSTR_SIZE - 4 downto INSTR_SIZE - ADDR_SIZE) = "01000" ) then --PRINT
					print_init <= '1';
					if (IR(INSTR_SIZE - 1 downto INSTR_SIZE - 3) = "000") then
							MBR<=REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE))));
							state <= 16;
					elsif (IR(INSTR_SIZE - 1 downto INSTR_SIZE - 3) = "001") then
							MAR <= IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE);
							READ_RAM <= '1';
							cur_state := 16;
							state <= 1;
					elsif (IR(INSTR_SIZE - 1 downto INSTR_SIZE - 3) = "010") then
							MAR <= REGISTERS(to_integer(unsigned(IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE))));
							READ_RAM <= '1';
							cur_state := 14;
							state <= 16;
					elsif (IR(INSTR_SIZE - 1 downto INSTR_SIZE - 3) = "011") then
							MBR<=IR(INSTR_SIZE - ADDR_SIZE-1 downto ADDR_SIZE);
							state <= 16;
					end if;
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
						MAR <= IR(ADDR_SIZE-1 downto 0);
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
				elsif (IR(INSTR_SIZE - 4 downto INSTR_SIZE - ADDR_SIZE) = "01101" ) then --JZ
					if (zero = '1') then
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
					else
						state <= 0;
					end if;
				elsif (IR(INSTR_SIZE - 4 downto INSTR_SIZE - ADDR_SIZE) = "01110" ) then --JNZ
					if (zero = '0') then
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
					else
						state <= 0;
					end if;
				elsif (IR(INSTR_SIZE - 4 downto INSTR_SIZE - ADDR_SIZE) = "01111" ) then --JA
					if (carry = '1') then
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
					else
						state <= 0;
					end if;
				elsif (IR(INSTR_SIZE - 4 downto INSTR_SIZE - ADDR_SIZE) = "10000" ) then --JAE
					if (zero = '1' or carry = '1') then
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
					else
						state <= 0;
					end if;
				elsif (IR(INSTR_SIZE - 4 downto INSTR_SIZE - ADDR_SIZE) = "10001" ) then --JB
					if (carry = '0') then
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
					else
						state <= 0;
					end if;
				elsif (IR(INSTR_SIZE - 4 downto INSTR_SIZE - ADDR_SIZE) = "10010" ) then --JBE
					if (zero = '1' or carry='0') then
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
					else
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
			when 16 =>
				if (print_done = '1') then
					print_init <= '0';
					state <= 0;
				else
					state <= 16;
				end if;
			when others  =>
				state <= 8;
			
		end case;
	end if;
end process;

reloj: process (clk)   -- DIVISOR DE FRECUENCIA DE 50 MHz a 500 Hz
		       variable cuenta:integer range 0 to 100000:=0;
               begin
             		if(clk'event and clk='1') then
						  if (cuenta < 100000) then
                      cuenta:=cuenta + 1;
						  else
							 cuenta := 0;
						  end if;	 
							if (cuenta < 50000) then
							 E <= '0';
							else
							 E <= '1';
							end if;	
						end if;
				 end process reloj;
process (E, reset)
	variable cur_digit : integer;
	variable num_digits : integer;
	variable num : integer;
	
begin
	if (reset = '1') then
		print_state <= HOLD;
		print_done <= '0';
	elsif (E'event and E='1') then
		case print_state is
				when HOLD =>
					if (print_init = '1') then
						print_done <= '0';
						print_state <= FI1A;
					else
						print_state <= HOLD;
					end if;
			  when FI1A =>      ----- INICIO código $28 SELECCION DEL BUS DE 4 BITS 
					RS <='0'; RW<='0';
					DB <="0010";
					print_state <= FI1B;
			  when FI1B =>
					RS <='0'; RW<='0';
					DB <="1000";
					print_state <= FI2A;
			  when FI2A =>
					RS <='0'; RW<='0';
					DB <="0010";
					print_state <= FI2B;
			  when FI2B =>
					RS <='0'; RW<='0';
					DB <="1000";
					print_state <= FI3A;
			  when FI3A =>
					RS <='0'; RW<='0';
					DB <="0010";
					print_state <= FI3B;
			  when FI3B =>
					RS <='0'; RW<='0';
					DB <="1000";       ----- FIN código $28 SELECCIÓM DEL BUS DE 4 BITS
					print_state <= BOR1;
				when BOR1 =>       ----- INICIO código $01 BORRA LA PANTALLA Y CURSOR A CASA
					RS <='0'; RW<='0';
					DB <="0000";
					print_state <= BOR2;
				when BOR2 =>
					RS <='0'; RW<='0';
					DB <="0001";       ----- FIN código $01 BORRA LA PANTALLA Y CURSOR A CASA 
					print_state <= CONT1;
				when CONT1 =>      ----- INICIO código $0C ACTIVA LA PANTALLA
					RS <='0'; RW<='0';
					DB <="0000";
					print_state <= CONT2;
				when CONT2 =>
					RS <='0'; RW<='0';
					DB <="1100";       ----- FIN código $0C ACTIVA LA PANTALLA
					print_state <= MOD1;
				when MOD1 =>       ----- INICIO código $06 INCREMENTA CURSOR EN LA PANTALLA 
					RS <='0'; RW<='0';
					DB <="0000";
					print_state <= MOD2;
				when MOD2 =>
					RS <='0'; RW<='0';
					DB <="0110";       ----- FIN código $06 INCREMENTA CURSOR EN LA PANTALLA 
					num := to_integer(unsigned(MBR));
					if (num >= 100) then
						num_digits := 3;
					elsif (num >= 10) then
						num_digits := 2;
					else
						num_digits := 1;
					end if;
					print_state <=e1;
				when e1 =>         
					RS <='1'; RW<='0';
					DB <="0011";
					case num_digits is
						when 3 =>
							for I in 2 downto 1 loop
								if (num >= 100*I)then
									cur_digit := I;
									num := num - cur_digit * 100;
									exit;
								end if; 
							end loop;
						when 2 =>
							for I in 9 downto 0 loop
								if (num >= 10*I)then
									cur_digit := I;
									num := num - cur_digit * 10;
									exit;
								end if; 
							end loop;
						when others =>
							cur_digit := num;
					end case;
					print_state <= e2;
				when e2 =>
					RS <='1'; RW<='0';
					DB <=std_logic_vector(to_unsigned(cur_digit,4));
					num_digits := num_digits - 1;
					if (num_digits > 0) then
						print_state <= e1;
					else
						print_state <= ret1; 
					end if;
				when ret1 =>        ----- INICIO código $80 RETORNO
					RS <='0'; RW<='0';
					DB <="1000";
					print_state <= ret2;
				when ret2 =>
					RS <='0'; RW<='0';
					DB <="0000";
					print_done <= '0';
					print_state <= HOLD; ----- FIN código $80 RETORNO
			end case;
		end if;
end process;

end Behavioral;
