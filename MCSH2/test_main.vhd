--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   00:46:52 03/26/2018
-- Design Name:   
-- Module Name:   C:/Users/i3/Google Drive/UPB/7_Septimo Semestre/mcu_atp/MCSH2/test_main.vhd
-- Project Name:  MCSH2
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: main
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY test_main IS
END test_main;
 
ARCHITECTURE behavior OF test_main IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT main
    PORT(
         CLK : IN  std_logic;
         RESET : IN  std_logic;
         E : INOUT  std_logic;
         RS : OUT  std_logic;
         RW : OUT  std_logic;
         SF_CE0 : OUT  std_logic;
         DB : OUT  std_logic_vector(3 downto 0);
         REGISTER_A : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal RESET : std_logic := '0';

	--BiDirs
   signal E : std_logic;

 	--Outputs
   signal RS : std_logic;
   signal RW : std_logic;
   signal SF_CE0 : std_logic;
   signal DB : std_logic_vector(3 downto 0);
   signal REGISTER_A : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: main PORT MAP (
          CLK => CLK,
          RESET => RESET,
          E => E,
          RS => RS,
          RW => RW,
          SF_CE0 => SF_CE0,
          DB => DB,
          REGISTER_A => REGISTER_A
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      wait for CLK_period*100;
   end process;

END;
