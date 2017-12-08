onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib PxlClkGen_opt

do {wave.do}

view wave
view structure
view signals

do {PxlClkGen.udo}

run -all

quit -force
