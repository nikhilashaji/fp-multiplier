
module float_mem
    (
     input  wire        clk,
     input  wire        reset,
     input  wire        inc_ptr,
     output reg  [31:0] rrf_a,
     output reg  [31:0] rrf_b
    );

reg [2:0] count;

 //////////////////////////////////////////////////
//////////////////////a_mem////////////////////////
always @ (posedge clk)
  case(count)
    'd0:  rrf_a <= 32'h3fc4d2a5;
    'd1:  rrf_a <= 32'h3dbad4fb;
    'd2:  rrf_a <= 32'h3decb1c0;
    'd3:  rrf_a <= 32'h3a51e213;
    'd4:  rrf_a <= 32'h3e84ac84;
    'd5:  rrf_a <= 32'h3c896f89;
    'd6:  rrf_a <= 32'h3ccc05fb;
    'd7:  rrf_a <= 32'h3c546f32;
     endcase
//////////////////////////////////////////////////

//////////////////////b_mem////////////////////////

always @ (posedge clk)
    case(count) 
       'd0: rrf_b <= 32'h3fc4d2a5;
       'd1: rrf_b <= 32'h3dbad4fb;
       'd2: rrf_b <= 32'h3e39d472;
       'd3: rrf_b <= 32'h3b58fc1f;
       'd4: rrf_b <= 32'h3e776afd;
       'd5: rrf_b <= 32'h3f42c899;
       'd6: rrf_b <= 32'h3d6785bf;
       'd7: rrf_b <= 32'h3effd8b0;
     endcase
//////////////////////////////////////////////////////////////

always @ (posedge clk,posedge reset)
   if (reset)
     count <= 'd0;
   else if(inc_ptr)
     count <= count+'d1;
     
endmodule
