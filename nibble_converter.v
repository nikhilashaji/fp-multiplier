
module nibble_converter
   (
      input  wire                     clk,
      input  wire                     reset,
      input  wire                     oneUSClk,
      input  wire                     mult_done, 
      input  wire [5:0]               lcd_cmd_ptr, 
      input  wire [31:0]              product, 
      output reg  [3:0]               data_in 
   );

reg  [31:0] prod_mem[0:4];
reg  [31:0] rrf_mem_1,rrf_mem_2;
reg  [ 3:0] mult_addr;
reg         mult_done_dly1;
wire        mult_done_rise;

always @ (posedge clk, posedge reset)
  if (reset)
    mult_done_dly1 <= 1'b0;
  else
    mult_done_dly1 <= mult_done;

always @ (posedge clk, posedge reset)
  if (reset)
    mult_addr <= 1'b0;
  else if (mult_done_rise)
    mult_addr <= mult_addr + 'd1;

assign mult_done_rise = (mult_done && !mult_done_dly1);

always @ (posedge clk, posedge reset)
  if (reset)
  begin	  
    prod_mem[00] <= 'd0;
    prod_mem[01] <= 'd0;
    prod_mem[02] <= 'd0;
    prod_mem[03] <= 'd0;
    prod_mem[04] <= 'd0;
  end  
  else if (mult_done_rise)
  begin	  
    prod_mem[mult_addr] <= product;
  end  

always @ (posedge oneUSClk, posedge reset)
  if (reset)
    data_in <= 'd0;
  else
    case (lcd_cmd_ptr)	  
       6'h04:  data_in <= rrf_mem_2[31:28];
       6'h05:  data_in <= rrf_mem_2[27:24];
       6'h06:  data_in <= rrf_mem_2[23:20];
       6'h07:  data_in <= rrf_mem_2[19:16];
       6'h08:  data_in <= rrf_mem_2[15:12];
       6'h09:  data_in <= rrf_mem_2[11:08];
       6'h0a:  data_in <= rrf_mem_2[07:04];
       6'h0b:  data_in <= rrf_mem_2[03:00];
       6'h0c:  data_in <= rrf_mem_2[31:28];
       6'h0d:  data_in <= rrf_mem_2[27:24];
       6'h0e:  data_in <= rrf_mem_2[23:20];
       6'h0f:  data_in <= rrf_mem_2[19:16];
       6'h10:  data_in <= rrf_mem_2[15:12];
       6'h11:  data_in <= rrf_mem_2[11:08];
       6'h12:  data_in <= rrf_mem_2[07:04];
       6'h13:  data_in <= rrf_mem_2[03:00];
       6'h14:  data_in <= rrf_mem_2[31:28];
       6'h15:  data_in <= rrf_mem_2[27:24];
       6'h16:  data_in <= rrf_mem_2[23:20];
       6'h17:  data_in <= rrf_mem_2[19:16];
       6'h18:  data_in <= rrf_mem_2[15:12];
       6'h19:  data_in <= rrf_mem_2[11:08];
       6'h1a:  data_in <= rrf_mem_2[07:04];
       6'h1b:  data_in <= rrf_mem_2[03:00];
       6'h1c:  data_in <= rrf_mem_2[31:28];
       6'h1d:  data_in <= rrf_mem_2[27:24];
       6'h1e:  data_in <= rrf_mem_2[23:20];
       6'h1f:  data_in <= rrf_mem_2[19:16];
       6'h20:  data_in <= rrf_mem_2[15:12];
       6'h21:  data_in <= rrf_mem_2[11:08];
       6'h22:  data_in <= rrf_mem_2[07:04];
       6'h23:  data_in <= rrf_mem_2[03:00];
       6'h24:  data_in <= rrf_mem_2[31:28];
       6'h25:  data_in <= rrf_mem_2[27:24];
       6'h26:  data_in <= rrf_mem_2[23:20];
       6'h27:  data_in <= rrf_mem_2[19:16];
       6'h28:  data_in <= rrf_mem_2[15:12];
       6'h29:  data_in <= rrf_mem_2[11:08];
       6'h2a:  data_in <= rrf_mem_2[07:04];
       6'h2b:  data_in <= rrf_mem_2[03:00];
      default :data_in <= rrf_mem_2[03:00];
   endcase
   
always @(posedge clk, posedge reset)
  if(reset)
   rrf_mem_1 <= 'd0;
  else if(lcd_cmd_ptr == 'd2)
   rrf_mem_1 <= prod_mem[00];
  else if(lcd_cmd_ptr == 'd11)
   rrf_mem_1 <= prod_mem[01];
  else if(lcd_cmd_ptr == 'd19)
   rrf_mem_1 <= prod_mem[02];
  else if(lcd_cmd_ptr == 'd28)
    rrf_mem_1 <= prod_mem[03];
  else if(lcd_cmd_ptr == 'd36)
    rrf_mem_1 <= prod_mem[04];

always @(posedge clk, posedge reset)
  if(reset)
   rrf_mem_2 <= 'd0;
  else if(lcd_cmd_ptr == 'd3)
   rrf_mem_2 <= rrf_mem_1;
  else if(lcd_cmd_ptr == 'd12)
   rrf_mem_2 <= rrf_mem_1;
  else if(lcd_cmd_ptr == 'd20)
   rrf_mem_2 <= rrf_mem_1;
  else if(lcd_cmd_ptr == 'd29)
    rrf_mem_2 <= rrf_mem_1;
  else if(lcd_cmd_ptr == 'd37)
    rrf_mem_2 <= rrf_mem_1;

endmodule   
