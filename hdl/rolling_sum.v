// Module to produce a rolling sum of waveform samples
// 
// The samples come in groups of four, 
// so the window moves by four samples on each clock cycle
//
// Aaron Fienberg
// September 2019

module rolling_sum #(parameter NGROUPS = 4, // number of groups in the sum
	                       INBITS = 14, // sample bits 
	                       OUTBITS = 18) // n_bits in the output
        (
	input clk,
	input reset_n,
	input[4*INBITS-1:0] d_in, // input data
	input pause,              // stops module from loading samples into the rolling sum 
	                          // should be externally synchronized w/ data inputs 
	output reg valid_out = 0, // indicates that output sum is meaningful 
	                          // true after module has filled its internal buffer
	output reg[OUTBITS-1:0] sum = 0
	);

// record of group sums, 
// the sums of each group of four incoming samples
localparam GSBITS = INBITS + 2; // n_bits in the sum of a group of four samples 
reg[GSBITS*(NGROUPS+1) - 1 : 0] group_sums = 0;

wire[GSBITS-1:0] din_ext[0:3]; // sign extended input data
localparam NMOREGROUP = GSBITS - INBITS;
generate
  	genvar i;
  	for (i = 0; i < 4; i = i+1) begin : din_ext_gen
  	  // sign extend each input sample
  	  assign din_ext[i] = { {NMOREGROUP{d_in[(i+1)*INBITS-1]}},
  	                         d_in[(i+1)*INBITS - 1:i*INBITS]};  
  	end
endgenerate

reg[GSBITS-1:0] new_sum; // sum of the incoming group of data samples
always @(*) begin
	new_sum = din_ext[0] +
		  din_ext[1] +
		  din_ext[2] +
		  din_ext[3];
end

//
// make sign extended version of first and last group sum;
// they will be needed for the rolling sum
//
localparam NMORESUM = OUTBITS - GSBITS;

wire[GSBITS-1:0] newest = group_sums[GSBITS - 1 : 0];
wire[OUTBITS-1:0] newest_ext = {{NMORESUM{newest[GSBITS - 1]}}, newest};

wire[GSBITS-1:0] oldest = group_sums[GSBITS*(NGROUPS + 1) - 1 : 
                                     GSBITS*NGROUPS];
wire[OUTBITS-1:0] oldest_ext = {{NMORESUM{oldest[GSBITS - 1]}}, oldest};

// keep track of pause condition changes
reg was_paused = 0;
always @(posedge clk) begin
  was_paused <= pause;
end

//
// main rolling sum logic
//

localparam S_FILLING = 1'b0,
           S_ROLLING = 1'b1;
reg fsm = S_FILLING;

reg[31:0] counter = 0;
always @(posedge clk) begin
	if (!reset_n) begin
	  fsm <= S_FILLING;
	  sum <= 0;
	  counter <= 0;
	  valid_out <= 0;	  
	end
	else begin
	  valid_out <= 0;
	  
	  if (!pause)
	    // if not paused, shift in a new group sum
	    group_sums <= {group_sums[GSBITS*NGROUPS - 1 : 0], 
	    	           new_sum};
	  
	  case (fsm) 
	    S_FILLING: begin
	    	if (counter == 0)
	    	  sum <= 0;	    	  

	    	else if (!was_paused) begin
	    	  // sign extend before adding
	    	  sum <= sum + newest_ext;
	    	  if (counter == NGROUPS) begin
	    	    fsm <= S_ROLLING;	 
	    	    valid_out <= 1;
	    	  end
	    	end
	    	
	    	if (!pause)
	    	  counter <= counter + 1;
	    end
	    S_ROLLING: begin
	    	if (!was_paused) begin
	    	  // if we weren't paused on the last input sample,
	    	  // update the output sum
	    	  sum <= sum + newest_ext - oldest_ext;	    
	    	end
	    	valid_out <= 1;
	    end
	    default: begin
	    	fsm <= S_FILLING;
	    	sum <= 0;
	    	counter <= 0;
	    end
	  endcase
	end
end


endmodule	                       