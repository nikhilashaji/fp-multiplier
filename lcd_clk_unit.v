////////////////////////////////////////
//
//One microsecond clk generator for instruction_word_generator and nibble_converter units
//
/////////////////////////////////////////////
module LCD_clk_unit(input wire clk,
					input wire reset,
					output reg oneUSClk);

reg [6:0] clkCount = 7'b0000000;
// This process counts to 100, and then resets.  It is used to divide the clock signal.
	// This makes oneUSClock peak aprox. once every 1microsecond
	always @(posedge clk, posedge reset) begin
                       if(reset) begin
                       clkCount <= 7'b0000000;
                        oneUSClk <= 'd0;
			end
			else if(clkCount == 7'b1100100) begin
			//if(clkCount == 7'b0000011) begin
					clkCount <= 7'b0000000;
					oneUSClk <= ~oneUSClk;
			end
			else begin
					clkCount <= clkCount + 1'b1;
			end

	end
	
endmodule