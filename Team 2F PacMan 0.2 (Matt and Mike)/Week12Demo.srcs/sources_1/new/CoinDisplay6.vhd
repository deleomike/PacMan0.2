library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- simulation library
--library UNISIM;
--use UNISIM.VComponents.all;

-- the mouse_displayer entity declaration
-- read above for behavioral description and port definitions.
entity CoinDisplay6 is
port (
   pixel_clk6: in std_logic;
   enable6: in std_logic_vector(3 downto 0);
--   xpos     : in std_logic_vector(11 downto 0);
--   ypos     : in std_logic_vector(11 downto 0);

   hcount6   : in std_logic_vector(11 downto 0);
   vcount6   : in std_logic_vector(11 downto 0);
   --blank    : in std_logic; -- if VGA blank is used

   --red_in   : in std_logic_vector(3 downto 0); -- if VGA signal pass-through is used
   --green_in : in std_logic_vector(3 downto 0);
   --blue_in  : in std_logic_vector(3 downto 0);
   
   enable_mouse_display_out6 : out std_logic;

   red_out6  : out std_logic_vector(3 downto 0);
   green_out6: out std_logic_vector(3 downto 0);
   blue_out6 : out std_logic_vector(3 downto 0)
);

-- force synthesizer to extract distributed ram for the
-- displayrom signal, and not a block ram, to save BRAM resources.
attribute rom_extract : string;
attribute rom_extract of CoinDisplay6: entity is "yes";
attribute rom_style : string;
attribute rom_style of CoinDisplay6: entity is "distributed";

end CoinDisplay6;

architecture Behavioral of CoinDisplay6 is

------------------------------------------------------------------------
-- CONSTANTS
------------------------------------------------------------------------

type displayrom is array(0 to 255) of std_logic_vector(1 downto 0);
-- the memory that holds the cursor.
-- 00 - black
-- 01 - white
-- 1x - transparent

constant mouserom: displayrom := (
"11","11","11","11","11","01","01","01","01","01","01","11","11","11","11","11",
"11","11","11","11","01","00","00","00","00","00","00","01","11","11","11","11",
"11","11","11","01","00","00","00","00","00","00","00","00","01","11","11","11",
"11","11","11","00","00","00","00","00","00","00","00","00","00","11","11","11",
"11","11","01","00","00","01","01","01","01","01","01","00","00","01","11","11",
"11","11","01","00","00","01","01","01","01","01","01","00","00","01","11","11",
"11","11","01","00","00","01","01","01","01","01","01","00","00","01","11","11",
"11","11","01","00","00","01","01","01","01","01","01","00","00","01","11","11",
"11","11","01","00","00","01","01","01","01","01","01","00","00","01","11","11",
"11","11","01","00","00","01","01","01","01","01","01","00","00","01","11","11",
"11","11","01","00","00","01","01","01","01","01","01","00","00","01","11","11",
"11","11","11","00","00","00","00","00","00","00","00","00","00","11","11","11",
"11","11","11","01","00","00","00","00","00","00","00","00","01","11","11","11",
"11","11","11","11","01","00","00","00","00","00","00","01","11","11","11","11",
"11","11","11","11","11","01","00","00","00","00","01","11","11","11","11","11",
"11","11","11","11","11","11","01","01","01","01","11","11","11","11","11","11"
);

-- width and height of cursor.
constant OFFSET: std_logic_vector(4 downto 0) := "10000";   -- 16

------------------------------------------------------------------------
-- SIGNALS
------------------------------------------------------------------------

-- pixel from the display memory, representing currently displayed
-- pixel of the cursor, if the cursor is being display at this point
signal mousepixel: std_logic_vector(1 downto 0) := (others => '0');
-- when high, enables displaying of the cursor, and reading the
-- cursor memory.
signal enable_mouse_display: std_logic := '0';

-- difference in range 0-15 between the vga counters and mouse position
signal xdiff: std_logic_vector(3 downto 0) := (others => '0');
signal ydiff: std_logic_vector(3 downto 0) := (others => '0');

signal red_int  : std_logic_vector(3 downto 0);
signal green_int: std_logic_vector(3 downto 0);
signal blue_int : std_logic_vector(3 downto 0);

signal red_int1  : std_logic_vector(3 downto 0);
signal green_int1: std_logic_vector(3 downto 0);
signal blue_int1 : std_logic_vector(3 downto 0);
signal xpos : std_logic_vector(11 downto 0) := "000111101010";
signal ypos : std_logic_vector(11 downto 0) := "000111011011";
--signal hcount : std_logic_vector(11 downto 0) := "001000100110";
--signal vcount : std_logic_vector(11 downto 0) := "001000100110";
begin

   -- compute xdiff
   x_diff: process(hcount6, xpos)
   variable temp_diff: std_logic_vector(11 downto 0) := (others => '0');
   begin
         temp_diff := hcount6 - xpos;
         xdiff <= temp_diff(3 downto 0);
   end process x_diff;

   -- compute ydiff
   y_diff: process(vcount6, xpos)
   variable temp_diff: std_logic_vector(11 downto 0) := (others => '0');
   begin
         temp_diff := vcount6 - ypos;
         ydiff <= temp_diff(3 downto 0);
   end process y_diff;

 -- read pixel from memory at address obtained by concatenation of
   -- ydiff and xdiff
   mousepixel <= mouserom(conv_integer(ydiff & xdiff))
                 when rising_edge(pixel_clk6);

   -- set enable_mouse_display high if vga counters inside cursor block
   enable_mouse: process(pixel_clk6, hcount6, vcount6, xpos, ypos)
   begin
      if(rising_edge(pixel_clk6)) then
         if(hcount6 >= xpos +X"001" and hcount6 < (xpos + OFFSET - X"001") and
            vcount6 >= ypos and vcount6 < (ypos + OFFSET)) and
            (mousepixel = "00" or mousepixel = "01")
         then
            enable_mouse_display <= '1';
         else
            enable_mouse_display <= '0';
         end if;
      end if;
   end process enable_mouse;
   
enable_mouse_display_out6 <= enable_mouse_display;

   -- if cursor display is enabled, then, according to pixel
   -- value, set the output color channels.
 process(pixel_clk6, enable6)
   begin
      if(rising_edge(pixel_clk6)) then
         -- if in visible screen
--       if(blank = '0') then
            -- in display is enabled
            if(enable_mouse_display = '1' and enable6 = "0001") then
               -- white pixel of cursor
               if(mousepixel = "01") then
                  red_out6 <= (others => '1');
                  green_out6 <= (others => '0');
                  blue_out6 <= (others => '0');
               -- black pixel of cursor
               elsif(mousepixel = "00") then
                  red_out6 <= (others => '0');
                  green_out6 <= (others => '0');
                  blue_out6 <= (others => '0');
               -- transparent pixel of cursor
               -- let input pass to output
--               else
--                  red_out <= red_in;
--                  green_out <= green_in;
--                  blue_out <= blue_in;
               end if;
            -- cursor display is not enabled
            -- let input pass to output.
--          else
--               red_out <= red_in;
--               green_out <= green_in;
--               blue_out <= blue_in;
            end if;
                if(enable_mouse_display = '1' and enable6 = "0000") then
                       -- white pixel of cursor
                       if(mousepixel = "01") then
                          red_out6 <= (others => '1');
                          green_out6 <= (others => '1');
                          blue_out6 <= (others => '1');
                       -- black pixel of cursor
                       elsif(mousepixel = "00") then
                          red_out6 <= (others => '1');
                          green_out6 <= (others => '1');
                          blue_out6 <= (others => '1');
                       -- transparent pixel of cursor
                       -- let input pass to output
        --               else
        --                  red_out <= red_in;
        --                  green_out <= green_in;
        --                  blue_out <= blue_in;
                       end if;
                    -- cursor display is not enabled
                    -- let input pass to output.
        --          else
        --               red_out <= red_in;
        --               green_out <= green_in;
        --               blue_out <= blue_in;
                    end if;
         -- not in visible screen, black outputs.
--       else
--            red_out <= (others => '0');
--            green_out <= (others => '0');
--            blue_out <= (others => '0');
--      end if;
      end if;
   end process;


end Behavioral;