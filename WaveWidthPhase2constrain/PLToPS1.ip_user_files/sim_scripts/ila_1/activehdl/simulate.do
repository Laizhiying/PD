onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+ila_1 -L xil_defaultlib -L xpm -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.ila_1 xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {ila_1.udo}

run -all

endsim

quit -force
