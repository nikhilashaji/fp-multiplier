
module synthesis_top
    (
     input  wire        clk,
     input  wire        reset,
     output wire [7:0]  JD,
     output wire [2:0]  JE
    );


wire        mult_clear;
wire        mult_done;
wire [31:0] product;

wire [31:0] rrf_a;
wire [31:0] rrf_b;

wire        mult_start;
wire        inc_ptr;
wire [3:0]  data_in;

wire        oneUSClk;
wire  [5:0] lcd_cmd_ptr;


////////////////////////////////////

single_prec_mult s1
  (
    clk, 
    reset,
    mult_start, 
    rrf_a, 
    rrf_b, 
    product,
    mult_done 
  );
  
  
 float_mem fmem
    (
     clk,
     reset,
     inc_ptr,
     rrf_a,
     rrf_b
    );
 
 
 memory_controller memctrl
    (
       clk,
       reset,
       mult_done,
       inc_ptr,
       mult_start
    );
	


LCD_clk_unit clkunit
   (    clk,
		reset,
		oneUSClk
	);

					
 instrctn_wrd_gen wrdgen
 (
    reset,
    oneUSClk,
    data_in,
    lcd_cmd_ptr,
    JD,
    JE
 );



nibble_converter n1
   (
      clk,
      reset,
      oneUSClk,
      mult_done, 
      lcd_cmd_ptr, 
      product, 
      data_in 
   );


     ////////////////////////////////////////////////////////////////////////////////////////////////
	 
endmodule
