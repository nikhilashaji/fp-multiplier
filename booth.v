
module booth
# (parameter N = 25)
  (
output wire [(2*N)-3:0] prod,
output reg              mult_done,
input  wire [N-1:0]     mc,    // multiplicand
input  wire [N-1:0]     mp,    // multiplier
input  wire             clk,
input  wire             reset,
input  wire             mult_term,
input  wire             start
);

function integer clogb2;
   input [31:0] value;
   integer 	i;
   begin
      clogb2 = 0;
      for(i = 0; 2**i < N; i = i + 1)
	clogb2 = i;
   end
endfunction

parameter CW = clogb2(N);

reg          Q_1, mult_act;
reg  [N-1:0] A, Q, M;
reg  [ CW:0] count;
wire [N-1:0] ALU, ALU_M, TWOS_COMP_M;

assign TWOS_COMP_M = (~M) + 1'b1;
assign ALU_M       = ({Q[0], Q_1} == 2'b01) ? M : TWOS_COMP_M;
assign ALU         = A + ALU_M;

always @(posedge clk, posedge reset)
  if (reset)
    mult_done <= 1'b0;
  else if (start || mult_term)
    mult_done <= 1'b0;
  else if (count == N-1)
    mult_done <= 1'b1;

always @(posedge clk, posedge reset)
  if (reset)
    mult_act <= 1'b0;
  else if (mult_term)
    mult_act <= 1'b0;
  else if (start)
    mult_act <= 1'b1;
  else if (count == N-1)
    mult_act <= 1'b0;

always @(posedge clk, posedge reset)
  if (reset) begin
    A     <= 'd0;
    M     <= 'd0;
    Q     <= 'd0;
    Q_1   <= 'd0;
    count <= 'd0;
  end
  else if (start || mult_term) begin
    A     <= 'd0;
    M     <= mc;
    Q     <= mp;
    Q_1   <= 1'b0;
    count <=  'd0;
  end
  else if ((Q[0] ^ Q_1) && mult_act)
  begin
    {A, Q, Q_1} <= {ALU[N-1], ALU[N-1:0], Q[N-1:0]};
    count       <= count + 1'b1;
  end
  else if (mult_act)
  begin
    {A, Q, Q_1} <= {A[N-1], A[N-1:0], Q[N-1:0]};
    count       <= count + 1'b1;
  end

assign prod = {A[N-3:0], Q};

endmodule
