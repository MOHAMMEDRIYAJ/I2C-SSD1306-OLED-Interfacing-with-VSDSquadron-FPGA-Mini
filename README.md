# ⚙️ OLED 1306 I2C DISPLAY WITH VSQUADRON FM 


## 📌 Project Overview

This project demonstrates the implementation of the Inter-Integrated Circuit (I²C) communication protocol using Verilog HDL on the **VSD Squadron Mini** development board to interface with a **0.96-inch SSD1306-based OLED display (128×64 resolution)**. I²C is a widely used serial communication protocol that enables efficient data transfer between digital devices using only two signal lines: Serial Data (SDA) and Serial Clock (SCL).

 As a demonstration, a **world map and the VSD** are rendered on the OLED display. This project serves as a practical example of FPGA-based peripheral interfacing and digital system design, making it suitable for academic learning and hands-on hardware development.


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
- **FPGA Platform**: VSQUADRON FM (VSD Squadron Mini)
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

### Software Environment and Tools

#### Operating System
- **OS**: Linux (Ubuntu-based)
- **Purpose**: Development environment for FPGA design, simulation, synthesis, and version control

#### Tools and Their Usage

| Tool / Software | Category | Purpose |
|-----------------|----------|---------|
| Linux (Ubuntu) | Operating System | Provides a stable development environment for FPGA toolchains, scripting, and version control |
| Verilog HDL | Hardware Description Language | Used to design the I²C master, OLED controller, and control FSMs |
| Yosys | Synthesis Tool | Synthesizes Verilog HDL into a gate-level netlist |
| nextpnr | Place and Route | Performs placement and routing for the target FPGA |
| IceStorm Toolchain | FPGA Support Tools | Generates FPGA bitstream for Lattice iCE40-based devices |
| VS Code | Code Editor / IDE | Used for writing, editing, and managing Verilog source files |
| GTKWave | Simulation / Waveform Viewer | Used to analyze signal timing and FSM behavior during simulation |
| Git | Version Control System | Tracks source code changes and manages project versions |
| GitHub | Code Hosting Platform | Hosts the project repository and documentation |



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


