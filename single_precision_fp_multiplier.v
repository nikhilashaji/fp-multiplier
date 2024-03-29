
module single_prec_mult
  (
    input  wire        clk, 
    input  wire        reset,
    input  wire        start, 
    input  wire [31:0] a, 
    input  wire [31:0] b, 
    output reg  [31:0] product,
    output reg         mult_done 
  );

wire              a_sign;
wire              b_sign;
wire              o_sign;
wire [ 7:0]   a_exponent;
wire [ 7:0]   b_exponent;
wire [ 7:0] o_exponent_1;
wire [ 7:0]   o_exponent;
wire [24:0]   a_mantissa;
wire [24:0]   b_mantissa;
reg  [22:0]   o_mantissa;
wire [47:0]    i_product;
reg  [ 7:0]       fi_ldz;
wire          booth_done;
wire          a_exp_zero;
wire          b_exp_zero;
wire          a_man_zero;
wire          b_man_zero;
wire          prod0;
reg           mult_term;
reg           o_sign_reg;
reg  [ 7:0]   o_exponent_reg;

always @ (posedge clk, posedge reset)
  if (reset)
       product       <= 'd0;
  else if (booth_done)
       product        <= {o_sign_reg, o_exponent, o_mantissa[22:0]};

always @ (posedge clk, posedge reset)
  if (reset)
       mult_done       <= 'd0;
  else if (start && prod0)
       mult_done       <= 1'b1;
  else if (start )//|| mult_clear)
       mult_done       <= 'd0;
  else if (booth_done)
       mult_done       <= 1'b1;

always @ (posedge clk, posedge reset)
  if (reset)
       mult_term       <= 'd0;
  else if (start && prod0)
       mult_term       <= 1'b1;
  else
       mult_term       <= 1'b0;

always @ (posedge clk, posedge reset)
  if (reset)
  begin
    o_sign_reg     <= 'd0;
    o_exponent_reg <= 'd0;
  end
  else if (start)  
  begin
    o_sign_reg     <= o_sign;
    o_exponent_reg <= o_exponent_1;
  end

assign a_sign         = a[31];
assign b_sign         = b[31];
assign o_sign         = a_sign ^ b_sign;

assign a_exp_zero     = (a[30:23] ==  8'd0); 
assign b_exp_zero     = (b[30:23] ==  8'd0); 
assign a_man_zero     = (a[22:00] == 23'd0); 
assign b_man_zero     = (b[22:00] == 23'd0); 

assign prod0          = ((a_exp_zero & a_man_zero) || (b_exp_zero & b_man_zero));

assign a_exponent     = a[30:23];
assign b_exponent     = b[30:23];
assign o_exponent_1   = a_exponent + b_exponent - 127;

assign a_mantissa     = {2'b01, a[22:0]};//for normalization
assign b_mantissa     = {2'b01, b[22:0]};

assign o_exponent     = o_exponent_reg + fi_ldz;

always @ (i_product)
  casez (i_product)	
    48'b1???????????????????????????????????????????????: begin fi_ldz = 8'h01; o_mantissa = i_product[46:24]; end
    48'b01??????????????????????????????????????????????: begin fi_ldz = 8'd00; o_mantissa = i_product[45:23]; end  
    48'b001?????????????????????????????????????????????: begin fi_ldz = 8'hFE; o_mantissa = i_product[44:22]; end 
    48'b0001????????????????????????????????????????????: begin fi_ldz = 8'hFD; o_mantissa = i_product[43:21]; end 
    48'b00001???????????????????????????????????????????: begin fi_ldz = 8'hFC; o_mantissa = i_product[42:20]; end 
    48'b000001??????????????????????????????????????????: begin fi_ldz = 8'hFB; o_mantissa = i_product[41:19]; end 
    48'b0000001?????????????????????????????????????????: begin fi_ldz = 8'hFA; o_mantissa = i_product[40:18]; end 
    48'b00000001????????????????????????????????????????: begin fi_ldz = 8'hF9; o_mantissa = i_product[39:17]; end 
    48'b000000001???????????????????????????????????????: begin fi_ldz = 8'hF8; o_mantissa = i_product[38:16]; end 
    48'b0000000001??????????????????????????????????????: begin fi_ldz = 8'hF7; o_mantissa = i_product[37:15]; end 
    48'b00000000001?????????????????????????????????????: begin fi_ldz = 8'hF6; o_mantissa = i_product[36:14]; end 
    48'b000000000001????????????????????????????????????: begin fi_ldz = 8'hF5; o_mantissa = i_product[35:13]; end 
    48'b0000000000001???????????????????????????????????: begin fi_ldz = 8'hF4; o_mantissa = i_product[34:12]; end 
    48'b00000000000001??????????????????????????????????: begin fi_ldz = 8'hF3; o_mantissa = i_product[33:11]; end 
    48'b000000000000001?????????????????????????????????: begin fi_ldz = 8'hF2; o_mantissa = i_product[32:10]; end 
    48'b0000000000000001????????????????????????????????: begin fi_ldz = 8'hF1; o_mantissa = i_product[31:09]; end 
    48'b00000000000000001???????????????????????????????: begin fi_ldz = 8'hF0; o_mantissa = i_product[30:08]; end 
    48'b000000000000000001??????????????????????????????: begin fi_ldz = 8'hEF; o_mantissa = i_product[29:07]; end 
    48'b0000000000000000001?????????????????????????????: begin fi_ldz = 8'hEE; o_mantissa = i_product[28:06]; end 
    48'b00000000000000000001????????????????????????????: begin fi_ldz = 8'hED; o_mantissa = i_product[27:05]; end 
    48'b000000000000000000001???????????????????????????: begin fi_ldz = 8'hEC; o_mantissa = i_product[26:04]; end 
    48'b0000000000000000000001??????????????????????????: begin fi_ldz = 8'hEB; o_mantissa = i_product[25:03]; end 
    48'b00000000000000000000001?????????????????????????: begin fi_ldz = 8'hEA; o_mantissa = i_product[24:02]; end 
    48'b000000000000000000000001????????????????????????: begin fi_ldz = 8'hE9; o_mantissa = i_product[23:01]; end 
    48'b0000000000000000000000001???????????????????????: begin fi_ldz = 8'hE8; o_mantissa = i_product[22:00]; end 
    48'b00000000000000000000000001??????????????????????: begin fi_ldz = 8'hE7; o_mantissa = {i_product[21:00],  1'd0}; end 
    48'b000000000000000000000000001?????????????????????: begin fi_ldz = 8'hE6; o_mantissa = {i_product[20:00],  2'd0}; end 
    48'b0000000000000000000000000001????????????????????: begin fi_ldz = 8'hE5; o_mantissa = {i_product[19:00],  3'd0}; end 
    48'b00000000000000000000000000001???????????????????: begin fi_ldz = 8'hE4; o_mantissa = {i_product[18:00],  4'd0}; end 
    48'b000000000000000000000000000001??????????????????: begin fi_ldz = 8'hE3; o_mantissa = {i_product[17:00],  5'd0}; end 
    48'b0000000000000000000000000000001?????????????????: begin fi_ldz = 8'hE2; o_mantissa = {i_product[16:00],  6'd0}; end 
    48'b00000000000000000000000000000001????????????????: begin fi_ldz = 8'hE1; o_mantissa = {i_product[15:00],  7'd0}; end 
    48'b000000000000000000000000000000001???????????????: begin fi_ldz = 8'hE0; o_mantissa = {i_product[14:00],  8'd0}; end 
    48'b0000000000000000000000000000000001??????????????: begin fi_ldz = 8'hDF; o_mantissa = {i_product[13:00],  9'd0}; end 
    48'b00000000000000000000000000000000001?????????????: begin fi_ldz = 8'hDE; o_mantissa = {i_product[12:00], 10'd0}; end 
    48'b000000000000000000000000000000000001????????????: begin fi_ldz = 8'hDD; o_mantissa = {i_product[11:00], 11'd0}; end 
    48'b0000000000000000000000000000000000001???????????: begin fi_ldz = 8'hDC; o_mantissa = {i_product[10:00], 12'd0}; end 
    48'b00000000000000000000000000000000000001??????????: begin fi_ldz = 8'hDB; o_mantissa = {i_product[09:00], 13'd0}; end 
    48'b000000000000000000000000000000000000001?????????: begin fi_ldz = 8'hDA; o_mantissa = {i_product[08:00], 14'd0}; end 
    48'b0000000000000000000000000000000000000001????????: begin fi_ldz = 8'hD9; o_mantissa = {i_product[07:00], 15'd0}; end 
    48'b00000000000000000000000000000000000000001???????: begin fi_ldz = 8'hD8; o_mantissa = {i_product[06:00], 16'd0}; end 
    48'b000000000000000000000000000000000000000001??????: begin fi_ldz = 8'hD7; o_mantissa = {i_product[05:00], 17'd0}; end 
    48'b0000000000000000000000000000000000000000001?????: begin fi_ldz = 8'hD6; o_mantissa = {i_product[04:00], 18'd0}; end 
    48'b00000000000000000000000000000000000000000001????: begin fi_ldz = 8'hD5; o_mantissa = {i_product[03:00], 19'd0}; end 
    48'b000000000000000000000000000000000000000000001???: begin fi_ldz = 8'hD4; o_mantissa = {i_product[02:00], 20'd0}; end 
    48'b0000000000000000000000000000000000000000000001??: begin fi_ldz = 8'hD3; o_mantissa = {i_product[01:00], 21'd0}; end 
    48'b00000000000000000000000000000000000000000000001?: begin fi_ldz = 8'hD2; o_mantissa = {i_product[00:00], 22'd0}; end 
    48'b00000000000000000000000000000000000000000000000?: begin fi_ldz = 8'hD1; o_mantissa =                 23'd0 ; end 
                                                 default: begin fi_ldz = 8'd00; o_mantissa =                 23'd0 ; end  
  endcase
 
booth booth 
  (
    i_product,
    booth_done,
    a_mantissa,
    b_mantissa, 
    clk,
    reset,
    mult_term,
    start
  );

endmodule
