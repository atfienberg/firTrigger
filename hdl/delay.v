// Module to delay a word by a small number of clock cycles
// 
// delay must be >= 1
// 
// do not use this module to delay by more than a handful of cycles
//
// Aaron Fienberg
// September 2019

module delay #(parameter DELAY=2,
	                 BITS=56,
	                 DEFAULT=1'b0) (	                    
	input clk,
	input reset_n,
	input[BITS-1:0] d_in, // input data
	output[BITS-1:0] d_out // output data
	);

generate
  // delay = 1 case
  if (DELAY == 1) begin : delay_one
    delay_one #(.BITS(BITS), .DEFAULT(DEFAULT))
      d1(.clk(clk), .reset_n(reset_n),
    	 .d_in(d_in), .d_out(d_out));
  end 

  // delay > 1 case
  else begin : delay_n
    delay_n #(.BITS(BITS),
    	      .DELAY(DELAY),
    	      .DEFAULT(DEFAULT))
      dn(.clk(clk), .reset_n(reset_n),
         .d_in(d_in), .d_out(d_out));
  end
endgenerate

endmodule	                       