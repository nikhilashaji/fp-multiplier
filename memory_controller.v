
module memory_controller
    (
	 input  wire             clk,
         input  wire             reset,
	 input  wire             mult_done,
	 output reg              inc_ptr,
	 output reg              mult_start
	 );

reg  [3:0]  state;
reg  [4:0]  nibble_cnt; 
reg         mult_done_dly1;
wire        mult_done_rise;

always @(posedge clk, posedge reset)
  if (reset)
   begin	  
    state <= 'd0;
    mult_start <= 'd0;
    inc_ptr    <= 1'b0;	 
   end 
  else
  case(state)
    'h0 : state <= 'h1;
	'h1 : state <= 'h2;
	'h2 : state <= 'h3;
	'h3 : begin
	       state      <= 'h4;
	       mult_start <= 'd1;
	      end
        'h4 : begin
	       state      <= 'h5;
	       mult_start <= 'd0;
	      end
	'h5 : begin
	        if(mult_done)
	          state   <= 'h6;
		else
		  state   <=  'h5;
	      end
        'h6 : begin
	            state         <= 'h7;
	       end
        'h7 : begin
	         if(nibble_cnt < 'd5)
	         begin
		    inc_ptr    <= 1'b1;	 
		    state      <= 'h8;
		end
		else
		begin
		    inc_ptr    <= 1'b0;	 
		    state      <=  'h9;
		end
	       end
        'h8 : begin
		    inc_ptr    <= 1'b0;	 
	            state      <= 'h3;
	       end
        'h9 : begin
	            state         <= 'h9;
	       end
    default : state <= 'h0;
endcase	
	
always @ (posedge clk, posedge reset)
  if (reset)
    mult_done_dly1 <= 1'b0;
  else
    mult_done_dly1 <= mult_done;

assign mult_done_rise = (mult_done && !mult_done_dly1);

always @ (posedge clk, posedge reset)
  if (reset)
    nibble_cnt <= 'd0;
  else if (mult_done_rise)
    nibble_cnt <= nibble_cnt + 'd1;
		
endmodule
