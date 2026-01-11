
# ⚙️ I2C SSD1306 OLED Interfacing with VSDSquadron FPGA Mini 

## 📌 Project Overview

This project demonstrates the implementation of the Inter-Integrated Circuit (I²C) communication protocol using Verilog HDL on the **VSDSquadron FM** development board to interface with a **0.96-inch SSD1306-based OLED display (128×64 resolution)**. I²C is a widely used serial communication protocol that enables efficient data transfer between digital devices using only two signal lines: Serial Data (SDA) and Serial Clock (SCL).

 As a demonstration, a **World map and the VSD** are rendered on the OLED display. This project serves as a practical example of FPGA-based peripheral interfacing and digital system design, making it suitable for academic learning and hands-on hardware development.


<img src="https://github.com/MOHAMMEDRIYAJ/OLED-1306-I2C-with-VSQUADRON-FM-/blob/main/Images/VSD.jpeg" width="90%" height="90%">


## Table of Contents

1.  [Key Features](#key-features)
2.  [Specifications](#specifications)
3.  [I2C Protocol Description](#i2c-protocol-description)
4.  [Files](#verilog-and-other-files)
5.  [Toolchain Installation (Linux)](#toolchain-installation-and-setup-linux)
6.  [Build and Flash Flow](#10-build-and-flash)
7.  [Design Flow](#design-flow)
8.  [Outputs](#outputs)
9.  [Learning Outcomes](#learning-outcomes)
10. [Summary](#summary)

## Key Features

- **Fully Synthesizable FPGA-Based I²C Master**  
  Implements the complete I²C protocol in Verilog HDL, including start/stop generation, slave addressing, and byte-level data transfer, without using any external microcontroller.

- **SSD1306-Compliant OLED Control**  
  Correctly initializes and drives a 0.96-inch 128×64 SSD1306 OLED display using the I²C control byte mechanism to distinguish between command and display data.

- **On-Chip Graphics Rendering**  
  Displays predefined monochrome graphics, including a world map and the VSD logo, by streaming data from FPGA on-chip memory to the OLED with reliable and periodic refresh.

## Specifications

### Hardware :

#### FPGA 
- **FPGA Platform**: VSDSQUADRON FM 
- **I/O Operating Voltage**: 3.3 V
- **Clock Source**: On-chip high-frequency oscillator (FPGA internal)
- **Memory**: On-chip FPGA RAM used for storing display graphic data

#### OLED Display 
- **Display Module**: 0.96-inch OLED
- **Display Controller**: SSD1306
- **Display Resolution**: 128 × 64 pixels
- **Display Type**: Monochrome
- **Communication Interface**: I²C (SDA, SCL)
- **Operating Voltage**: 3.3 V
- **Addressing Mode**: Page addressing mode

###  Software :

#### Environment
- **OS**: Linux (Ubuntu-based)
- **Purpose**: Development environment for FPGA design, simulation, synthesis, and version control

#### Tools

| Step | Tool Name | Purpose |
|------|----------|---------|
| 1 | Icarus Verilog (iverilog) | Compile and simulate Verilog HDL designs to verify functionality |
| 2 | GTKWave | View simulation waveforms to debug and validate FSMs and I²C signals |
| 3 | Yosys | Synthesize Verilog HDL into a gate-level netlist |
| 4 | nextpnr | Perform placement and routing for the iCE40 FPGA |
| 5 | icepack | Generate the FPGA bitstream from the placed and routed design |
| 6 | iceprog | Program the generated bitstream onto the FPGA hardware |


---

## I2C Protocol Description

The **Inter-Integrated Circuit (I²C)** protocol is a **synchronous serial communication** standard that connects multiple devices using only **two lines**:  

- **SDA** – Serial Data  
- **SCL** – Serial Clock  

### Key Points
- **Master-Slave Architecture**: Master controls the clock; slaves respond to requests.  
- **Data Transfer**: 8-bit bytes sent with an ACK/NACK from the Oled.  
- **Start/Stop Conditions**: Start signals the beginning; Stop signals the end of communication.  
- **Command/Data Control**: Some devices (like SSD1306 OLED) use a control byte to differentiate command bytes from data bytes.  

---
### Verilog and Other Files

<details>
<summary><strong>Design Files</strong></summary>

<details>
<summary><strong>I2C.v</strong></summary>

```verilog
module I2C(
input clk,                    //clock input
input start,                   //start signal
input DCn,                     //1 -> Data/ 0 -> Command
input [7:0]Data,               //8-bit Data
output reg busy=0,             //I2C busy
output reg scl=1,              //Serial clock
output reg sda=1);             //Serial data

parameter IDEL  = 0;
parameter START = 1;
parameter ADDR  = 2;
parameter CBYTE = 3;
parameter DATA  = 4;
parameter STOP  = 5;
parameter T_WAIT= 50;        //=wait_time*clk_frequency  =5us*12MHz 4

reg DCn_r=0;
reg [2:0]state=0;
reg [3:0]i=0;
reg [3:0]step=0;
reg [12:0]delay=1;
reg [7:0]slave= 8'b01111000;   //slave address
reg [7:0]cbyte= 8'b10000000;   //Control byte for command
reg [7:0]dbyte= 8'b01000000;   //Control byte for data
reg [7:0]data=  0;

always @(posedge clk)
begin
     
if(delay != 1)                 //if delay is not zero, wait for clock cycles specified by delay
begin
 delay<= delay-1;
end else begin                 //if delay is zero, proceed
 case(state)
 IDEL:begin
 	scl<=1;
 	sda<=1;
 	if(start) 
 	begin                  //when start signal is recieved,
 	   DCn_r<=DCn;         //fetch data or command?
 	   data<=Data;         //detch data/command to transmit
 	   busy<=1;            //update busy flag
 	   state<= START;      //start transmission
 	   step<=0;            //sub state = 0    
 	end
      end
      
 START:begin                   //start signal. 
 	case(step)
 	0:begin
 	    sda<=0;            //SDA goes low
 	    delay<=T_WAIT;     //wait for T_WAIT cycles
 	    step<=step+1;      
 	  end
 	1:begin
 	    scl<=0;            //SCL goes low
 	    // delay<=T_WAIT;     //Wait for T_WAIT cycles
 	    //step<=step+1;
	    state<=ADDR;       //Start sending address
 	    step<=0;
 	  end
 	// 2:begin
 	//     state<=ADDR;       //Start sending address
 	//     step<=0;
 	//   end
 	endcase
       end

 ADDR:begin
 	case(step)
 	0:begin
 	  if(i<8)              //check if all bits are transmitted
 	  begin
 	      scl<=0;          //SCL goes low
 	      step<=1;
 	  end else if(i==8)    //ACK bit
 	  begin
 	      scl<=0;
 	      sda<=0;
 	      delay<=T_WAIT;
 	      i<=i+1;
 	      step<=2;
 	  end
 	  end
 	1:begin
 	      sda<=slave[7-i];  //transmit address bit
 	      delay<=T_WAIT-1;
 	      i<=i+1;
 	      step<=2;
 	  end
 	2:begin
 	    if(i<9)
 	    begin
 	      scl<=1;           //SCL goes high
 	      delay<=T_WAIT;    //Delay
 	      step<=0;
 	    end else begin
 	      scl<=1;
 	      delay<=T_WAIT;
 	      step<=3;
 	    end
 	  end
 	3:begin
 	      scl<=0;           //SCL goes low
 	      sda<=0;
 	      delay<=T_WAIT;    //Delay
 	      step<=4;
 	  end
 	4:begin
 	      step<=0;
 	      i<=0;
 	      state<=CBYTE;     //transmit control byte
 	  end
 	endcase
      end
      
 CBYTE:begin
 	case(step)
 	0:begin
 	  if(i<8)
 	  begin
 	      scl<=0;
 	      step<=1;
 	  end else if(i==8)
 	  begin
 	      scl<=0;
 	      sda<=0;
 	      delay<=T_WAIT;
 	      i<=i+1;
 	      step<=2;
 	  end
 	  end
 	1:begin
 	      if(DCn_r)
 	      begin
 	      	sda<=dbyte[7-i];
 	      end else begin
 	      	sda<=cbyte[7-i];
 	      end
 	      delay<=T_WAIT-1;
 	      i<=i+1;
 	      step<=2;
 	  end
 	2:begin
 	    if(i<9)
 	    begin
 	      scl<=1;
 	      delay<=T_WAIT;
 	      step<=0;
 	    end else begin
 	      scl<=1;
 	      delay<=T_WAIT;
 	      step<=3;
 	    end
 	  end
 	3:begin
 	      scl<=0;
 	      sda<=0;
 	      delay<=T_WAIT;
 	      step<=4;
 	  end
 	4:begin
 	      step<=0;
 	      i<=0;
 	      state<=DATA;
 	  end
 	
 	endcase
      end
      
 DATA:begin
 	case(step)
 	0:begin
 	  if(i<8)
 	  begin
 	      scl<=0;
 	      step<=1;
 	  end else if(i==8)
 	  begin
 	      scl<=0;
 	      sda<=0;
 	      delay<=T_WAIT;
 	      i<=i+1;
 	      step<=2;
 	  end
 	  end
 	1:begin
 	      sda<=data[7-i];
 	      delay<=T_WAIT-1;
 	      i<=i+1;
 	      step<=2;
 	  end
 	2:begin
 	    if(i<9)
 	    begin
 	      scl<=1;
 	      delay<=T_WAIT;
 	      step<=0;
 	    end else begin
 	      scl<=1;
 	      delay<=T_WAIT;
 	      step<=3;
 	    end
 	  end
 	3:begin
 	      scl<=0;
 	      sda<=0;
 	      delay<=T_WAIT;
 	      step<=4;
 	  end
 	4:begin
 	      step<=0;
 	      i<=0;
 	      state<=STOP;
 	  end
 	
 	endcase
      end   
 STOP:begin
 	case(step)
 	0:begin
 	    scl<=1;         //SCL goes high
 	    sda<=0;         //SDA goes low
 	    delay<=T_WAIT;     //Wait
 	    step<=step+1;
 	  end
 	1:begin
 	    state<=IDEL;   //IDLE, SDA goes high
 	    busy<=0;       //Update busy flag
 	    step<=0; 
 	  end
 	endcase
       end    

 endcase
end
end


endmodule
```
</details> 

<details>
<summary><strong>oled.v</strong></summary>

```verilog 

module OLED(    
output SCL,         //OLED serial Clock
output SDA,         //OLED serial Data
output FPS         //Output to measure FPS
);

parameter T=5;     //Delay betweeen two instructions

//--------------I2C interface-----------------------
wire Busy;
wire Clk;              
reg Start=0;
reg DCn=0;
reg [7:0]DATA=0;

reg [15:0]d=0;
reg [12:0]delay=0;
reg [7:0] addr=0;
reg [6:0]col=0;
reg [5:0]step=0;
reg [2:0]page=0;
reg bank=0;
reg mem=0;
reg fps=0;
reg [23:0] pwr_delay = 24'd8_000_000;  // ~150 ms @ ~48 MHz


wire [15:0] dout1;
wire [15:0] dout2;


//----------Module instantiation-----------------------------------------------------------

SB_HFOSC #(.CLKHF_DIV("0b01")) u_SB_HFOSC (
  .CLKHFPU(1'b1),
  .CLKHFEN(1'b1),
  .CLKHF(Clk)
);  
I2C Mod(.clk(Clk),.start(Start),.DCn(DCn),.Data(DATA),.busy(Busy),.scl(SCL),.sda(SDA));   //I2C Master
SB_RAM40_4K Mem1(
  .WDATA(16'd0),
  .MASK(16'd0),
  .WADDR(11'd0),
  .WE(1'b0),          // ROM: write disabled
  .WCLKE(1'b0),
  .WCLK(1'b0),
  .RDATA(dout1),
  .RADDR({3'b0,addr}),
  .RE(1'b1),
  .RCLKE(1'b1),
  .RCLK(Clk)
);
SB_RAM40_4K Mem2(
  .WDATA(16'd0),
  .MASK(16'd0),
  .WADDR(11'd0),
  .WE(1'b0),          // ROM: write disabled
  .WCLKE(1'b0),
  .WCLK(1'b0),
  .RDATA(dout2),
  .RADDR({3'b0,addr}),
  .RE(1'b1),
  .RCLKE(1'b1),
  .RCLK(Clk)
);
//------------------------------------------------------------------------------------------

always @(posedge Clk)
begin
  if(mem)                //choose memory module
     begin
        d<=dout2;         //Mem2
     end
  else
     begin
        d<=dout1;         //Mem1
     end
end

always @(posedge Clk)
begin
  if (pwr_delay != 0)
  begin
    pwr_delay <= pwr_delay - 1;
    Start <= 0;       // Do NOT start I2C
    step  <= 0;       // Hold FSM at step 0
    delay <= 0;
  end
  // -------- Normal OLED operation --------
  else
  begin
    Start <= 0;  
     if(delay!=0)
     begin
        delay<=delay-1;             //Handle delay
     end 
  else 
     begin
        if(Busy)
           begin
              Start<=0;              //If I2C bus is busy, add delay of T cycles 
              delay<=T;              //Delay between two instructions
           end 
        else
           begin
              case(step)
              0:begin
          	   DATA<=8'hAF;      //set display on
          	   DCn<=0;
	           Start<=1;
         	   step<=step+1;
	           delay<=T;
        	end
      	      1:begin
          	   DATA<=8'hA6;      //set normal mode
	           DCn<=0;
         	   Start<=1;
	           step<=step+1;
         	   delay<=T;
	        end
      	      2:begin
          	   DATA<=8'h20;      //set addressing mode
  	           DCn<=0;
         	   Start<=1;
	           step<=step+1;
        	   delay<=T;
 	        end
      	      3:begin
         	   DATA<=8'h02;      //set addressing mode to page
	           DCn<=0;
         	   Start<=1;
	           step<=step+1;
	           delay<=T;
 	        end
      	      4:begin
	           DATA<=8'h8D;      //charge pump setting
         	   DCn<=0;
	           Start<=1;
         	   step<=step+1;
	           delay<=T;
        	end
      	      5:begin
	           DATA<=8'h14;      //charge pump on
         	   DCn<=0;
	           Start<=1;
         	   step<=step+1;
	           delay<=T;
	        end
      	      6:begin
        	   DATA<=8'h00;      //set column address lower nibble to 0
	           DCn<=0;
         	   Start<=1;
	           step<=step+1;
	           delay<=T;
        	end
      	      7:begin
	           DATA<=8'h10;      //set column address higher nibble to 0
         	   DCn<=0;
	           Start<=1;
         	   step<=step+1;
 	           delay<=T;
        	end
      	      8:begin
	           DATA<=8'hB0+page; //set page number
	           DCn<=0;
	           Start<=1;
	           step<=9;
 	           delay<=T;
        	end
      	      9:begin
   	           if(bank==0)
          	      begin
 	                 DATA<=d[7:0];      //send data from lower bank
            	         bank<=1;
  	             end
          	   else
 	              begin	
            	         DATA<=d[15:8];      //send data from upper bank
   	                 addr<=addr+1;       //increment address
	                 if(addr==8'b11111111)
		            begin
		               mem<=~mem;    //After reading Mem1, read Mem2
		               addr<=0;      //Reset address
		            end
	                 bank<=0;
 	              end
          	   DCn<=1;
          	   Start<=1;
          	   delay<=T;
          	   col<=col+1;                //Increment column address
          	   if(col==127)
          	      begin
	                 page<=page+1;        //After 128 columns, change page
	                 if(page==7)
   	                    begin
            	               fps<=1;
 		            end 
 		         else 
 		            begin
		               fps<=0;
		            end
	                step<=8;             //Send page address
          	      end
      	        end
              endcase
           end
     end
end
end

assign FPS=fps;


//------------Replace this part------------------------------------------------------------

defparam Mem2.INIT_F = 256'h000000000000001F1F1F0000001F1F1F00000000000000000000000000000000;
defparam Mem2.INIT_E = 256'h0000_3f3f_3131_3131_3131_3100_0000_0000_0000_0000_0000_0000_0000_0000_0000_0030;
//defparam Mem2.INIT_E = 256'h00_003f_3f31_3131_3131_3131_0000_0000_0000_0000_0000_0000_0000_0000_0000_000000;
defparam Mem2.INIT_D = 256'h3f3f_3030_3030_381f_0f00_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
defparam Mem2.INIT_C = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
defparam Mem2.INIT_B = 256'h0000_0000_0000_00e0_f0f8_3c3e_3cf8_f0e0_0000_0000_0000_0000_0000_0000_0000_0000;

defparam Mem2.INIT_A = 256'h0000_c6c6_c6c6_c6c6_c6fe_fe00_0000_0000_0000_0000_0000_0000_0000_0000_0000_0006;

defparam Mem2.INIT_9 = 256'hfefe_0606_0606_0efc_f800_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;

defparam Mem2.INIT_8 = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;

defparam Mem2.INIT_7 = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
defparam Mem2.INIT_6 = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
defparam Mem2.INIT_5 = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
defparam Mem2.INIT_4 = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
defparam Mem2.INIT_3 = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
defparam Mem2.INIT_2 = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
defparam Mem2.INIT_1 = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
defparam Mem2.INIT_0 = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;

defparam Mem1.INIT_F = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
defparam Mem1.INIT_E = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
defparam Mem1.INIT_D = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
defparam Mem1.INIT_C = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;

defparam Mem1.INIT_B = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
defparam Mem1.INIT_A = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;

defparam Mem1.INIT_9 = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;

defparam Mem1.INIT_8 = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;

defparam Mem1.INIT_7 = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;

defparam Mem1.INIT_6 = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
defparam Mem1.INIT_5 = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
defparam Mem1.INIT_4 = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
defparam Mem1.INIT_3 = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
defparam Mem1.INIT_2 = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
defparam Mem1.INIT_1 = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
defparam Mem1.INIT_0 = 256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;

endmodule
```
</details> 

</details> 

<details>
<summary><strong>Constraints.pcf</strong></summary>

```
set_io FPS 39
set_io SCL 27
set_io SDA 28

```
</details>


<details>
<summary><strong>Makefile</strong></summary>

```makefile
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

```
 </details> 



## Toolchain Installation and Setup (Linux)

This project uses a **native Linux-based open-source FPGA toolchain** instead of a prebuilt `.vdi` (VirtualBox disk image).  
Replicating the toolchain directly on Linux ensures transparency, flexibility, and easier debugging.

---

### 1. Install Required Packages

Install all necessary FPGA, simulation, and USB programming tools using `apt`:

```bash
sudo apt update
sudo apt install -y \
git make gcc g++ \
yosys \
nextpnr-ice40 \
fpga-icestorm \
icepack \
iverilog \
gtkwave \
libftdi1-dev \
libusb-1.0-0-dev
```


### 2. Verify USB Detection

After connecting the VSDSquadron board, verify USB detection:

```bash
lsusb
```

You should see an FTDI device listed.

Test programmer access:

```bash
iceprog -t
```

If permission is denied, proceed to udev setup.

### 3. Configure udev Rules (USB Access)

Create a udev rule to allow non-root access to the board:

```bash
sudo gedit /etc/udev/rules.d/99-vsdsquadron-ftdi.rules

```
Add the following line:

```
SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="6014", MODE="0666"
```

Reload udev rules:

```bash
sudo udevadm control --reload-rules
sudo udevadm trigger
```

Unplug and replug the VSDSquadron board.

### 4. Toolchain Verification

Verify installed tools:

```bash
yosys -V
nextpnr-ice40 --version
iverilog -V
gtkwave --version
iceprog -t
```

Successful detection confirms the toolchain is ready.

### 5. next step to create the folder VSDSquadron_FM  for projects 

```bash
mkdir -p ~/VSDSquadron_FM/I2C_Protocol
```

#### 6. Get into the protocol folder :
```bash
cd ~/VSDSquadron_FM/I2C_Protocol
```
#### 7. create a file for verilog files :

```bash
gedit I2C.v 
```

```bash
gedit OLED.v
```

#### 8. create constraints.pcf

```bash
gedit constraints.pcf
```
Defines the physical pin mapping between logical signals (such as `SCL`, `SDA`, etc.) and the FPGA package pins.  
This ensures correct electrical connectivity between the FPGA and external hardware components.

#### 9. create Makefile

```bash
gedit Makefile
```
Automates the complete FPGA toolchain flow and enforces the correct execution order of synthesis, place-and-route, and bitstream generation.  
It allows the entire build process to be triggered with a single command, improving reproducibility and reducing manual errors.

#### 10. Build and Flash 

```bash
make clean
make
sudo make flash
```
 `make clean`
Removes all previously generated build artifacts (`.json`, `.asc`, `.bin`) to ensure a clean and deterministic build environment.  
This is recommended before every fresh synthesis run to avoid stale or conflicting outputs.

`make`
Executes the complete FPGA build flow defined in the `Makefile`, which includes:
- Verilog synthesis using **Yosys**
- Place-and-route using **nextpnr-ice40**
- Bitstream generation using **icepack**

All Verilog source files and the pin constraints file are consumed during this process.

`sudo make flash`
Programs the generated bitstream (`.bin`) onto the FPGA using **iceprog**.  
Superuser privileges are typically required for USB device access.

---




### Design Flow 

```
Verilog Design (.v)
        ↓
Simulation (iverilog + GTKWave)
        ↓
Synthesis (Yosys)
        ↓
Place & Route (nextpnr-ice40)
        ↓
Bitstream Generation (icepack)
        ↓
FPGA Programming (iceprog)
```
---

## Outputs:

### World Map Display

![Image](https://github.com/MOHAMMEDRIYAJ/OLED-1306-I2C-with-VSQUADRON-FM-/blob/main/Images/World%20Map.jpeg)

---

### VSD Display

<img src="https://github.com/MOHAMMEDRIYAJ/OLED-1306-I2C-with-VSQUADRON-FM-/blob/main/Images/VSD.jpeg" width="90%" height="90%">

## Display Methodology :

<p align="center">
<img src="https://github.com/MOHAMMEDRIYAJ/OLED-1306-I2C-with-VSQUADRON-FM-/blob/main/Images/Display.jpeg" width="20%" height="100%">
<img src="https://github.com/MOHAMMEDRIYAJ/OLED-1306-I2C-with-VSQUADRON-FM-/blob/main/Images/Display%20Partition.jpeg" width="772.2">
</p>

The display memory is divided into 32 independent blocks, where MEM2 contains 16 blocks and MEM1 contains the other 16 blocks. Each block represents a vertical-aligned pixel group and is encoded as 32 nibbles. Every nibble corresponds to a vertical slice of pixels and is represented directly as a hexadecimal digit in the code, with the bottom pixel as the LSB and the top pixel as the MSB.

A block is coded using Verilog initialization parameters such as:

<pre>
 defparam Mem2.INIT_D = 256'h3f3f_3030_3030_381f_0f00_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
</pre>

In this encoding, the first hex digit represents the first nibble, the second hex digit is the nibble directly below it, the third hex digit is positioned to the right of the first nibble, and the fourth hex digit lies below the third and to the right of the second. This ordering continues across the block, allowing a clear left-to-right and top-to-bottom mapping between the Excel layout and the memory initialization.

---

## Learning Outcomes

This project helped me understand the complete FPGA design flow on the VSDSquadron FM  using Verilog HDL and an open-source toolchain. I gained practical experience with the I²C protocol, SSD1306 OLED interfacing, pin constraints, and FPGA programming on Linux. Overall, it strengthened my skills in digital design, FPGA workflows, and hardware–software integration.


## 👥 Team Members:

Mohammed Riyaj J, Bannari Amman Institute Of Technology [[Linkedin](https://www.linkedin.com/in/mohammedriyaj786/)]  [[Github](https://github.com/MOHAMMEDRIYAJ)]

Mohanapriyan P, Bannari Amman Institute Of Technology [[Linkedin](https://www.linkedin.com/in/mohanapriyan-p-b94962325/)]  [[Github](https://github.com/MOHANAPRIYANP16)]

---

We are grateful to our VLSI faculty for his consistent support and valuable guidance throughout the project.

Dr.Elango Sekar S [[Linkedin](https://www.linkedin.com/in/elango-sekar-8973b958/)]  [[Github](https://github.com/eceelango)]

Associate Professor,Department of ECE ,Bannari Amman Institute Of Technology.

---

## Acknowledgements

We gratefully acknowledge the work of **Premraj02** [Github](https://github.com/Premraj02/OLED-Controller-Verilog) for the foundational reference repository OLED-Controller-Verilog. This project provided valuable insights into SSD1306 OLED interfacing using Verilog and served as a key learning resource that helped inform the design and implementation of our I²C-based OLED controller on the VSDSquadron FM platform.


# Summary

This project implements an I²C-based interface between the VSDSquadron FM FPGA and a 0.96-inch SSD1306 OLED display using Verilog HDL. A synthesizable I²C master is designed to handle display initialization and data transfer over the SDA and SCL lines. Graphic patterns, including a world map and the VSD , are stored in FPGA on-chip memory and rendered on a 128×64 monochrome OLED.

The project demonstrates end-to-end FPGA display interfacing, including protocol-level communication, finite-state machine control, and reliable frame refresh using an open-source ICE40 toolchain on Linux. It serves as a practical learning platform for digital design, embedded graphics handling, and hardware–software co-design using the VSDSquadron FM board.

