vlib work
vlib riviera

vlib riviera/xil_defaultlib
vlib riviera/xpm

vmap xil_defaultlib riviera/xil_defaultlib
vmap xpm riviera/xpm

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../../Week12Demo.srcs/sources_1/ip/ClkGen" "+incdir+../../../../Week12Demo.srcs/sources_1/ip/PxlClkGen" "+incdir+../../../../Week12Demo.srcs/sources_1/ip/ClkGen" "+incdir+../../../../Week12Demo.srcs/sources_1/ip/PxlClkGen" \
"C:/Xilinx/Vivado/2017.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm -93 \
"C:/Xilinx/Vivado/2017.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../Week12Demo.srcs/sources_1/ip/ClkGen" "+incdir+../../../../Week12Demo.srcs/sources_1/ip/PxlClkGen" "+incdir+../../../../Week12Demo.srcs/sources_1/ip/ClkGen" "+incdir+../../../../Week12Demo.srcs/sources_1/ip/PxlClkGen" \
"../../../../Week12Demo.srcs/sources_1/ip/ClkGen/ClkGen_clk_wiz.v" \
"../../../../Week12Demo.srcs/sources_1/ip/ClkGen/ClkGen.v" \

vlog -work xil_defaultlib \
"glbl.v"

