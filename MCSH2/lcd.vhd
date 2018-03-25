----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:46:16 12/14/2017 
-- Design Name: 
-- Module Name:    lcd - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lcd is
    Port ( clk, reset : in std_logic;
			  PRINT : in std_logic;
			  E: inout std_logic;
			  RS,RW,SF_CE0 : out std_logic;
			  DB : out std_logic_vector(3 downto 0) 
			);
end lcd;

architecture Behavioral of lcd is

type estados is (FI1A,FI1B,FI2A,FI2B,FI3A,FI3B,BOR1,BOR2,CONT1,CONT2,MOD1,MOD2,hold, start_printing, keep_printing,
						r_00, r_01);	
signal pr_estado:estados := FI1A;
signal sig_estado:estados := FI1A;
begin

		SF_CE0 <='1';
		SEC_maquina: process(clk, reset)  --- PARTE SECUENCIAL DE LA MAQUINA DE ESTADOS
				begin
					if(clk'event and clk='1') then
					 if(reset='1') then
					   pr_estado <= FI1A;
					else
						pr_estado <= sig_estado;
					 end if;
					end if; 
		end process SEC_maquina;
		COMB_maquina: process (pr_estado) --- PARTE COMBINATORIA DE LA MAQUINA DE ESTADOS
      begin
            case pr_estado is
				  when FI1A =>      ----- INICIO código $28 SELECCIÓM DEL BUS DE 4 BITS 
					RS <='0'; RW<='0';
					DB <="0010";
					sig_estado <= FI1B;
				  when FI1B =>
					RS <='0'; RW<='0';
					DB <="1000";
					sig_estado <= FI2A;
				  when FI2A =>
					RS <='0'; RW<='0';
					DB <="0010";
					sig_estado <= FI2B;
				  when FI2B =>
					RS <='0'; RW<='0';
					DB <="1000";
					sig_estado <= FI3A;
				  when FI3A =>
					RS <='0'; RW<='0';
					DB <="0010";
					sig_estado <= FI3B;
				  when FI3B =>
					RS <='0'; RW<='0';
					DB <="1000";       ----- FIN código $28 SELECCIÓM DEL BUS DE 4 BITS
					sig_estado <= BOR1;
					when BOR1 =>       ----- INICIO código $01 BORRA LA PANTALLA Y CURSOR A CASA
					RS <='0'; RW<='0';
					DB <="0000";
					sig_estado <= BOR2;
					when BOR2 =>
					RS <='0'; RW<='0';
					DB <="0001";       ----- FIN código $01 BORRA LA PANTALLA Y CURSOR A CASA 
					sig_estado <= CONT1;
					when CONT1 =>      ----- INICIO código $0C ACTIVA LA PANTALLA
					RS <='0'; RW<='0';
					DB <="0000";
					sig_estado <= CONT2; 
					when CONT2 =>
					RS <='0'; RW<='0';
					DB <="1100";       ----- FIN código $0C ACTIVA LA PANTALLA
					sig_estado <= MOD1;
					when MOD1 =>       ----- INICIO código $06 INCREMENTA CURSOR EN LA PANTALLA 
					RS <='0'; RW<='0';
					DB <="0000";
					sig_estado <= MOD2;
					when MOD2 =>
					RS <='0'; RW<='0';
					DB <="0110";       ----- FIN código $06 INCREMENTA CURSOR EN LA PANTALLA 
					sig_estado <= hold;
					when hold =>
						if (PRINT = '1') then
							sig_estado <= start_printing;
						end if;
					when start_printing =>					--NUMERO UNO
						RS <='1'; RW<='0';
						DB <="0011";
						sig_estado <= keep_printing;
					when keep_printing =>
						RS <='1'; RW<='0';
--						for I in 0 to 4 loop
--								if (auxiliar < 10*(I+1))then
--								var1 := I;
--								DB <=std_logic_vector(to_unsigned(I,4));
--								exit;
--								
--								end if; 
--						end loop;
--						
						DB <= "0001";
						sig_estado <= r_00;
					when r_00 =>	
						RS <='0'; RW<='0';
						DB <="0001";
						sig_estado <= r_01;
					when r_01 =>	
						RS <='0'; RW<='0';
						DB <="0000";
						sig_estado <= hold;
	         end case;
			  
         end process COMB_maquina;
end Behavioral;

