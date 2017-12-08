
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;----------------------------------------------------------------------------------
USE ieee.numeric_std.ALL;

entity FinalConverter2 is
 Port ( clk : in std_logic;
        DataIn : in std_logic_vector(8 downto 0);
        Done : in std_logic;
        xpos: Out std_logic_vector(11 downto 0);
        ypos: Out std_logic_vector(11 downto 0));
end FinalConverter2;
architecture Behavioral of FinalConverter2 is
signal X : integer range 200 to 1150 := 550;
signal Y : integer range 230 to 800 := 535;
signal cnt : integer := 0;
begin
process (DataIn, Done, clk, cnt)
begin
if Done = '1' and clk'event and clk = '1' and cnt = 0 then
if DataIn = "100011101" then                            -- 'W' (up)
if cnt = 0 then
Y <= Y - 15;
end if;
cnt <= cnt + 1;
end if;
if DataIn = "000011100" then                            -- 'A' (left)
if cnt = 0 then
X <= X - 15;
end if;
cnt <= cnt + 1;
end if;
if DataIn = "100011011" then                            -- 'S' (down)
if cnt = 0 then
Y <= Y + 15;
end if;
cnt <= cnt + 1;
end if; 
if DataIn = "000100011" then                            -- 'D' (right)
if cnt = 0 then
X <= X + 15;
end if;
cnt <= cnt + 1;
end if;
end if;
if done = '0' then
cnt <= 0;
end if;
end process;


xpos <= std_logic_vector(to_unsigned(X, 12));
ypos <= std_logic_vector(to_unsigned(Y, 12));
end Behavioral;