////////////////////////////////////////
//This is the modified version of Pmod CLP controller reference code
//
/////////////////////////////////////////////

`timescale 1ns / 1ps

module instrctn_wrd_gen(
    input  wire        reset,								
    input  wire        oneUSClk,
    input  wire  [3:0] data_in,
    output wire   [5:0] lcd_cmd_ptr,
    output wire  [7:0] JD,
	output wire  [6:4] JE
	
    );

	
	// ===========================================================================
	// 							  Parameters, Regsiters, and Wires
	// ===========================================================================
	
    reg[9:0] data_reg;
   //LCD control state machine
	parameter [3:0] stFunctionSet = 0,						// Initialization states
						 stDisplayCtrlSet = 1,
						 stDisplayClear = 2,
						 stPowerOn_Delay = 3,					// Delay states
						 stFunctionSet_Delay = 4,
						 stDisplayCtrlSet_Delay = 5,
						 stDisplayClear_Delay = 6,
						 stInitDne = 7,							// Display characters and perform standard operations
						 stActWr = 8,
						 stCharDelay = 9;							// Write delay for operations
	
	
	/* These constants are used to initialize the LCD pannel.

		--  FunctionSet:
								Bit 0 and 1 are arbitrary
								Bit 2:  Displays font type(0=5x8, 1=5x11)
								Bit 3:  Numbers of display lines (0=1, 1=2)
								Bit 4:  Data length (0=4 bit, 1=8 bit)
								Bit 5-7 are set
		--  DisplayCtrlSet:
								Bit 0:  Blinking cursor control (0=off, 1=on)
								Bit 1:  Cursor (0=off, 1=on)
								Bit 2:  Display (0=off, 1=on)
								Bit 3-7 are set
		--  DisplayClear:
								Bit 1-7 are set	*/
		
	
	reg [20:0] count = 21'b000000000000000000000;	// 21 bit count variable for timing delays
	wire delayOK;														
	reg [3:0] stCur = stPowerOn_Delay;						// LCD control state machine
	reg [3:0] stNext;
	wire writeDone;											// Command set finish
    
    
	reg [5:0] lcd_cmd_ptr_1, lcd_cmd_ptr_delay1, lcd_cmd_ptr_delay2;

	// ===========================================================================
	// 										Implementation
	// ===========================================================================

	// This process increments the count variable unless delayOK = 1.
	always @(posedge oneUSClk, posedge reset) begin
                        if(reset)
                           count <= 'd0;
	
			else if(delayOK == 1'b1) begin
					count <= 21'b000000000000000000000;
			end
			else begin
					count <= count + 1'b1;
			end
	
	end


	// Determines when count has gotten to the right number, depending on the state.
	assign delayOK = (
				((stCur == stPowerOn_Delay) && (count == 21'b111101000010010000000)) ||				// 2000000	 	-> 20 ms
				((stCur == stFunctionSet_Delay) && (count == 21'b000000000111110100000)) ||		// 4000 			-> 40 us
				((stCur == stDisplayCtrlSet_Delay) && (count == 21'b000000000111110100000)) ||	// 4000 			-> 40 us
				((stCur == stDisplayClear_Delay) && (count == 21'b000100111000100000000)) ||		// 160000 		-> 1.6 ms
				((stCur == stCharDelay) && (count == 21'b000111111011110100000))						// 260000		-> 2.6 ms - Max Delay for character writes and shifts
	) ? 1'b1 : 1'b0;

	// writeDone goes high when all commands have been run	
	assign writeDone = (lcd_cmd_ptr_1 == 6'd44) ? 1'b1 : 1'b0;

	
	// Increments the pointer so the statemachine goes through the commands
	always @(posedge oneUSClk,posedge reset) begin
                        if(reset)
                                 lcd_cmd_ptr_1 <= 5'b00000;
	        
			else if((stNext == stInitDne || stNext == stDisplayCtrlSet || stNext == stDisplayClear) && writeDone == 1'b0) begin
					lcd_cmd_ptr_1 <= lcd_cmd_ptr_1 + 1'b1;
			end
			else if(stCur == stPowerOn_Delay || stNext == stPowerOn_Delay) begin
					lcd_cmd_ptr_1 <= 5'b00000;
			end
			else begin
					lcd_cmd_ptr_1 <= lcd_cmd_ptr_1;
			end
	end
	/////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////
	always @(posedge oneUSClk,posedge reset) begin
	if(reset)
	begin
	   lcd_cmd_ptr_delay1 <= 'd0;
	   lcd_cmd_ptr_delay2 <= 'd0;
	end
	else
	begin
	   lcd_cmd_ptr_delay1 <= lcd_cmd_ptr_1;
	   lcd_cmd_ptr_delay2 <= lcd_cmd_ptr_delay1;
	end
	end  
	
	always @(posedge oneUSClk,posedge reset) begin
        if(reset)
            data_reg <= 'd0;
        else
        begin
            if(lcd_cmd_ptr_delay2 < 4 || lcd_cmd_ptr_delay2 == 'd44)
            begin
                data_reg[9:8] <= 2'b00; // write command names please
                if(lcd_cmd_ptr_delay2 == 'd0)
                   data_reg[7:0] <= 'h3C; 
                else if(lcd_cmd_ptr_delay2 == 'd1)
                   data_reg[7:0] <= 'h0C; 
                else if(lcd_cmd_ptr_delay2 == 'd2)
                   data_reg[7:0] <= 'h01; 
                else if(lcd_cmd_ptr_delay2 == 'd3)
                   data_reg[7:0] <= 'h02; 
                else if(lcd_cmd_ptr_delay2 == 'd44)
                   data_reg[7:0] <= 'h18;                       
            end                                             
            else
            begin
                data_reg[9:8] <= 2'b10;
            case(data_in)
            4'd0: data_reg[7:0] <= 'h30;   
            4'd1: data_reg[7:0] <= 'h31;
            4'd2: data_reg[7:0] <= 'h32;
            4'd3: data_reg[7:0] <= 'h33;
            4'd4: data_reg[7:0] <= 'h34;
            4'd5: data_reg[7:0] <= 'h35;
            4'd6: data_reg[7:0] <= 'h36;
            4'd7: data_reg[7:0] <= 'h37;
            4'd8: data_reg[7:0] <= 'h38;
            4'd9: data_reg[7:0] <= 'h39;
            4'd10: data_reg[7:0] <= 'h41; // A
            4'd11: data_reg[7:0] <= 'h42;
            4'd12: data_reg[7:0] <= 'h43;
            4'd13: data_reg[7:0] <= 'h44;
            4'd14: data_reg[7:0] <= 'h45;
            4'd15: data_reg[7:0] <= 'h46;     
            endcase   
            end    
        end
    end
	
	assign lcd_cmd_ptr = lcd_cmd_ptr_1[5:0]; 
	////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////
	
	// This process runs the LCD state machine
	always @(posedge oneUSClk,posedge reset) begin
	        
			 if(reset == 1'b1) begin
					stCur <= stPowerOn_Delay;
			end
			else begin
					stCur <= stNext;
			end
	end
	

	// This process generates the sequence of outputs needed to initialize and write to the LCD screen
	always @(stCur or delayOK or writeDone or lcd_cmd_ptr_1) begin
			case (stCur)
				// Delays the state machine for 20ms which is needed for proper startup.
				stPowerOn_Delay : begin
						if(delayOK == 1'b1) begin
							stNext <= stFunctionSet;
						end
						else begin
							stNext <= stPowerOn_Delay;
						end
				end
					
				// This issues the function set to the LCD as follows 
				// 8 bit data length, 1 lines, font is 5x8.
				stFunctionSet : begin
						stNext <= stFunctionSet_Delay;
				end
				
				// Gives the proper delay of 37us between the function set and
				// the display control set.
				stFunctionSet_Delay : begin
						if(delayOK == 1'b1) begin
							stNext <= stDisplayCtrlSet;
						end
						else begin
							stNext <= stFunctionSet_Delay;
						end
				end
				
				// Issuse the display control set as follows
				// Display ON,  Cursor OFF, Blinking Cursor OFF.
				stDisplayCtrlSet : begin
						stNext <= stDisplayCtrlSet_Delay;
				end

				// Gives the proper delay of 37us between the display control set
				// and the Display Clear command. 
				stDisplayCtrlSet_Delay : begin
						if(delayOK == 1'b1) begin
							stNext <= stDisplayClear;
						end
						else begin
							stNext <= stDisplayCtrlSet_Delay;
						end
				end
				
				// Issues the display clear command.
				stDisplayClear	: begin
						stNext <= stDisplayClear_Delay;
				end

				// Gives the proper delay of 1.52ms between the clear command
				// and the state where you are clear to do normal operations.
				stDisplayClear_Delay : begin
						if(delayOK == 1'b1) begin
							stNext <= stInitDne;
						end
						else begin
							stNext <= stDisplayClear_Delay;
						end
				end
				
				// State for normal operations for displaying characters, changing the
				// Cursor position etc.
				stInitDne : begin		
						stNext <= stActWr;
				end

				// stActWr
				stActWr : begin
						stNext <= stCharDelay;
				end
					
				// Provides a max delay between instructions.
				stCharDelay : begin
						if(delayOK == 1'b1) begin
							stNext <= stInitDne;
						end
						else begin
							stNext <= stCharDelay;
						end
				end

				default : stNext <= stPowerOn_Delay;

			endcase
	end
		
	// Assign outputs
	assign JE[4] = data_reg[9];
	assign JE[5] = data_reg[8];
	assign JD = data_reg[7:0];
	assign JE[6] = (stCur == stFunctionSet || stCur == stDisplayCtrlSet || stCur == stDisplayClear || stCur == stActWr) ? 1'b1 : 1'b0;
  
endmodule
