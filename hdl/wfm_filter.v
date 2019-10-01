// Waveform filter that takes four parallelized samples as input
// and produces four parallelized filter samples as output
// Example:
// input [s0, s1, s2, s3], [s4, s5, s6, s7] 
// to output [f0, f1, f2, f3], [f4, f5, f6, f7]
// where f_n is the nth filtered output sample
// 
// Latency depends on how one wants to interpret the filtered output in 
// light of the reloadable coefficients.
// 
// There are three clock cycles of latency between the first
// valid input and the first valid output 
//
// Aaron Fienberg
// September 2019

module wfm_filter(
	input clk,
	input reset_n,
	input valid_in, // whether input is valid
	input[75:0] in_data, // input samples
	output reg valid_out = 0, // whether output is valid
	output reg[7:0] out_err = 0, // output errors
	output reg[123:0] out_data = 0, // output samples
	input coeff_in_clk, 
	input coeff_in_areset,
	input[3:0] coeff_in_we,
	input[1:0] coeff_in_adr, // coeff adr fanned out to all internal filters
	input[63:0] coeff_in_data, // new coefficient data
	input coeff_in_read,
	output[3:0] coeff_out_valid,
	output[63:0] coeff_out_data
	);

localparam nbits_in = 19;
localparam nbits_out = 31;
// number of bits in the raw core filter outputs
localparam nbits_rout = 29;
localparam nbits_coeff = 16;

// sign-extended core filter outputs
wire[nbits_out-1:0] core_outputs[0:3][0:3];

// combine the core filter outputs to get the
// fully filtered output waveform
integer i, j;
reg[nbits_out-1:0] d_out_array[0:3];
always @(*) begin
	for (i = 0; i < 4; i=i+1) begin
	  d_out_array[i] = {nbits_out{1'b0}};
	  // output i is the row sum over column i 
	  // of the core_outputs matrix
	  for (j = 0; j < 4; j=j+1) begin
	    d_out_array[i] = d_out_array[i]
	                   + core_outputs[j][i];
	  end
	end	
end

wire[123:0] next_out_data = 
	{
	d_out_array[3],
	d_out_array[2],
	d_out_array[1],
	d_out_array[0]
	};

// last set of four input samples
reg[4*nbits_in-1:0] last_in_data = 0;

// valid out will be the and of all the valid_outs
// from the internal filters
wire[3:0] core_valid_out;
wire next_valid_out;
assign next_valid_out = 
	    core_valid_out[0] &&
	    core_valid_out[1] &&
	    core_valid_out[2] &&
	    core_valid_out[3];

// update last_in_data, valid_out, out_data, out_err
// at each clock edge
wire[7:0] next_out_err;
always @(posedge clk) begin
	if (!reset_n) begin
	  last_in_data <= {4*nbits_in{1'b0}};
	  out_data <= 0;
	  valid_out <= 0;
	  out_err <= 0;
	end
	else begin
	  last_in_data <= in_data;
	  out_data <= next_out_data;
	  valid_out <= next_valid_out;
	  out_err <= next_out_err;
	end
end

//
// The four core filters
//

// build input data arrays to make the code below easier
// to write and follow

// 8 most recent samples
wire[nbits_in-1:0] d_in_array[0:7];
// new coefficient inputs
wire[nbits_coeff-1:0] coeff_in_array[0:3];
// the core filter inputs
wire[4*nbits_in-1:0] f_in[0:3];

// assign the input arrays 
generate
	genvar k_in;
	for (k_in = 0; k_in < 4; k_in = k_in + 1) begin : input_gen
    	  assign d_in_array[k_in] = 
  	    last_in_data[nbits_in*(k_in+1) - 1:nbits_in*k_in];

  	  assign d_in_array[k_in+4] =
  	    in_data[nbits_in*(k_in+1) - 1:nbits_in*k_in];
  	  
  	  assign coeff_in_array[k_in] =
	  	coeff_in_data[nbits_coeff*(k_in+1) - 1 : 
	  		      nbits_coeff * k_in];

	  assign f_in[k_in] = {
	  	d_in_array[6 - k_in],
	  	d_in_array[5 - k_in],
	  	d_in_array[4 - k_in],
	  	d_in_array[3 - k_in]
	  };
  	end
endgenerate

// Similarly, I will package the outputs into arrays
wire[4*nbits_rout - 1:0] f_out[0:3]; // outputs of the four internal filters
generate
	genvar k_out, k_chan;
	for (k_out = 0; k_out < 4; k_out = k_out + 1) begin : output_gen
	  for (k_chan = 0; k_chan < 4; k_chan = k_chan + 1) begin : output_chan_gen
	    // core_output is sign extended filter output
	    assign core_outputs[k_out][k_chan] = 
	        {{2{f_out[k_out][nbits_rout*(k_chan+1) - 1]}},
	          f_out[k_out][nbits_rout*(k_chan+1) - 1 : nbits_rout*k_chan]};	    
	  end
	end
endgenerate
 
// output for reading coefficients
wire[nbits_coeff-1:0] coeff_out_array[0:3];
assign coeff_out_data = {
	coeff_out_array[3],
	coeff_out_array[2],
	coeff_out_array[1],
	coeff_out_array[0]
};
 
// now generate the internal filters
generate
	genvar k_filt;
	for (k_filt = 0; k_filt < 4; k_filt = k_filt + 1) begin : filter_gen
	  filter_core f(
	  	.clk(clk),
		.reset_n(reset_n),
		.ast_sink_data(f_in[k_filt]),
		.ast_sink_valid(valid_in),
		.ast_sink_error(2'b0),
		.ast_source_data(f_out[k_filt]),
		.ast_source_valid(core_valid_out[k_filt]),
		.ast_source_error(next_out_err[2*(k_filt + 1) - 1 : 2*k_filt]),
		.coeff_in_clk(clk),
		.coeff_in_areset(coeff_in_areset),
		.coeff_in_address(coeff_in_adr),
		.coeff_in_read(coeff_in_read),
		.coeff_out_valid(coeff_out_valid[k_filt]),
		.coeff_out_data(coeff_out_array[k_filt]),
		.coeff_in_we(coeff_in_we[k_filt]),
		.coeff_in_data(coeff_in_array[k_filt])
	  	);
	end
endgenerate

endmodule