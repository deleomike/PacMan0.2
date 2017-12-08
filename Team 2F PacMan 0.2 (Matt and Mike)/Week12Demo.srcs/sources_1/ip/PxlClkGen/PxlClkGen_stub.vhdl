-- Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2017.2 (win64) Build 1909853 Thu Jun 15 18:39:09 MDT 2017
-- Date        : Wed Nov  8 18:26:47 2017
-- Host        : E8WLAB5130 running 64-bit Service Pack 1  (build 7601)
-- Command     : write_vhdl -force -mode synth_stub {P:/Private/Documents/CMPEN
--               371/Week12Demo/Week12Demo.srcs/sources_1/ip/PxlClkGen/PxlClkGen_stub.vhdl}
-- Design      : PxlClkGen
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a100tcsg324-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PxlClkGen is
  Port ( 
    CLK_OUT1 : out STD_LOGIC;
    LOCKED : out STD_LOGIC;
    CLK_IN1 : in STD_LOGIC
  );

end PxlClkGen;

architecture stub of PxlClkGen is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "CLK_OUT1,LOCKED,CLK_IN1";
begin
end;
