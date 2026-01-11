module OLED(
//input  wire rst_n,     
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
);  //50MHz clock
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

    /*if (!rst_n) begin
      Start      <= 0;
      DCn        <= 0;
      DATA       <= 0;
      d          <= 0;
      delay      <= 0;
      addr       <= 0;
      col        <= 0;
      step       <= 0;
      page       <= 0;
      bank       <= 0;
      mem        <= 0;
      fps        <= 0;
      pwr_delay  <= 24'd8_000_000;  // ~150 ms @ 48 MHz
  end
  else */
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
