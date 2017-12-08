// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.2 (win64) Build 1909853 Thu Jun 15 18:39:09 MDT 2017
// Date        : Fri Dec  1 02:44:39 2017
// Host        : E8WLAB5133 running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ ClkGen_stub.v
// Design      : ClkGen
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix(clk_100MHz_o, clk_200MHz_o, reset_i, locked_o, 
  clk_100MHz_i)
/* synthesis syn_black_box black_box_pad_pin="clk_100MHz_o,clk_200MHz_o,reset_i,locked_o,clk_100MHz_i" */;
  output clk_100MHz_o;
  output clk_200MHz_o;
  input reset_i;
  output locked_o;
  input clk_100MHz_i;
endmodule
