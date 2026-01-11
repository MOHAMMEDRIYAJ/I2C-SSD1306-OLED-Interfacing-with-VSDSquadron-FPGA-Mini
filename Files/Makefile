# Top-level module name
TOP = OLED

# Constraint file
PCF = constraints.pcf

# Source files (NO simulation stubs here)
SRC = OLED.v I2C.v

all: build

build:
	yosys -p "read_verilog $(SRC); synth_ice40 -top $(TOP) -json $(TOP).json"
	nextpnr-ice40 --up5k --package sg48 --json $(TOP).json --pcf $(PCF) --asc $(TOP).asc
	icepack $(TOP).asc $(TOP).bin

flash:
	iceprog $(TOP).bin

clean:
	rm -f *.json *.asc *.bin

