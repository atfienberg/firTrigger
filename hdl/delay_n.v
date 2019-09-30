// Used by delay.v;
// 
// delays by n cycles, where n >= 2
//
// Aaron Fienberg
// September 2019

module delay_n #(parameter DELAY=2,
	                   BITS=56,
	                   DEFAULT=1'b0) (	                    
	input clk,
	input reset_n,
	input[BITS-1:0] d_in, // input data
	output[BITS-1:0] d_out // output data
	);

reg[BITS*DELAY-1:0] old_words = {BITS*DELAY{DEFAULT}};

// output is the highest BITS_PER_SAMPLE bits of old_words
assign d_out = old_words[BITS*DELAY - 1:
                         BITS*(DELAY-1)];

always @(posedge clk) begin
  if (!reset_n) begin
    old_words <= {BITS*DELAY{DEFAULT}};
  end
  else begin
    // shift new data into old_words
    old_words <=
       {old_words[BITS*(DELAY-1) - 1 : 0], d_in};
  end
end

endmodule	                       