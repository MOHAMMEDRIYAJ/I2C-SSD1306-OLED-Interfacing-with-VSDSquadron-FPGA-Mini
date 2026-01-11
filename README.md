# 📌 OLED 1306 I2C DISPLAY WITH VSQUADRON FM FPGA


## About
## Introduction

## Introduction

This project demonstrates the implementation of the Inter-Integrated Circuit (I²C) communication protocol using Verilog HDL on the **VSD Squadron Mini** development board to interface with a **0.96-inch SSD1306-based OLED display (128×64 resolution)**. I²C is a widely used serial communication protocol that enables efficient data transfer between digital devices using only two signal lines: Serial Data (SDA) and Serial Clock (SCL).

 As a demonstration, a **world map and the VSD** are rendered on the OLED display. This project serves as a practical example of FPGA-based peripheral interfacing and digital system design, making it suitable for academic learning and hands-on hardware development.


<img src="https://github.com/MOHAMMEDRIYAJ/OLED-1306-I2C-with-VSQUADRON-FM-/blob/main/Images/VSD.jpeg" width="90%" height="90%">




## I2C
The SSD1306 OLED display is commonly used in embedded systems due to its low power consumption, high contrast, and compact form factor. By leveraging the I²C interface, the VSD Squadron Mini can reliably transmit command and display data to the OLED, enabling the rendering of text, symbols, and simple graphics.

The objective of this project is to understand the practical aspects of I²C protocol operation, including device addressing, control byte formatting, and data transmission, while also gaining hands-on experience in driving a graphical display at the register and protocol level. This implementation serves as a foundational step toward more advanced embedded and SoC-based display applications.

## about 
This project demonstrates the implementation of FPGA-based  Inter-Integrated Circuit (I²C) communication protocol interface for a 0.96-inch 128×64 SSD1306 OLED display on the VSQUADRON FM platform using Verilog HDL. The design features a fully synthesizable I²C master, SSD1306-compliant initialization sequencing, and command/data selection through the I²C control byte mechanism. 

The OLED operates in monochrome mode with page addressing, where display data is streamed from on-chip ROM to the display memory. The system periodically refreshes display data to ensure stable and reliable visual output. This project demonstrates low-level OLED interfacing, I²C protocol implementation, and practical FPGA-based digital design techniques.




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


