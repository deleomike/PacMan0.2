----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/04/2017 08:48:46 PM
-- Design Name: 
-- Module Name: Score_Display - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Score_Display is
Port (
value : in std_logic_vector(3 downto 0);
--decimalpoint : in std_logic := '0';
--SW : in std_logic_vector(2 downto 0);
CLK100MHZ : in std_logic;
--    blank : in std_logic;
--    test : in std_logic;
channels : out std_logic_vector(7 downto 0);
    segs : out std_logic_vector(6 downto 0));
end Score_Display;
-- This is a good third project since it is simply combinatorial logic. When
-- synthesized the selection statement (case) generates a decoder that takes
-- four input lines and generates eight output lines. (the decimal point is
-- always set to 'off.' If you want to get decimal point control, try adding
-- another pin (dp) to the port description, and then you can assign it with
-- a concurrent signal assignment
architecture behavioral of Score_Display is
signal counting: std_logic_vector(3 downto 0);
begin
    process(CLK100MHZ) is
   begin
      if(rising_edge(CLK100MHZ)) then
            if counting="1111" then
               counting <="0000";
            else
               counting <= counting + 1;
            end if;

         end if;
   end process;

channels <= not X"01"; -- invert 1

--  process (counting, CLK100MHZk,value, blank, test) is
process (value) is
begin
--if (blank = '1') then
--    segs <= NOT "0000000";
--elsif (test = '1') then
--    segs <= NOT "1111111";
--else
    case value is
 --   case counting is
        when "0000" => segs <= NOT "0111111"; -- 0
         when "0001" => segs <=NOT "0000110"; -- 1
         when "0010" => segs <=NOT "1011011"; -- 2
         when "0011" => segs <=NOT "1001111"; -- 3
         when "0100" => segs <=NOT "1100110"; -- 4
         when "0101" => segs <=NOT "1101101"; -- 5
         when "0110" => segs <=NOT "1111101"; -- 6
         when "0111" => segs <=NOT "0000111"; -- 7
         when "1000" => segs <=NOT "1111111"; -- 8
         when "1001" => segs <=NOT "1100111"; -- 9
         when "1010" => segs <=NOT "1110111"; -- A
         when "1011" => segs <=NOT "1111100"; -- b
         when "1100" => segs <=NOT "0111001"; -- c
         when "1101" => segs <=NOT "1011110"; -- d
         when "1110" => segs <=NOT "1111001"; -- E
         when others => segs <=NOT "1110001"; -- f
    end case;

end process;
end behavioral;
