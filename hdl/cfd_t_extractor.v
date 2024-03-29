//
// SPE time extractor
// 
// Uses a CFD algorithm with two parameters: shift and delay
//
// Delayed, inverted waveform is essentially multiplied by 2^SHIFT
// 
// RESOLUTION is the number of sub-clocktick bits to include in the extracted time.
// latency increases by one clock tick per additional bit of resolutoin
//
// Delay must be between 1 and 4 (inclusive)
//
// RESOLUTION must be >= 1
//
// Aaron Fienberg
// October 2019


module cfd_t_extractor #(parameter INBITS=14, 
	                           BSUMBITS=18,
	                           DELAY=1,
	                           SHIFT=2,
	                           RESOLUTION=4,
	                           LTC_BITS=32) 
   (
   input clk,
   input reset_n,
   input [LTC_BITS-1:0] ltc,        // time counter for given input samples         
   input [INBITS-1:0] in_0, // input sample 0
   input [INBITS-1:0] in_1, // input sample 1
   input [INBITS-1:0] in_2, // input sample 2
   input [INBITS-1:0] in_3, // input sample 3   
   input tot_0,             // tot for input sample 0
   input tot_1,             // tot for input sample 1
   input tot_2,             // tot for input sample 2
   input tot_3,             // tot for input sample 3
   input [BSUMBITS-1:0] bsum_in, //  baseline sum
   
   input valid_in,           // whether to load the input into the pipeline
   output reg valid_out = 0, // whether t_out is a valid time extraction 

   // LTC_BITS bits for LTC, 2 for sample index in group, plus the RESOLUTION bits
   output reg [LTC_BITS + 2 + RESOLUTION - 1:0] t_out = 0 // the extracted time
   );

// 
// Baseline correct input samples as they come in
//

// number of bits for the baseline corrected samples
localparam CORBITS = BSUMBITS + 1;

// signed input samples
wire[INBITS-1:0] s_in[0:3];
unsigned_to_signed #(.NBITS(INBITS)) convert_s0(.in(in_0), .out(s_in[0]));
unsigned_to_signed #(.NBITS(INBITS)) convert_s1(.in(in_1), .out(s_in[1]));
unsigned_to_signed #(.NBITS(INBITS)) convert_s2(.in(in_2), .out(s_in[2]));
unsigned_to_signed #(.NBITS(INBITS)) convert_s3(.in(in_3), .out(s_in[3]));

// sign extended baseline sum
wire[CORBITS-1:0] bsum_ext = {bsum_in[BSUMBITS - 1], bsum_in};

// baseline corrected input samples
wire[CORBITS-1:0] cor_in[0:3];
// shift, sign extend, subtract baseline
assign cor_in[0] = ((s_in[0] << (BSUMBITS-INBITS)) | 
	            (s_in[0][INBITS-1] << BSUMBITS)) 
                    - bsum_ext;
assign cor_in[1] = ((s_in[1] << (BSUMBITS-INBITS)) | 
	            (s_in[1][INBITS-1] << BSUMBITS)) 
                    - bsum_ext;
assign cor_in[2] = ((s_in[2] << (BSUMBITS-INBITS)) | 
	            (s_in[2][INBITS-1] << BSUMBITS)) 
                    - bsum_ext;
assign cor_in[3] = ((s_in[3] << (BSUMBITS-INBITS)) | 
	            (s_in[3][INBITS-1] << BSUMBITS)) 
                    - bsum_ext;        

//
// This implementation requires a record of the last 8 samples
// and another record of 8 samples which have been inverted, bit shifted
// and delayed by one group relative to the first record
// 
// these operations are handled below
//

// number of bits for the inverted, bit shifted samples
localparam INVBITS = CORBITS + SHIFT;

// sample records
reg[8*CORBITS-1:0] sample_rec = 0; // baseline corrected samples
reg[8*INVBITS-1:0] inv_rec = 0;    // inverted, bit-shifted samples

// sample arrays (convenient aliases into the above records) 
wire[CORBITS-1:0] cor_samps[0:7];
wire[INVBITS-1:0] inv_samps[0:7];

// the newest group of inverted, bit shifted samples
wire[INVBITS-1:0] new_inv[0:3];

// registers for keeping track of LTCs;
// need three sequential LTCs for algorithm to make sense
reg[LTC_BITS-1:0] last_ltc = 0;
// whether the last two LTCS 
// and the two before that were sequential
reg[1:0] was_sequential = 2'b0;

genvar i;
generate
	for (i = 0; i < 8; i = i + 1) begin : sample_vecs
	  assign cor_samps[7 - i] = sample_rec[(i+1)*CORBITS-1:i*CORBITS]; 
	  assign inv_samps[7 - i] = inv_rec[(i+1)*INVBITS-1:i*INVBITS]; 
	end	

	for (i = 0; i < 4; i = i + 1) begin : inversions
	  assign new_inv[i] = -1*(cor_samps[4 + i] << SHIFT);
	end	
endgenerate

// update the records at each rising clock edge
always @(posedge clk) begin
	if (!reset_n) begin
	  sample_rec <= 0;
	  inv_rec <= 0;
	  was_sequential <= 2'b0;
	end
	else if (valid_in) begin
	  sample_rec <= {sample_rec[4*CORBITS - 1:0],
	                 {cor_in[0], cor_in[1], cor_in[2], cor_in[3]}};

	  inv_rec <= {inv_rec[4*INVBITS - 1:0],
	              {new_inv[0], new_inv[1], new_inv[2], new_inv[3]}};

          last_ltc <= ltc;

          was_sequential <= {was_sequential[0], ltc == last_ltc + 1};
        end	                
end

// 
// Sum of the samples and the inverted, delayed samples
// Five of these are needed to find and interpolate the zero crossing
//

localparam SUMBITS = INVBITS + 1;
// n bits to extend the samples before summing 
localparam SEXTEND = SUMBITS - CORBITS;
// n bits to extend the inverted samples before summing 
localparam IEXTEND = SUMBITS - INVBITS;

wire[SUMBITS-1:0] sums[0:4];
generate
	for (i = 0; i < 5; i = i + 1) begin : sum_assignments	  
	  // index in the delayed, inverted array that should be
	  // be summed with index i in the sample array
	  // is i + 4 - DELAY
	  assign sums[i] =  {{SEXTEND{cor_samps[i][CORBITS-1]}}, 
	                     cor_samps[i][CORBITS-1:0]}
	                  + {{IEXTEND{inv_samps[i + 4 - DELAY][INVBITS-1]}}, 
	                      inv_samps[i + 4 - DELAY][INVBITS-1:0]};
	end
endgenerate

// Conditions for sum/cfd waveform to be valid for 0-xing detection:
// 1. A new group was loaded into the pipeline in the previous clock cycle
// 2. The last three loaded groups had sequential LTCs 
// the following reg and wire are used to check these condition
reg was_valid = 0;
always @(posedge clk) was_valid <= valid_in;
wire sequential_ltcs = was_sequential[0] && was_sequential[1];
reg valid_sum = 0;

// must delay the input TOT so it is available 
// at the same time as the sum for the associated samples.
// Must only advance the TOT pipeline when valid_in is 1.
// TOT pipeline is two cycles deep
// 4 bits * 2 cycles = 8 bits
reg[7:0] tot_pline = 0;
always @(posedge clk) begin
	if (!reset_n) tot_pline <= 0;
	else if (valid_in) 
	  tot_pline <= {tot_pline[4:0], 
	  	        {tot_3, tot_2, tot_1, tot_0}};	
end
// delayed tot
wire tot_d[0:3];
assign tot_d[0] = tot_pline[4];
assign tot_d[1] = tot_pline[5];
assign tot_d[2] = tot_pline[6];
assign tot_d[3] = tot_pline[7];
// tot for the registered sum
reg sum_tot[0:3];

// register the sums (aka the cfd waveform)
reg signed[SUMBITS-1:0] r_sums[0:4];
// ltc associated with the sum/cfd waveform is last_ltc - 1
reg[LTC_BITS-1:0] sum_ltc = 0;
integer i_sum;
always @(posedge clk) begin
  sum_ltc <= last_ltc - 1;
  valid_sum <= was_valid && sequential_ltcs;
  
  for (i_sum = 0; i_sum < 5; i_sum = i_sum + 1) begin
    r_sums[i_sum] <= sums[i_sum];

    if (i_sum < 4) 
      sum_tot[i_sum] <= tot_d[i_sum];
  end
end


//
// Zero-crossing detection
//

// store values on left/right of zero-crossing for interpolation
// repeat until desired RESOLUTION is reached
localparam LRBITS = SUMBITS + 1;
reg signed[LRBITS-1:0] lefts[0:RESOLUTION-1];
reg signed[LRBITS-1:0] rights[0:RESOLUTION-1];
wire signed[LRBITS-1:0] lr_sums[0:RESOLUTION-1];
generate
  for (i = 0; i < RESOLUTION; i = i + 1) begin : lr_sum_assign
    assign lr_sums[i] = lefts[i] + rights[i];	
  end
endgenerate

// zero crossing sample index
reg[1:0] crossing_ind = 0;
// whether a crossing was found
reg crossing_found = 0;
integer i_s; // sample index
always @(posedge clk) begin
	crossing_ind <= 0;
	crossing_found <= 0;
	
	if (!reset_n) begin
	  lefts[0] <= 0;
	  rights[0] <= 0;
	end

	else if (valid_sum) begin
	  crossing_found <= 0;
	  crossing_ind <= 0;
	  lefts[0] <= 0;
	  rights[0] <= 0;

	  for (i_s = 0; i_s < 4; i_s = i_s + 1) begin
	  
	    if (sum_tot[i_s] && 
	    	r_sums[i_s] >= 0 && r_sums[i_s + 1] < 0) begin
	      crossing_found <= 1;
	      crossing_ind <= i_s;

	      lefts[0] <= {r_sums[i_s][SUMBITS-1], r_sums[i_s]};
	      rights[0] <= {r_sums[i_s+1][SUMBITS-1], r_sums[i_s+1]};	 
	    end	  
	  
	  end

	end
end

// build up sub-sample RESOLUTION word one bit at a time
reg[RESOLUTION-1:0] ssamp_words[0:RESOLUTION-1]; // pipeline of words representing 
                                                 // zero crossing location between samples
integer i_lr;                              
always @(posedge clk) begin
	if (!reset_n) begin
	  for (i_lr = 0; i_lr < RESOLUTION; i_lr = i_lr + 1) begin
	    ssamp_words[i_lr] <= 0;
	    if (i_lr > 0) begin 
	      // lefts/rights[0] handled by zero-crossing finder above
	      lefts[i_lr] <= 0;
	      rights[i_lr] <= 0;
	    end
	  end
	end

 	// for each l-r pair, check whether zero crossing is 
 	// closer to left side or right side. repeat iteratively
	else begin
	  for (i_lr = 0; i_lr < RESOLUTION; i_lr = i_lr + 1) begin
	    if (lr_sums[i_lr] < 0) begin
	    	// zero crossing closer to the left: new 0 bit
	    	if (i_lr == 0) ssamp_words[0] <= 0;

	    	else begin
	    	  ssamp_words[i_lr] <= ssamp_words[i_lr - 1];
		end

		if (i_lr != RESOLUTION-1) begin
	    	  lefts[i_lr+1] <= lefts[i_lr];
	    	  // midpoint (new right) is lr_sum / 2 w/ manual sign extension
	    	  rights[i_lr+1] <= {lr_sums[i_lr][LRBITS-1], lr_sums[i_lr][LRBITS-1:1]}; 
	    	end
	    end // end if lr_sums >0

	    else begin 
	    	// zero crossing closer to the right: new 1 bit
	    	if (i_lr == 0) ssamp_words[0] <= (1'b1 << (RESOLUTION-1));

	    	else begin
	    	  ssamp_words[i_lr] <= (ssamp_words[i_lr - 1] | 
	    	  	                (1'b1 << (RESOLUTION-1-i_lr)));
	    	end

	    	if (i_lr != RESOLUTION-1) begin
	    	  // midpoint (new left) is lr_sum / 2
	    	  lefts[i_lr + 1] <= lr_sums[i_lr] >> 1;
	    	  rights[i_lr + 1] <= rights[i_lr];
	    	end
	    end
	  end // end loop over RESOLUTION bits
	end
end                               

//
// Prepare / align output data
//

// crossing index and crossing_found must be delayed by RESOLUTION 
// to allow for time to calculate the subsample RESOLUTION bits
wire[1:0] crossing_ind_d;
delay #(.DELAY(RESOLUTION), .BITS(2)) 
  c_ind_delay(.clk(clk), .reset_n(reset_n), 
  	      .d_in(crossing_ind), 
  	      .d_out(crossing_ind_d));

wire out_rdy;
delay #(.DELAY(RESOLUTION), .BITS(1)) 
  c_found_delay(.clk(clk), .reset_n(reset_n), 
  	        .d_in(crossing_found), 
  	        .d_out(out_rdy));


// output_ltc is sum_ltc delayed by RESOUTION + 1 clock ticks
// (1 cycle to find the group idx, RESOLUTION for the resolution bits)
wire[LTC_BITS-1:0] output_ltc;
delay #(.DELAY(RESOLUTION + 1), .BITS(LTC_BITS)) 
  c_ltc_delay(.clk(clk), .reset_n(reset_n), 
  	      .d_in(sum_ltc), 
  	      .d_out(output_ltc));

//
// register the outputs
//

always @(posedge clk) begin
  valid_out <= 0;
  if (out_rdy) begin 
    t_out <= {output_ltc, 
  	      crossing_ind_d, 
  	      ssamp_words[RESOLUTION-1]};
    valid_out <= 1;
  end
end

endmodule
	                       