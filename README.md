# ⚙️ OLED 1306 I2C DISPLAY WITH VSD SQUADRON FM 


## 📌 Project Overview

This project demonstrates the implementation of the Inter-Integrated Circuit (I²C) communication protocol using Verilog HDL on the **VSD Squadron FM** development board to interface with a **0.96-inch SSD1306-based OLED display (128×64 resolution)**. I²C is a widely used serial communication protocol that enables efficient data transfer between digital devices using only two signal lines: Serial Data (SDA) and Serial Clock (SCL).

 As a demonstration, a **World map and the VSD** are rendered on the OLED display. This project serves as a practical example of FPGA-based peripheral interfacing and digital system design, making it suitable for academic learning and hands-on hardware development.


<img src="https://github.com/MOHAMMEDRIYAJ/OLED-1306-I2C-with-VSQUADRON-FM-/blob/main/Images/VSD.jpeg" width="90%" height="90%">


## Key Features

- **Fully Synthesizable FPGA-Based I²C Master**  
  Implements the complete I²C protocol in Verilog HDL, including start/stop generation, slave addressing, and byte-level data transfer, without using any external microcontroller.

- **SSD1306-Compliant OLED Control**  
  Correctly initializes and drives a 0.96-inch 128×64 SSD1306 OLED display using the I²C control byte mechanism to distinguish between command and display data.

- **On-Chip Graphics Rendering**  
  Displays predefined monochrome graphics, including a world map and the VSD logo, by streaming data from FPGA on-chip memory to the OLED with reliable and periodic refresh.

## Specifications

### Hardware Specifications

#### FPGA Specifications
- **FPGA Platform**: VSD SQUADRON FM 
- **I/O Operating Voltage**: 3.3 V
- **Clock Source**: On-chip high-frequency oscillator (FPGA internal)
- **Memory**: On-chip FPGA RAM used for storing display graphic data

#### OLED Display Specifications
- **Display Module**: 0.96-inch OLED
- **Display Controller**: SSD1306
- **Display Resolution**: 128 × 64 pixels
- **Display Type**: Monochrome
- **Communication Interface**: I²C (SDA, SCL)
- **Operating Voltage**: 3.3 V
- **Addressing Mode**: Page addressing mode

###  Software Specifications

#### Software Environment
- **OS**: Linux (Ubuntu-based)
- **Purpose**: Development environment for FPGA design, simulation, synthesis, and version control

#### FPGA Toolchain Workflow

| Step | Tool Name | Purpose |
|------|----------|---------|
| 1 | Icarus Verilog (iverilog) | Compile and simulate Verilog HDL designs to verify functionality |
| 2 | GTKWave | View simulation waveforms to debug and validate FSMs and I²C signals |
| 3 | Yosys | Synthesize Verilog HDL into a gate-level netlist |
| 4 | nextpnr | Perform placement and routing for the iCE40 FPGA |
| 5 | icepack | Generate the FPGA bitstream from the placed and routed design |
| 6 | iceprog | Program the generated bitstream onto the FPGA hardware |
| 7 | icetime | Perform timing analysis on the synthesized design (optional but recommended) |

---

## ⛓️ I2C
The SSD1306 OLED display is commonly used in embedded systems due to its low power consumption, high contrast, and compact form factor. By leveraging the I²C interface, the VSD Squadron Mini can reliably transmit command and display data to the OLED, enabling the rendering of text, symbols, and simple graphics.

The objective of this project is to understand the practical aspects of I²C protocol operation, including device addressing, control byte formatting, and data transmission, while also gaining hands-on experience in driving a graphical display at the register and protocol level. This implementation serves as a foundational step toward more advanced embedded and SoC-based display applications.

---



## World Map Display

![Image](https://github.com/MOHAMMEDRIYAJ/OLED-1306-I2C-with-VSQUADRON-FM-/blob/main/Images/World%20Map.jpeg)

---

## Display Block Diagram

![Image](https://github.com/MOHAMMEDRIYAJ/OLED-1306-I2C-with-VSQUADRON-FM-/blob/main/Images/Display.jpeg)

---

## Display Partition

![Image](https://github.com/MOHAMMEDRIYAJ/OLED-1306-I2C-with-VSQUADRON-FM-/blob/main/Images/Display%20Partition.jpeg)

---


