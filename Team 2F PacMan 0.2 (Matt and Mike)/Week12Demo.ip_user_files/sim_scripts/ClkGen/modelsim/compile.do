vlib work
vlib msim

vlib msim/xil_defaultlib
vlib msim/xpm

vmap xil_defaultlib msim/xil_defaultlib
vmap xpm msim/xpm

vlog -work xil_defaultlib -64 -incr -sv "+incdir+../../../../Week12Demo.srcs/sources_1/ip/ClkGen" "+incdir+../../../../Week12Demo.srcs/sources_1/ip/PxlClkGen" "+incdir+../../../../Week12Demo.srcs/sources_1/ip/ClkGen" "+incdir+../../../../Week12Demo.srcs/sources_1/ip/PxlClkGen" \
"C:/Xilinx/Vivado/2017.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm -64 -93 \
"C:/Xilinx/Vivado/2017.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib -64 -incr "+incdir+../../../../Week12Demo.srcs/sources_1/ip/ClkGen" "+incdir+../../../../Week12Demo.srcs/sources_1/ip/PxlClkGen" "+incdir+../../../../Week12Demo.srcs/sources_1/ip/ClkGen" "+incdir+../../../../Week12Demo.srcs/sources_1/ip/PxlClkGen" \
"../../../../Week12Demo.srcs/sources_1/ip/ClkGen/ClkGen_clk_wiz.v" \
"../../../../Week12Demo.srcs/sources_1/ip/ClkGen/ClkGen.v" \

vlog -work xil_defaultlib \
"glbl.v"

