----------------------------------------------------------------------------------
----------------------------------------------------------------------------
-- Author:  Albert Fazakas adapted from Alec Wyen and Mihaita Nagy
--          Copyright 2014 Digilent, Inc.
----------------------------------------------------------------------------
-- 
-- Create Date:    13:01:51 02/15/2013 
-- Design Name: 
-- Module Name:    Vga - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--       This module represents the Vga controller that creates the HSYNC and VSYNC signals
--    for the VGA screen and formats the 4-bit R, G and B signals to display various items
--    on the screen:
--       - A moving colorbar in the background
--       - A Digilent - Analog Devices logo for the Nexys4 board, the RGB data is provided 
--    by the LogoDisplay component. The logo bitmap is stored in the BRAM_1 Block RAM in .ngc format.
--       - The FPGA temperature on a 0..80C scale. Temperature data is taken from the XADC
--    component in the Artix-7 FPGA, provided by the upper level FPGAMonitor component and the RGB data is
--    provided by the Inst_XadcTempDisplay instance of the TempDisplay component.
--       - The Nexys4 Onboard ADT7420 Temperature Sensor temperature on a 0..80C scale. 
--    Temperature data is provided by the upper level TempSensorCtl component and the RGB data is
--    provided by the Inst_Adt7420TempDisplay instance of the TempDisplay component.
--       - The Nexys4 Onboard ADXL362 Accelerometer Temperature Sensor temperature on a 0..80C scale. 
--    Temperature data is provided by the upper level AccelerometerCtl component and the RGB data is
--    provided by the Inst_Adxl362TempDisplay instance of the TempDisplay component.
--       - The R, G and B data which is also sent to the Nexys4 onboard RGB Leds LD16 and LD17. The 
--    incomming RGB Led data is taken from the upper level RgbLed component and the formatted RGB data is provided
--    by the RGBLedDisplay component.
--       - The audio signal coming from the Nexys4 Onboard ADMP421 Omnidirectional Microphone. The formatted
--    RGB data is provided by the MicDisplay component.
--       - The X and Y acceleration in a form of a moving box and the acceleration magnitude determined by 
--    the SQRT (X^2 + Y^2 + Z^2) formula. The acceleration and magnitude data is provided by the upper level 
--    AccelerometerCtl component and the formatted RGB data is provided by the AccelDisplay component.
--       - The mouse cursor on the top on all of the items. The USB mouse should be connected to the Nexys4 board before 
--    the FPGA is configured. The mouse cursor data is provided by the upper level MouseCtl component and the 
--    formatted RGB data for the mouse cursor shape is provided by the MouseDisplay component.
--       - An overlay that displayed the frames and text for the displayed items described above. The overlay data is
--    stored in the overlay_bram Block RAM in the .ngc format and the data is provided by the OverlayCtl component.
--       The Vga controller holds the synchronization signal generation, the moving colorbar generation and the main
--    multiplexers for the outgoing R, G and B signals. Also the 108 MHz pixel clock (pxl_clk) generator is instantiated
--    inside the Vga controller.
--       The current resolution is 1280X1024 pixels, however, other resolutions can also be selected by 
--    commenting/uncommenting the corresponding VGA resolution constants. In the case when a different resolution
--    is selected, the pixel clock generator output frequency also has to be updated accordingly.
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.ALL;
--use ieee.math_real.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Vgaformouseonly is
    Port ( CLK_I : in  STD_LOGIC;
           -- VGA Output Signals
           VGA_HS_O : out  STD_LOGIC; -- HSYNC OUT
           VGA_VS_O : out  STD_LOGIC; -- VSYNC OUT
           VGA_RED_O    : out  STD_LOGIC_VECTOR (3 downto 0); -- Red signal going to the VGA interface
           VGA_GREEN_O  : out  STD_LOGIC_VECTOR (3 downto 0); -- Green signal going to the VGA interface
           VGA_BLUE_O   : out  STD_LOGIC_VECTOR (3 downto 0); -- Blue signal going to the VGA interface
          
           -- -- Mouse signals
           MOUSE_X_POS :  in std_logic_vector (11 downto 0); -- X position from the mouse
           MOUSE_Y_POS :  in std_logic_vector (11 downto 0); -- Y position from the mouse
           score : out std_logic_vector(3 downto 0)
--        
           );
end Vgaformouseonly;

architecture Behavioral of Vgaformouseonly is

-------------------------------------------------------------------------

-- Component Declarations

-------------------------------------------------------------------------
component WhiteBox is
port (
   pixel_clkWB: in std_logic;
--   xpos     : in std_logic_vector(11 downto 0);
--   ypos     : in std_logic_vector(11 downto 0);

   hcountWB   : in std_logic_vector(11 downto 0);
   vcountWB   : in std_logic_vector(11 downto 0);
   --blank    : in std_logic; -- if VGA blank is used

   --red_in   : in std_logic_vector(3 downto 0); -- if VGA signal pass-through is used
   --green_in : in std_logic_vector(3 downto 0);
   --blue_in  : in std_logic_vector(3 downto 0);
   
   enable_mouse_display_outWB : out std_logic;

   red_outWB  : out std_logic_vector(3 downto 0);
   green_outWB: out std_logic_vector(3 downto 0);
   blue_outWB : out std_logic_vector(3 downto 0)
);
end component;
component CoinDisplay is
port (
   pixel_clk: in std_logic;
--   xpos     : in std_logic_vector(11 downto 0);
--   ypos     : in std_logic_vector(11 downto 0);
enable : in std_logic_vector(3 downto 0);
   hcount   : in std_logic_vector(11 downto 0);
   vcount   : in std_logic_vector(11 downto 0);
   --blank    : in std_logic; -- if VGA blank is used

   --red_in   : in std_logic_vector(3 downto 0); -- if VGA signal pass-through is used
   --green_in : in std_logic_vector(3 downto 0);
   --blue_in  : in std_logic_vector(3 downto 0);
   
   enable_mouse_display_out : out std_logic;

   red_out  : out std_logic_vector(3 downto 0);
   green_out: out std_logic_vector(3 downto 0);
   blue_out : out std_logic_vector(3 downto 0)
);
end component;
component CoinDisplay2 is
port (
   pixel_clk2: in std_logic;
--   xpos     : in std_logic_vector(11 downto 0);
--   ypos     : in std_logic_vector(11 downto 0);
enable2 : in std_logic_vector(3 downto 0);
   hcount2   : in std_logic_vector(11 downto 0);
   vcount2   : in std_logic_vector(11 downto 0);
   --blank    : in std_logic; -- if VGA blank is used

   --red_in   : in std_logic_vector(3 downto 0); -- if VGA signal pass-through is used
   --green_in : in std_logic_vector(3 downto 0);
   --blue_in  : in std_logic_vector(3 downto 0);
   
   enable_mouse_display_out2 : out std_logic;

   red_out2  : out std_logic_vector(3 downto 0);
   green_out2: out std_logic_vector(3 downto 0);
   blue_out2 : out std_logic_vector(3 downto 0)
);
end component;
component CoinDisplay3 is
port (
   pixel_clk3: in std_logic;
   enable3 : in std_logic_vector(3 downto 0);
--   xpos     : in std_logic_vector(11 downto 0);
--   ypos     : in std_logic_vector(11 downto 0);

   hcount3   : in std_logic_vector(11 downto 0);
   vcount3   : in std_logic_vector(11 downto 0);
   --blank    : in std_logic; -- if VGA blank is used

   --red_in   : in std_logic_vector(3 downto 0); -- if VGA signal pass-through is used
   --green_in : in std_logic_vector(3 downto 0);
   --blue_in  : in std_logic_vector(3 downto 0);
   
   enable_mouse_display_out3 : out std_logic;

   red_out3  : out std_logic_vector(3 downto 0);
   green_out3: out std_logic_vector(3 downto 0);
   blue_out3 : out std_logic_vector(3 downto 0)
);
end component;
component CoinDisplay4 is
port (
   pixel_clk4: in std_logic;
   enable4 : in std_logic_vector(3 downto 0);
--   xpos     : in std_logic_vector(11 downto 0);
--   ypos     : in std_logic_vector(11 downto 0);

   hcount4   : in std_logic_vector(11 downto 0);
   vcount4   : in std_logic_vector(11 downto 0);
   --blank    : in std_logic; -- if VGA blank is used

   --red_in   : in std_logic_vector(3 downto 0); -- if VGA signal pass-through is used
   --green_in : in std_logic_vector(3 downto 0);
   --blue_in  : in std_logic_vector(3 downto 0);
   
   enable_mouse_display_out4 : out std_logic;

   red_out4  : out std_logic_vector(3 downto 0);
   green_out4: out std_logic_vector(3 downto 0);
   blue_out4 : out std_logic_vector(3 downto 0)
);
end component;
component CoinDisplay5 is
port (
   pixel_clk5: in std_logic;
   enable5 : in std_logic_vector(3 downto 0);
--   xpos     : in std_logic_vector(11 downto 0);
--   ypos     : in std_logic_vector(11 downto 0);

   hcount5   : in std_logic_vector(11 downto 0);
   vcount5   : in std_logic_vector(11 downto 0);
   --blank    : in std_logic; -- if VGA blank is used

   --red_in   : in std_logic_vector(3 downto 0); -- if VGA signal pass-through is used
   --green_in : in std_logic_vector(3 downto 0);
   --blue_in  : in std_logic_vector(3 downto 0);
   
   enable_mouse_display_out5 : out std_logic;

   red_out5  : out std_logic_vector(3 downto 0);
   green_out5: out std_logic_vector(3 downto 0);
   blue_out5 : out std_logic_vector(3 downto 0)
);
end component;
component CoinDisplay6 is
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
end component;
component CoinDisplay7 is
port (
   pixel_clk7: in std_logic;
   enable7 : in std_logic_vector(3 downto 0);
--   xpos     : in std_logic_vector(11 downto 0);
--   ypos     : in std_logic_vector(11 downto 0);

   hcount7   : in std_logic_vector(11 downto 0);
   vcount7   : in std_logic_vector(11 downto 0);
   --blank    : in std_logic; -- if VGA blank is used

   --red_in   : in std_logic_vector(3 downto 0); -- if VGA signal pass-through is used
   --green_in : in std_logic_vector(3 downto 0);
   --blue_in  : in std_logic_vector(3 downto 0);
   
   enable_mouse_display_out7 : out std_logic;

   red_out7  : out std_logic_vector(3 downto 0);
   green_out7: out std_logic_vector(3 downto 0);
   blue_out7 : out std_logic_vector(3 downto 0)
);
end component;
component CoinDisplay8 is
port (
   pixel_clk8: in std_logic;
   enable8 : in std_logic_vector(3 downto 0);
--   xpos     : in std_logic_vector(11 downto 0);
--   ypos     : in std_logic_vector(11 downto 0);

   hcount8  : in std_logic_vector(11 downto 0);
   vcount8   : in std_logic_vector(11 downto 0);
   --blank    : in std_logic; -- if VGA blank is used

   --red_in   : in std_logic_vector(3 downto 0); -- if VGA signal pass-through is used
   --green_in : in std_logic_vector(3 downto 0);
   --blue_in  : in std_logic_vector(3 downto 0);
   
   enable_mouse_display_out8 : out std_logic;

   red_out8 : out std_logic_vector(3 downto 0);
   green_out8: out std_logic_vector(3 downto 0);
   blue_out8 : out std_logic_vector(3 downto 0)
);
end component;
component CoinDisplay9 is
port (
   pixel_clk9: in std_logic;
   enable9 : in std_logic_vector(3 downto 0);
--   xpos     : in std_logic_vector(11 downto 0);
--   ypos     : in std_logic_vector(11 downto 0);

   hcount9   : in std_logic_vector(11 downto 0);
   vcount9   : in std_logic_vector(11 downto 0);
   --blank    : in std_logic; -- if VGA blank is used

   --red_in   : in std_logic_vector(3 downto 0); -- if VGA signal pass-through is used
   --green_in : in std_logic_vector(3 downto 0);
   --blue_in  : in std_logic_vector(3 downto 0);
   
   enable_mouse_display_out9 : out std_logic;

   red_out9  : out std_logic_vector(3 downto 0);
   green_out9: out std_logic_vector(3 downto 0);
   blue_out9 : out std_logic_vector(3 downto 0)
);
end component;
   -- To generate the 108 MHz Pixel Clock
   -- needed for a resolution of 1280*1024 pixels
   COMPONENT PxlClkGen
   PORT
    (-- Clock in ports
     CLK_IN1           : in std_logic;
     -- Clock out ports
     CLK_OUT1          : out std_logic;
     -- Status and control signals
     LOCKED            : out std_logic
    );
   END COMPONENT;


COMPONENT OverlayCtl is
    Port ( CLK_I : in  STD_LOGIC;
           VSYNC_I : in  STD_LOGIC;
           ACTIVE_I : in  STD_LOGIC;
           OVERLAY_O : out  STD_LOGIC
           );
end COMPONENT; 


   -- Display the Mouse cursor
   COMPONENT MouseDisplay
   PORT (
      pixel_clk: in std_logic;
      xpos     : in std_logic_vector(11 downto 0); -- Mouse cursor X position
      ypos     : in std_logic_vector(11 downto 0); -- Mouse cursor Y position 

      hcount   : in std_logic_vector(11 downto 0);
      vcount   : in std_logic_vector(11 downto 0);
      --blank    : in std_logic; -- blank the screen in overlay mode, here is not used
      
      enable_mouse_display_out : out std_logic; -- When active, the mouse cursor signal is sent to the VGA display
      
      --red_in   : in std_logic_vector(3 downto 0); -- Red, Green and Blue input signal in overlay mode, here are not used
      --green_in : in std_logic_vector(3 downto 0);
      --blue_in  : in std_logic_vector(3 downto 0);
      -- Output Red, blue and Green Signals
      red_out  : out std_logic_vector(3 downto 0);
      green_out: out std_logic_vector(3 downto 0);
      blue_out : out std_logic_vector(3 downto 0)
   );
  END COMPONENT;



--***1280x1024@60Hz***--
constant FRAME_WIDTH : natural := 1280;
constant FRAME_HEIGHT : natural := 1024;

constant H_FP : natural := 48; --H front porch width (pixels)
constant H_PW : natural := 112; --H sync pulse width (pixels)
constant H_MAX : natural := 1688; --H total period (pixels)

constant V_FP : natural := 1; --V front porch width (lines)
constant V_PW : natural := 3; --V sync pulse width (lines)
constant V_MAX : natural := 1066; --V total period (lines)

constant H_POL : std_logic := '1';
constant V_POL : std_logic := '1';



-------------------------------------------------------------------------

-- Signal Declarations

-------------------------------------------------------------------------


-------------------------------------------------------------------------

-- VGA Controller specific signals: Counters, Sync, R, G, B

-------------------------------------------------------------------------
-- Pixel clock, in this case 108 MHz
signal pxl_clk : std_logic;
-- The active signal is used to signal the active region of the screen (when not blank)
signal active  : std_logic;

-- Horizontal and Vertical counters
signal h_cntr_reg : std_logic_vector(11 downto 0) := (others =>'0');
signal v_cntr_reg : std_logic_vector(11 downto 0) := (others =>'0');

-- Pipe Horizontal and Vertical Counters
signal h_cntr_reg_dly   : std_logic_vector(11 downto 0) := (others => '0');
signal v_cntr_reg_dly   : std_logic_vector(11 downto 0) := (others => '0');

-- Horizontal and Vertical Sync
signal h_sync_reg : std_logic := not(H_POL);
signal v_sync_reg : std_logic := not(V_POL);
-- Pipe Horizontal and Vertical Sync
signal h_sync_reg_dly : std_logic := not(H_POL);
signal v_sync_reg_dly : std_logic :=  not(V_POL);

-- VGA R, G and B signals coming from the main multiplexers
signal vga_red_cmb   : std_logic_vector(3 downto 0);
signal vga_green_cmb : std_logic_vector(3 downto 0);
signal vga_blue_cmb  : std_logic_vector(3 downto 0);
--The main VGA R, G and B signals, validated by active
signal vga_red    : std_logic_vector(3 downto 0);
signal vga_green  : std_logic_vector(3 downto 0);
signal vga_blue   : std_logic_vector(3 downto 0);
-- Register VGA R, G and B signals
signal vga_red_reg   : std_logic_vector(3 downto 0) := (others =>'0');
signal vga_green_reg : std_logic_vector(3 downto 0) := (others =>'0');
signal vga_blue_reg  : std_logic_vector(3 downto 0) := (others =>'0');

-------------------------------------------------------------------------

-- Signals for registering the inputs

-------------------------------------------------------------------------
signal RGB_LED_RED_REG     : std_logic_vector (4 downto 0);
signal RGB_LED_BLUE_REG    : std_logic_vector (4 downto 0);
signal RGB_LED_GREEN_REG   : std_logic_vector (4 downto 0);



signal MOUSE_X_POS_REG  : std_logic_vector (11 downto 0);
signal MOUSE_Y_POS_REG  : std_logic_vector (11 downto 0);
signal MOUSE_LEFT_BUTTON_REG : std_logic;

-----------------------------------------------------------
-- Signals for generating the background (moving colorbar)
-----------------------------------------------------------
signal cntDyn				: integer range 0 to 2**28-1; -- counter for generating the colorbar
signal intHcnt				: integer range 0 to H_MAX - 1;
signal intVcnt				: integer range 0 to V_MAX - 1;
-- Colorbar red, greeen and blue signals
signal bg_red 				: std_logic_vector(3 downto 0);
signal bg_blue 			: std_logic_vector(3 downto 0);
signal bg_green 			: std_logic_vector(3 downto 0);
-- Pipe the colorbar red, green and blue signals
signal bg_red_dly			: std_logic_vector(3 downto 0) := (others => '0');
signal bg_green_dly		: std_logic_vector(3 downto 0) := (others => '0');
signal bg_blue_dly		: std_logic_vector(3 downto 0) := (others => '0');




-- Mouse cursor display signals
signal mouse_cursor_red    : std_logic_vector (3 downto 0) := (others => '0');
signal mouse_cursor_blue   : std_logic_vector (3 downto 0) := (others => '0');
signal mouse_cursor_green  : std_logic_vector (3 downto 0) := (others => '0');
-- Mouse cursor enable display signals
signal enable_mouse_display:  std_logic;

-- Overlay display signal
signal overlay_en : std_logic;


-- Registered Mouse cursor display signals
signal mouse_cursor_red_dly   : std_logic_vector (3 downto 0) := (others => '0');
signal mouse_cursor_blue_dly  : std_logic_vector (3 downto 0) := (others => '0');
signal mouse_cursor_green_dly : std_logic_vector (3 downto 0) := (others => '0');
-- Registered Mouse cursor enable display signals
signal enable_mouse_display_dly  :  std_logic;

-- Registered Overlay display signal
signal overlay_en_dly : std_logic;

signal COINS_X_BUFFER: std_logic_vector (107 downto 0);
signal COINS_Y_BUFFER: std_logic_vector (107 downto 0);
signal WBr: std_logic_vector (3 downto 0);
signal WBg: std_logic_vector (3 downto 0);
signal WBb: std_logic_vector (3 downto 0);

signal WB_r1_dly: std_logic_vector(3 downto 0);
signal WB_g1_dly: std_logic_vector(3 downto 0);
signal WB_b1_dly: std_logic_vector(3 downto 0);

--signal for colors for first coin
signal coinr1: std_logic_vector (3 downto 0);
signal coing1: std_logic_vector (3 downto 0);
signal coinb1: std_logic_vector (3 downto 0);

-- display signal for first coin
signal coin_r1_dly: std_logic_vector (3 downto 0);
signal coin_g1_dly: std_logic_vector (3 downto 0);
signal coin_b1_dly: std_logic_vector (3 downto 0);

signal enable_coin_1_dly: std_logic;
signal enable_coin_1: std_logic;

signal coinr2: std_logic_vector (3 downto 0);
signal coing2: std_logic_vector (3 downto 0);
signal coinb2: std_logic_vector (3 downto 0);

-- display signal for first coin
signal coin_r2_dly: std_logic_vector (3 downto 0);
signal coin_g2_dly: std_logic_vector (3 downto 0);
signal coin_b2_dly: std_logic_vector (3 downto 0);

signal enable_coin_2_dly: std_logic;
signal enable_coin_2: std_logic;

signal coinr3: std_logic_vector (3 downto 0);
signal coing3: std_logic_vector (3 downto 0);
signal coinb3: std_logic_vector (3 downto 0);

-- display signal for first coin
signal coin_r3_dly: std_logic_vector (3 downto 0);
signal coin_g3_dly: std_logic_vector (3 downto 0);
signal coin_b3_dly: std_logic_vector (3 downto 0);

signal enable_coin_3_dly: std_logic;
signal enable_coin_3: std_logic;

signal coinr4: std_logic_vector (3 downto 0);
signal coing4: std_logic_vector (3 downto 0);
signal coinb4: std_logic_vector (3 downto 0);

-- display signal for first coin
signal coin_r4_dly: std_logic_vector (3 downto 0);
signal coin_g4_dly: std_logic_vector (3 downto 0);
signal coin_b4_dly: std_logic_vector (3 downto 0);

signal enable_coin_4_dly: std_logic;
signal enable_coin_4: std_logic;

signal coinr5: std_logic_vector (3 downto 0);
signal coing5: std_logic_vector (3 downto 0);
signal coinb5: std_logic_vector (3 downto 0);

-- display signal for first coin
signal coin_r5_dly: std_logic_vector (3 downto 0);
signal coin_g5_dly: std_logic_vector (3 downto 0);
signal coin_b5_dly: std_logic_vector (3 downto 0);

signal enable_coin_5_dly: std_logic;
signal enable_coin_5: std_logic;

signal coinr6: std_logic_vector (3 downto 0);
signal coing6: std_logic_vector (3 downto 0);
signal coinb6: std_logic_vector (3 downto 0);

-- display signal for first coin
signal coin_r6_dly: std_logic_vector (3 downto 0);
signal coin_g6_dly: std_logic_vector (3 downto 0);
signal coin_b6_dly: std_logic_vector (3 downto 0);

signal enable_coin_6_dly: std_logic;
signal enable_coin_6: std_logic;

signal coinr7: std_logic_vector (3 downto 0);
signal coing7: std_logic_vector (3 downto 0);
signal coinb7: std_logic_vector (3 downto 0);

-- display signal for first coin
signal coin_r7_dly: std_logic_vector (3 downto 0);
signal coin_g7_dly: std_logic_vector (3 downto 0);
signal coin_b7_dly: std_logic_vector (3 downto 0);

signal enable_coin_7_dly: std_logic;
signal enable_coin_7: std_logic;

signal coinr8: std_logic_vector (3 downto 0);
signal coing8: std_logic_vector (3 downto 0);
signal coinb8: std_logic_vector (3 downto 0);

-- display signal for first coin
signal coin_r8_dly: std_logic_vector (3 downto 0);
signal coin_g8_dly: std_logic_vector (3 downto 0);
signal coin_b8_dly: std_logic_vector (3 downto 0);

signal enable_coin_8_dly: std_logic;
signal enable_coin_8: std_logic;

signal coinr9: std_logic_vector (3 downto 0);
signal coing9: std_logic_vector (3 downto 0);
signal coinb9: std_logic_vector (3 downto 0);

-- display signal for first coin
signal coin_r9_dly: std_logic_vector (3 downto 0);
signal coin_g9_dly: std_logic_vector (3 downto 0);
signal coin_b9_dly: std_logic_vector (3 downto 0);

signal enable_coin_9_dly: std_logic;
signal enable_coin_9: std_logic;
signal enable_WB_dly: std_logic;
signal enable_WB: std_logic;
signal C1enable : std_logic_vector(3 downto 0) := "0001";
signal C2enable : std_logic_vector(3 downto 0) := "0001";
signal C3enable : std_logic_vector(3 downto 0) := "0001";
signal C4enable : std_logic_vector(3 downto 0) := "0001";
signal C5enable : std_logic_vector(3 downto 0) := "0001";
signal C6enable : std_logic_vector(3 downto 0) := "0001";
signal C7enable : std_logic_vector(3 downto 0) := "0001";
signal C8enable : std_logic_vector(3 downto 0) := "0001";
signal C9enable : std_logic_vector(3 downto 0) := "0001";

signal scorecount: std_logic_vector(3 downto 0) := "0000";
signal scre : std_logic_vector(3 downto 0) := "0000";
signal cnt: integer := 0;
signal cnt1: integer := 0;
begin

process (MOUSE_X_POS, MOUSE_Y_POS, CLK_I, cnt)
begin
if (MOUSE_X_POS = "010001111110" and MOUSE_Y_POS = "000001110011") then
C1enable <= "0000";
end if;
if (MOUSE_X_POS = "000111101010" and MOUSE_Y_POS = "001110111011") then 
C2enable <= "0000";
end if;
if (MOUSE_X_POS = "001001100010" and MOUSE_Y_POS = "000011101011") then 
C3enable <= "0000";
end if;
if (MOUSE_X_POS = "000001000110" and MOUSE_Y_POS = "000010101111") then 
C4enable <= "0000";
end if;
if (MOUSE_X_POS = "000100110110" and MOUSE_Y_POS = "000101100011") then 
C5enable <= "0000";
end if;
if (MOUSE_X_POS = "000111101010" and MOUSE_Y_POS = "000111011011") then 
C6enable <= "0000";
end if;
if (MOUSE_X_POS = "001011011010" and MOUSE_Y_POS = "001011001011") then 
C7enable <= "0000";
end if;
if (MOUSE_X_POS = "010001000010" and MOUSE_Y_POS = "001110111011") then 
C8enable <= "0000";
end if;
if (MOUSE_X_POS = "010000000110" and MOUSE_Y_POS = "001000010111") then 
C9enable <= "0000";
end if;
if CLK_I'event and CLK_I = '1' then
cnt <= cnt + 1;
end if;
if cnt = 400000000 then
if C1enable = "0001" then
C1enable <= "0000";
cnt1 <= cnt1 + 1;
end if;
if C5enable = "0001" then
C5enable <= "0000";
cnt1 <= cnt1 + 1;
end if;
if C8enable = "0001" then
C8enable <= "0000";
cnt1 <= cnt1 + 1;
end if;
end if;
if cnt = 600000000 then
if C2enable = "0001" then
C2enable <= "0000";
cnt1 <= cnt1 + 1;
end if;
if C4enable = "0001" then
C4enable <= "0000";
cnt1 <= cnt1 + 1;
end if;
if C9enable = "0001" then
C9enable <= "0000";
cnt1 <= cnt1 + 1;
end if;
end if;
if cnt = 900000000 then
if C3enable = "0001" then
C3enable <= "0000";
cnt1 <= cnt1 + 1;
end if;
if C6enable = "0001" then
C6enable <= "0000";
cnt1 <= cnt1 + 1;
end if; 
if C7enable = "0001" then
C7enable <= "0000";
cnt1 <= cnt1 + 1;
end if;
end if;

if cnt1 = 0 then 
scre <= "0000";
end if;
if cnt1 = 1 then 
scre <= "0001";
end if;
if cnt1 = 2 then
scre <= "0010";
end if;
if cnt1 = 3 then
scre <= "0011";
end if;
if cnt1 = 4 then
scre <= "0100"; 
end if;
if cnt1 = 5 then
scre <= "0101";
end if;
if cnt1 = 6 then
scre <= "0110";
end if;
if cnt1 = 7 then
scre <= "0111";
end if;
if cnt1 = 8 then
scre <= "1000";
end if;
if cnt1 = 9 then 
scre <= "1001";
end if;

end process;


scorecount <= C1enable + C2enable + C3enable + C4enable + C5enable + C6enable + C7enable + C8enable + C9enable + scre;

process (scorecount) 
begin
if scorecount > "1001" then
score <= "0000";
end if;
if scorecount = "1001" then
score <= "0000";
end if;
if scorecount = "1000" then
score <= "0001";
end if;
if scorecount = "0111" then
score <= "0010";
end if;
if scorecount = "0110" then
score <= "0011";
end if;
if scorecount = "0101" then
score <= "0100";
end if;
if scorecount = "0100" then
score <= "0101";
end if;
if scorecount = "0011" then
score <= "0110";
end if;
if scorecount = "0010" then
score <= "0111";
end if;
if scorecount = "0001" then
score <= "1000";
end if;
if scorecount = "0000" then
score <= "1001";
end if;

end process;
Inst_WB: WhiteBox
port map (
   pixel_clkWB => pxl_clk,

   hcountWB  => h_cntr_reg,
   vcountWB  => v_cntr_reg,

   
   enable_mouse_display_outWB => enable_WB,

   red_outWB => WBr,
   green_outWB => WBg,
   blue_outWB => WBb
);
    Inst_Coin_1: CoinDisplay
    port map(
   pixel_clk => pxl_clk,
--       xpos     => COINS_X_BUFFER(11 downto 0),
--       ypos     => COINS_Y_BUFFER(11 downto 0),
    enable => C1enable,
       hcount   => h_cntr_reg,
       vcount   => v_cntr_reg,
       --blank    : in std_logic; -- if VGA blank is used
    
       --red_in   : in std_logic_vector(3 downto 0); -- if VGA signal pass-through is used
       --green_in : in std_logic_vector(3 downto 0);
       --blue_in  : in std_logic_vector(3 downto 0);
       
       enable_mouse_display_out => enable_coin_1,
    
       red_out => coinr1,
       green_out => coing1,
       blue_out => coinb1
       );
    Inst_Coin_2:CoinDisplay2
    port map(
       pixel_clk2 => pxl_clk,
       enable2 => C2enable,
--           xpos     => COINS_X_BUFFER(23 downto 12),
--           ypos     => COINS_Y_BUFFER(23 downto 12),
        
           hcount2   => h_cntr_reg,
           vcount2  => v_cntr_reg,
           --blank    : in std_logic; -- if VGA blank is used
        
           --red_in   : in std_logic_vector(3 downto 0); -- if VGA signal pass-through is used
           --green_in : in std_logic_vector(3 downto 0);
           --blue_in  : in std_logic_vector(3 downto 0);
           
           enable_mouse_display_out2 => enable_coin_2,
        
           red_out2 => coinr2,
           green_out2 => coing2,
           blue_out2 => coinb2
           );
    Inst_Coin_3:CoinDisplay3
    port map(
       pixel_clk3 => pxl_clk,
       enable3 => C3enable,
--           xpos     => COINS_X_BUFFER(35 downto 24),
--           ypos     => COINS_Y_BUFFER(35 downto 24),
        
           hcount3   => h_cntr_reg,
           vcount3   => v_cntr_reg,
           --blank    : in std_logic; -- if VGA blank is used
        
           --red_in   : in std_logic_vector(3 downto 0); -- if VGA signal pass-through is used
           --green_in : in std_logic_vector(3 downto 0);
           --blue_in  : in std_logic_vector(3 downto 0);
           
           enable_mouse_display_out3 => enable_coin_3,
        
           red_out3 => coinr3,
           green_out3 => coing3,
           blue_out3 => coinb3
           );
    Inst_Coin_4:CoinDisplay4
    port map(
       pixel_clk4 => pxl_clk,
       enable4 => C4enable,
--           xpos     => COINS_X_BUFFER(47 downto 36),
--           ypos     => COINS_Y_BUFFER(47 downto 36),
        
           hcount4   => h_cntr_reg,
           vcount4   => v_cntr_reg,
           --blank    : in std_logic; -- if VGA blank is used
        
           --red_in   : in std_logic_vector(3 downto 0); -- if VGA signal pass-through is used
           --green_in : in std_logic_vector(3 downto 0);
           --blue_in  : in std_logic_vector(3 downto 0);
           
           enable_mouse_display_out4 => enable_coin_4,
        
           red_out4 => coinr4,
           green_out4 => coing4,
           blue_out4 => coinb4
           );
    Inst_Coin_5:CoinDisplay5
    port map(
       pixel_clk5 => pxl_clk,
       enable5 => C5enable,
--           xpos     => COINS_X_BUFFER(59 downto 48),
--           ypos     => COINS_Y_BUFFER(59 downto 48),
        
           hcount5   => h_cntr_reg,
           vcount5   => v_cntr_reg,
           --blank    : in std_logic; -- if VGA blank is used
        
           --red_in   : in std_logic_vector(3 downto 0); -- if VGA signal pass-through is used
           --green_in : in std_logic_vector(3 downto 0);
           --blue_in  : in std_logic_vector(3 downto 0);
           
           enable_mouse_display_out5 => enable_coin_5,
        
           red_out5 => coinr5,
           green_out5 => coing5,
           blue_out5 => coinb5
           );
    Inst_Coin_6:CoinDisplay6
    port map(
       pixel_clk6 => pxl_clk,
       enable6 => C6enable,
--           xpos     => COINS_X_BUFFER(71 downto 60),
--           ypos     => COINS_Y_BUFFER(71 downto 60),
        
           hcount6   => h_cntr_reg,
           vcount6  => v_cntr_reg,
           --blank    : in std_logic; -- if VGA blank is used
        
           --red_in   : in std_logic_vector(3 downto 0); -- if VGA signal pass-through is used
           --green_in : in std_logic_vector(3 downto 0);
           --blue_in  : in std_logic_vector(3 downto 0);
           
           enable_mouse_display_out6 => enable_coin_6,
        
           red_out6 => coinr6,
           green_out6 => coing6,
           blue_out6 => coinb6
           );
    Inst_Coin_7:CoinDisplay7
    port map(
       pixel_clk7 => pxl_clk,
       enable7 => C7enable,
--           xpos     => COINS_X_BUFFER(83 downto 72),
--           ypos     => COINS_Y_BUFFER(83 downto 72),
        
           hcount7   => h_cntr_reg,
           vcount7   => v_cntr_reg,
           --blank    : in std_logic; -- if VGA blank is used
        
           --red_in   : in std_logic_vector(3 downto 0); -- if VGA signal pass-through is used
           --green_in : in std_logic_vector(3 downto 0);
           --blue_in  : in std_logic_vector(3 downto 0);
           
           enable_mouse_display_out7 => enable_coin_7,
        
           red_out7 => coinr7,
           green_out7 => coing7,
           blue_out7 => coinb7
           );
    Inst_Coin_8:CoinDisplay8
    port map(
       pixel_clk8 => pxl_clk,
       enable8 => C8enable,
--           xpos     => COINS_X_BUFFER(95 downto 84),
--           ypos     => COINS_Y_BUFFER(95 downto 84),
        
           hcount8   => h_cntr_reg,
           vcount8   => v_cntr_reg,
           --blank    : in std_logic; -- if VGA blank is used
        
           --red_in   : in std_logic_vector(3 downto 0); -- if VGA signal pass-through is used
           --green_in : in std_logic_vector(3 downto 0);
           --blue_in  : in std_logic_vector(3 downto 0);
           
           enable_mouse_display_out8 => enable_coin_8,
        
           red_out8 => coinr8,
           green_out8 => coing8,
           blue_out8 => coinb8
           );
    Inst_Coin_9: CoinDisplay9
    port map(
       pixel_clk9 => pxl_clk,
       enable9 => C9enable,
--           xpos     => COINS_X_BUFFER(107 downto 96),
--           ypos     => COINS_Y_BUFFER(107 downto 96),
        
           hcount9   => h_cntr_reg,
           vcount9   => v_cntr_reg,
           --blank    : in std_logic; -- if VGA blank is used
        
           --red_in   : in std_logic_vector(3 downto 0); -- if VGA signal pass-through is used
           --green_in : in std_logic_vector(3 downto 0);
           --blue_in  : in std_logic_vector(3 downto 0);
           
           enable_mouse_display_out9 => enable_coin_9,
        
           red_out9 => coinr9,
           green_out9 => coing9,
           blue_out9 => coinb9
           );
    
  
------------------------------------

-- Generate the 108 MHz pixel clock 

------------------------------------
   Inst_PxlClkGen: PxlClkGen
   port map
    (-- Clock in ports
     CLK_IN1   => CLK_I,
     -- Clock out ports
     CLK_OUT1  => pxl_clk,
     -- Status and control signals
     LOCKED   => open
    );

---------------------------------------------------------------

-- Generate Horizontal, Vertical counters and the Sync signals

---------------------------------------------------------------
                                                                                                                                                                                                                                                                                                                                                                        
  -- Horizontal counter
  process (pxl_clk)
  begin
    if (rising_edge(pxl_clk)) then
      if (h_cntr_reg = (H_MAX - 1)) then
        h_cntr_reg <= (others =>'0');
      else
        h_cntr_reg <= h_cntr_reg + 1;
      end if;
    end if;
  end process;
  -- Vertical counter
  process (pxl_clk)
  begin
    if (rising_edge(pxl_clk)) then
      if ((h_cntr_reg = (H_MAX - 1)) and (v_cntr_reg = (V_MAX - 1))) then
        v_cntr_reg <= (others =>'0');
      elsif (h_cntr_reg = (H_MAX - 1)) then
        v_cntr_reg <= v_cntr_reg + 1;
      end if;
    end if;
  end process;
  -- Horizontal sync
  process (pxl_clk)
  begin
    if (rising_edge(pxl_clk)) then
      if (h_cntr_reg >= (H_FP + FRAME_WIDTH - 1)) and (h_cntr_reg < (H_FP + FRAME_WIDTH + H_PW - 1)) then
        h_sync_reg <= H_POL;
      else
        h_sync_reg <= not(H_POL);
      end if;
    end if;
  end process;
  -- Vertical sync
  process (pxl_clk)
  begin
    if (rising_edge(pxl_clk)) then
      if (v_cntr_reg >= (V_FP + FRAME_HEIGHT - 1)) and (v_cntr_reg < (V_FP + FRAME_HEIGHT + V_PW - 1)) then
        v_sync_reg <= V_POL;
      else
        v_sync_reg <= not(V_POL);
      end if;
    end if;
  end process;
  
--------------------

-- The active 

--------------------  
  -- active signal
  active <= '1' when h_cntr_reg_dly < FRAME_WIDTH and v_cntr_reg_dly < FRAME_HEIGHT
            else '0';

--------------------

-- Register Inputs

--------------------
register_inputs: process (pxl_clk, v_sync_reg)
  begin
    if (rising_edge(pxl_clk)) then
      if v_sync_reg = V_POL then -- All of the signals, except the incoming microphone data 

         
         
         MOUSE_X_POS_REG <= MOUSE_X_POS;
         MOUSE_Y_POS_REG <= MOUSE_Y_POS;
         MOUSE_LEFT_BUTTON_REG <= MOUSE_LEFT_BUTTON_REG;
      end if;   
      -- Incoming Microphone data rate is faster than VSYNC, therefore is registered on the pixel clock
  --    MIC_M_DATA_I_REG <= MIC_M_DATA_I;
    end if;
end process register_inputs;




    

----------------------------------

-- Mouse Cursor display instance

----------------------------------
   Inst_MouseDisplay: MouseDisplay
   PORT MAP 
   (
      pixel_clk   => pxl_clk,
      xpos        => MOUSE_X_POS_REG, 
      ypos        => MOUSE_Y_POS_REG,
      hcount      => h_cntr_reg,
      vcount      => v_cntr_reg,
      enable_mouse_display_out  => enable_mouse_display,
      red_out     => mouse_cursor_red,
      green_out   => mouse_cursor_green,
      blue_out    => mouse_cursor_blue
   );

----------------------------------

-- Overlay display instance

----------------------------------
    	Inst_OverlayCtrl: OverlayCtl 
      PORT MAP
      (
		CLK_I       => pxl_clk,
		VSYNC_I     => v_sync_reg,
		ACTIVE_I    => active,
		OVERLAY_O   => overlay_en
      );
  
  
---------------------------------------

-- Generate moving colorbar background

---------------------------------------

	process(pxl_clk)
	begin
		if(rising_edge(pxl_clk)) then
			cntdyn <= cntdyn + 1;
		end if;
	end process;
   
  	intHcnt <= conv_integer(h_cntr_reg);
	intVcnt <= conv_integer(v_cntr_reg);
	
	bg_red <= conv_std_logic_vector((-intvcnt - inthcnt - cntDyn/2**20),8)(7 downto 4);
	bg_green <= conv_std_logic_vector((inthcnt - cntDyn/2**20),8)(7 downto 4);
	bg_blue <= conv_std_logic_vector((intvcnt - cntDyn/2**20),8)(7 downto 4);
   



---------------------------------------------------------------------------------------------------

-- Register Outputs coming from the displaying components and the horizontal and vertical counters

---------------------------------------------------------------------------------------------------
  process (pxl_clk)
  begin
    if (rising_edge(pxl_clk)) then
   
     
      
       bg_red_dly			<= bg_red;
		 bg_green_dly		<= bg_green;
		 bg_blue_dly			<= bg_blue;
    
    WB_r1_dly <= WBr;
    WB_g1_dly <= WBg;
    WB_b1_dly <= WBb;
    enable_WB_dly <= enable_WB;
    
    coin_r1_dly <= coinr1;
    coin_g1_dly <= coing1;
    coin_b1_dly <= coinb1;
    enable_coin_1_dly <= enable_coin_1;
    
    coin_r2_dly <= coinr2;
    coin_g2_dly <= coing2;
    coin_b2_dly <= coinb2;
    enable_coin_2_dly <= enable_coin_2;
        
    coin_r3_dly <= coinr3;
    coin_g3_dly <= coing3;
    coin_b3_dly <= coinb3;
    enable_coin_3_dly <= enable_coin_3;
    
    coin_r4_dly <= coinr4;
    coin_g4_dly <= coing4;
    coin_b4_dly <= coinb4;
    enable_coin_4_dly <= enable_coin_4;
    
   coin_r5_dly <= coinr5;
    coin_g5_dly <= coing5;
    coin_b5_dly <= coinb5;
    enable_coin_5_dly <= enable_coin_5;
    
    coin_r6_dly <= coinr6;
    coin_g6_dly <= coing6;
    coin_b6_dly <= coinb6;
    enable_coin_6_dly <= enable_coin_6;
    
     coin_r8_dly <= coinr8;
    coin_g8_dly <= coing8;
    coin_b8_dly <= coinb8;
    enable_coin_8_dly <= enable_coin_8;
    
    coin_r7_dly <= coinr7;
    coin_g7_dly <= coing7;
    coin_b7_dly <= coinb7;
    enable_coin_7_dly <= enable_coin_7;
    
      coin_r9_dly <= coinr9;
    coin_g9_dly <= coing9;
    coin_b9_dly <= coinb9;
    enable_coin_9_dly <= enable_coin_9;
      
        
      mouse_cursor_red_dly    <= mouse_cursor_red;
      mouse_cursor_blue_dly   <= mouse_cursor_blue;
      mouse_cursor_green_dly  <= mouse_cursor_green;

      enable_mouse_display_dly   <= enable_mouse_display;

      overlay_en_dly <= overlay_en;
      
      h_cntr_reg_dly <= h_cntr_reg;
		v_cntr_reg_dly <= v_cntr_reg;
      
      
    end if;
  end process;


-------------------------------------------------------------

-- Main Multiplexers for the VGA Red, Green and Blue signals

-------------------------------------------------------------
----------
-- Red
----------

  vga_red <=   -- Mouse_cursor_display is on the top of others
               mouse_cursor_red_dly when enable_mouse_display_dly = '1'
               else
               -- Overlay display is black 
               x"0" when overlay_en_dly = '1'
            
      
                
               else
                --coin1 
                coin_r1_dly when enable_coin_1_dly = '1'
                else
                --coin2 
                coin_r2_dly when enable_coin_2_dly = '1'
                else
                --coin3 
                coin_r3_dly when enable_coin_3_dly = '1'
                else
                --coin4 
                coin_r4_dly when enable_coin_4_dly = '1'
                else
                --coin4 
                coin_r4_dly when enable_coin_4_dly = '1'
                else
                --coin5 
                coin_r5_dly when enable_coin_5_dly = '1'
                 else
                --coin6 
                coin_r6_dly when enable_coin_6_dly = '1'
                else
                --coin1 
                coin_r7_dly when enable_coin_7_dly = '1'
                 else
                --coin1 
                coin_r8_dly when enable_coin_8_dly = '1'
                else
                --coin1 
                coin_r9_dly when enable_coin_9_dly = '1'
                
--                else
                -- Accelerometer display   
--                acl_red_dly when h_cntr_reg_dly > ACL_LEFT and h_cntr_reg_dly < ACL_RIGHT 
--                             and v_cntr_reg_dly > ACL_TOP and v_cntr_reg_dly < ACL_BOTTOM
                 else 
              WB_r1_dly when enable_WB_dly ='1'
               else
               -- Colorbar will be on the backround
               bg_red_dly;
                
-----------
-- Green
-----------

  vga_green <= -- Mouse_cursor_display is on the top of others
               mouse_cursor_green_dly when enable_mouse_display_dly = '1'
               else
               -- Overlay display is black 
               x"0" when overlay_en_dly = '1'
         
                           
               else
              --coin1 
              coin_g1_dly when enable_coin_1_dly = '1'
              else
              --coin2 
              coin_g2_dly when enable_coin_2_dly = '1'
              else
              --coin3 
              coin_g3_dly when enable_coin_3_dly = '1'
              else
              --coin4 
              coin_g4_dly when enable_coin_4_dly = '1'
              else
              --coin4 
              coin_g4_dly when enable_coin_4_dly = '1'
              else
              --coin5 
              coin_g5_dly when enable_coin_5_dly = '1'
               else
              --coin6 
              coin_g6_dly when enable_coin_6_dly = '1'
              else
              --coin1 
              coin_g7_dly when enable_coin_7_dly = '1'
               else
              --coin1 
              coin_g8_dly when enable_coin_8_dly = '1'
              else
              --coin1 
              coin_g9_dly when enable_coin_9_dly = '1'
                
--                else
--                -- Accelerometer display
--                acl_green_dly when h_cntr_reg_dly > ACL_LEFT and h_cntr_reg_dly < ACL_RIGHT 
--                               and v_cntr_reg_dly > ACL_TOP and v_cntr_reg_dly < ACL_BOTTOM
 else 
                                            WB_g1_dly when enable_WB_dly ='1'
               else
               -- Colorbar will be on the backround
               bg_green_dly;

-----------
-- Blue
-----------

  vga_blue <=  -- Mouse_cursor_display is on the top of others
               mouse_cursor_blue_dly when enable_mouse_display_dly = '1'
               else
               -- Overlay display is black 
               x"0" when overlay_en_dly = '1'
        
                             
               else
                 --coin1 
                 coin_b1_dly when enable_coin_1_dly = '1'
                 else
                 --coin2 
                 coin_b2_dly when enable_coin_2_dly = '1'
                 else
                 --coin3 
                 coin_b3_dly when enable_coin_3_dly = '1'
                 else
                 --coin4 
                 coin_b4_dly when enable_coin_4_dly = '1'
                 else
                 --coin4 
                 coin_b4_dly when enable_coin_4_dly = '1'
                 else
                 --coin5 
                 coin_b5_dly when enable_coin_5_dly = '1'
                  else
                 --coin6 
                 coin_b6_dly when enable_coin_6_dly = '1'
                 else
                 --coin1 
                 coin_b7_dly when enable_coin_7_dly = '1'
                  else
                 --coin1 
                 coin_b8_dly when enable_coin_8_dly = '1'
                 else
                 --coin1 
                 coin_b9_dly when enable_coin_9_dly = '1'
                    else 
                                                                                     WB_b1_dly when enable_WB_dly ='1'
               
--                else
--                -- Accelerometer display
--                acl_blue_dly when h_cntr_reg_dly > ACL_LEFT and h_cntr_reg_dly < ACL_RIGHT 
--                              and v_cntr_reg_dly > ACL_TOP and v_cntr_reg_dly < ACL_BOTTOM
               else
               -- Colorbar will be on the backround
               bg_blue_dly;
                

------------------------------------------------------------
-- Turn Off VGA RBG Signals if outside of the active screen
-- Make a 4-bit AND logic with the R, G and B signals
------------------------------------------------------------
 vga_red_cmb <= (active & active & active & active) and vga_red;
 vga_green_cmb <= (active & active & active & active) and vga_green;
 vga_blue_cmb <= (active & active & active & active) and vga_blue;
 

 -- Register Outputs
  process (pxl_clk)
  begin
    if (rising_edge(pxl_clk)) then

      v_sync_reg_dly <= v_sync_reg;
      h_sync_reg_dly <= h_sync_reg;
      vga_red_reg    <= vga_red_cmb;
      vga_green_reg  <= vga_green_cmb;
      vga_blue_reg   <= vga_blue_cmb;      
    end if;
  end process;

  -- Assign outputs
--  COINS_X_BUFFER <= COINS_X_POS;
--  COINS_Y_BUFFER <= COINS_Y_POS;
  VGA_HS_O     <= h_sync_reg_dly;
  VGA_VS_O     <= v_sync_reg_dly;
  VGA_RED_O    <= vga_red_reg;
  VGA_GREEN_O  <= vga_green_reg;
  VGA_BLUE_O   <= vga_blue_reg;

end Behavioral;
