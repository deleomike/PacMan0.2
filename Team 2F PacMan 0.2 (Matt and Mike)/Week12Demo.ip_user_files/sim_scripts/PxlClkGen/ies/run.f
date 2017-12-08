-makelib ies/xil_defaultlib -sv \
  "C:/Xilinx/Vivado/2017.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
-endlib
-makelib ies/xpm \
  "C:/Xilinx/Vivado/2017.2/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies/xil_defaultlib \
  "../../../../Week12Demo.srcs/sources_1/ip/PxlClkGen/PxlClkGen_clk_wiz.v" \
  "../../../../Week12Demo.srcs/sources_1/ip/PxlClkGen/PxlClkGen.v" \
-endlib
-makelib ies/xil_defaultlib \
  glbl.v
-endlib

