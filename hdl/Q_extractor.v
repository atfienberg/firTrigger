//
// Charge (Q) extractor
//
// One charge is extracted for each string of continuously triggered samples
// 
// Charge is guaranteed valid only when valid_out == 1
//
// valid_out will pulse for one clock cycle following the end of a trigger island
//

module Q_extractor #(parameter BITS=31) 
   (
   input clk,
   input reset_n,
   input trig,           // whether these samples triggered
   input signed[BITS-1:0] in_0, // input sample 0
   input signed[BITS-1:0] in_1, // input sample 1
   input signed[BITS-1:0] in_2, // input sample 2
   input signed[BITS-1:0] in_3, // input sample 3

   output valid_out,
   output reg signed[BITS-1:0] Q = 0
   );

// keep track of last two trig conditions
reg[1:0] last_trigs = 2'b0;
always @(posedge clk) last_trigs <= {last_trigs[0], trig};
wire trig_pe = !last_trigs[1] && last_trigs[0]; // positive edge
wire trig_ne = last_trigs[1] && !last_trigs[0]; // negative edge

//
// pipelined comparison logic
//

// greater of in_0 & in_1
reg signed[BITS-1:0] g_01 = 0;
// greater of in_2 & in_3
reg signed[BITS-1:0] g_23 = 0;
// greater of g_01 and g_23
reg signed[BITS-1:0] new_max = 0;
always @(posedge clk) begin
  if (!reset_n) begin
    g_01 <= 0;
    g_23 <= 0;    
    new_max <= 0;
    Q <= 0;
  end

  else begin
    g_01 <= in_0 > in_1 ? in_0 : in_1;
    g_23 <= in_2 > in_3 ? in_2 : in_3;

    new_max <= g_01 > g_23 ? g_01 : g_23;

    if (trig_pe) Q <= 0;
    else Q <= new_max > Q ? new_max : Q;
  end
end

// valid out is trig_ne delayed by 1 cycle,
// accounts for pipeline delay
delay #(.DELAY(1), .BITS(1))
  trig_ne_delay(
  	.clk(clk),
  	.reset_n(reset_n),
  	.d_in(trig_ne),
  	.d_out(valid_out)
  	); 

endmodule	                       