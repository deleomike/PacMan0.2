-- if Clock is 100 MHZ
-- Count Value      Output Frequency
-- 1                    100 MHZ
-- 100,000,000           1Hz            (100 MHZ clock source)

--- 200,000,000             0.5 HZ  (25 MHZ clock source)

---
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity count_display is
    Port ( 
		
		value : in std_logic_vector(7 downto 0);
		CLK100MHZ : in std_logic;
--	    RESETME : in std_logic;   
		channels : out std_logic_vector(7 downto 0);
	    segs : out std_logic_vector(6 downto 0));
end count_display;

-- This is a good third project since it is simply combinatorial logic. When
-- synthesized the selection statement (case) generates a decoder that takes
-- four input lines and generates eight output lines. (the decimal point is 
-- always set to 'off.' If you want to get decimal point control, try adding
-- another pin (dp) to the port description, and then you can assign it with
-- a concurrent signal assignment 
architecture behavioral of count_display is
    
    
    signal counting: integer :=1;
		signal cnt: std_logic_vector(19 downto 0); -- divider counter for ~95.3Hz refresh rate (with 100MHz main clock)
	signal intAn: std_logic_vector(7 downto 0); -- internal signal representing anode data

     --   signal channelsBuffer: std_logic_vector(7 downto 0):= X"00";

signal value1 : std_logic_vector(3 downto 0);
signal value2 : std_logic_vector(3 downto 0);  

begin
	
	
	value1 <= value(3 downto 0);
	value2 <= value(7 downto 4);
	
	 channels <= intAn;
  --seg <= hex;

  clockDivider: process(CLK100MHZ)
  begin
     if CLK100MHZ'event and CLK100MHZ = '1' then
        cnt <= cnt + '1';
     end if;
  end process clockDivider;

  -- Anode Select
  with cnt(19 downto 17) select -- 100MHz/2^20 = 95.3Hz
     intAn <=    
        "11111110" when "000",
        "11111110" when "001",
        "11111110" when "010",
        "11111110" when "011",
        "11111101" when "100",
        "11111101" when "101",
        "11111101" when "110",
        "11111101" when others;

	
  --  process (counting, CLK100MHZk,value, blank, test) is
    process (intAn) is
    begin
	-- if (blank = '1') then
	    -- segs <= NOT "0000000";
	-- elsif (test = '1') then
	    -- segs <= NOT "1111111";
	-- else 
	if (intAn = "11111110" ) THEN 
	    case value1 is
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
		when others => segs <=NOT "1110001"; -- F
	    end case;
	    
	    else 
	    
	    case value2 is
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
        when others => segs <=NOT "1110001"; -- F
        end case;
        
        end if ;
	--end if;
    end process;
    
  

    
   

    
    
end behavioral;