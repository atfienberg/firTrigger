// Used by wfm_delay;
// 
// delays by one cycle
//
// Aaron Fienberg
// September 2019

module delay_one #(parameter BITS=56, 
	                     DEFAULT=1'b0) (
	input clk,
	input reset_n,
	input[BITS-1:0] d_in, // input data
	output reg[BITS-1:0] d_out = {BITS{DEFAULT}} // output data
	);

always @(posedge clk) begin
  if (!reset_n) begin
    d_out <= {BITS{DEFAULT}};
  end
  else begin
    d_out <= d_in;
  end
end

endmodule	                       