//
// Baseline corrected FIR filter based triggering module
//
// input: waveform samples
// output: tot bits, delayed samples, filtered samples, baseline sum
//
// Aaron Fienberg
// September 2019

module fir_trig #(parameter BSUM_DELAY=10, 
	                    TRIG_WFM_DELAY=6,
	                    BPAUSE_LEN=8)   
   (
   input clk, 
   input reset_n, 
   // sample input and output
   input[13:0] in_0, // input sample 0
   input[13:0] in_1, // input sample 1
   input[13:0] in_2, // input sample 2
   input[13:0] in_3, // input sample 3
   output[13:0] out_0, // output sample 0
   output[13:0] out_1, // output sample 1
   output[13:0] out_2, // output sample 2
   output[13:0] out_3, // output sample 3
   output[30:0] fout_0, // filtered output sample 0
   output[30:0] fout_1, // filtered output sample 1
   output[30:0] fout_2, // filtered output sample 2
   output[30:0] fout_3, // filtered output sample 3

   // trigger control and output
   input signed[30:0] thresh,   // trigger threshold,
   output tot_0, // time over threshod 0
   output tot_1, // time over threshod 1
   output tot_2, // time over threshod 2
   output tot_3, // time over threshod 3

   // baseline sum output and control
   input pause_override_in,  // override baseline sum pause control;
                             // 1 -> include all new samples in bsum
   input bsum_reset,         // pulse this to reset the rolling baseline sum 
                             // note: following a bsum_reset, 
                             // the filter output will be temporarily invalid
   output[17:0] bsum_out,    // baseline sum used to correct the
                             // given output samples

   // filter control and coefficient reloading
   input valid_in,        // whether input samples are valid 
                           // for filtering
   output fvalid_out,      // whether filter output is valid
   output[7:0] out_err,    // output errors

   input coeff_in_areset,  
   input[3:0] coeff_in_we,
   input[1:0] coeff_in_adr, // coeff adr fanned out to all internal filters
   input[63:0] coeff_in_data, // new coefficient data
   input coeff_in_read,
   output[3:0] coeff_out_valid,
   output[63:0] coeff_out_data
   ); 

// two's complement converted input samples
// (signed input)
wire[13:0] s_in[0:3];

// create input/output ports for delay paths
wire[55:0] in_p = {in_3, in_2, in_1, in_0}; // input samples
wire[55:0] s_in_p = {s_in[3], s_in[2], 
	             s_in[1], s_in[0]};
wire[55:0] bsum_in_p;
wire[55:0] d_wfm_p;

// convert input samples from offset binary to two's complement
unsigned_to_signed convert_s0(.in(in_0), .out(s_in[0]));
unsigned_to_signed convert_s1(.in(in_1), .out(s_in[1]));
unsigned_to_signed convert_s2(.in(in_2), .out(s_in[2]));
unsigned_to_signed convert_s3(.in(in_3), .out(s_in[3]));

// wire up the delays
// delay for output sample alignment
delay #(.DELAY(TRIG_WFM_DELAY), .BITS(56)) 
   wfm_d(
	.clk(clk),
	.reset_n(reset_n),
	.d_in(in_p),
	.d_out(d_wfm_p) 
	);

// delay for baseline sum input
delay #(.DELAY(BSUM_DELAY - 1), .BITS(56))
   sum_in_d(
	.clk(clk),
	.reset_n(reset_n),
	.d_in(s_in_p),
	.d_out(bsum_in_p)
	);

//
// pulse extenders to manage baseline sum pausing
//
wire bsum_pause;
wire any_trigs = ( tot_0 > 0 || 
		   tot_1 > 0 ||
		   tot_2 > 0 ||
		   tot_3 > 0);
pulse_extender #(.N_TO_EXTEND(BPAUSE_LEN)) 
    trig_extender (
   	.clk(clk),
   	.reset_n(reset_n),
   	.in(any_trigs), 
   	.out(bsum_pause)
        );

// generate intenal pause override signal
// triggered by b_sum_reset pulses
// note: +3 for valid_in -> valid_out latency
wire int_pause_override; 
pulse_extender #(.N_TO_EXTEND(BPAUSE_LEN + 3)) 
   bsum_rst_extender (
   	.clk(clk),
   	.reset_n(reset_n),
   	.in(bsum_reset),
   	.out(int_pause_override)
	);
// pause override is or of input pause override 
// and internally generated pause override
wire pause_override = pause_override_in || int_pause_override;
   	
// baseline summer

// delay valid_in to use with baseline summer
wire valid_in_d;
delay #(.DELAY(BSUM_DELAY-1), .BITS(1))
  vin_d(.clk(clk), .reset_n(reset_n), 
  	.d_in(valid_in), .d_out(valid_in_d));

wire [17:0] bsum;
wire bsum_valid_out;
rolling_sum #(.NGROUPS(4))
   sum(
	.clk(clk),
	.reset_n(reset_n && !bsum_reset),
	.d_in(bsum_in_p),
	.pause((bsum_pause && !pause_override) || !valid_in_d),
	.valid_out(bsum_valid_out),
	.sum(bsum)
	);

// output baseline sum is bsum
// delayed by TRIG_WFM_DELAY 
delay #(.DELAY(TRIG_WFM_DELAY), .BITS(18))
   sum_out_d(
	.clk(clk),
	.reset_n(reset_n),
	.d_in(bsum),
	.d_out(bsum_out)
	);

// baseline corrected input samples:
// 1. sign extend baseline sum
// 2. scale & sign extend input samples
// 3. corrected_samples = (2.) - (1.) 
wire[18:0] bsum_ext = {bsum[17], bsum};
// baseline corrected samples
wire[18:0] s_cor[0:3];
// multiply signed input samples by 16 and sign extend one bit
assign s_cor[0] = ((s_in[0] << 4) | (s_in[0][13] << 18)) 
                                         - bsum_ext;
assign s_cor[1] = ((s_in[1] << 4) | (s_in[1][13] << 18)) 
                                         - bsum_ext;
assign s_cor[2] = ((s_in[2] << 4) | (s_in[2][13] << 18)) 
                                         - bsum_ext;
assign s_cor[3] = ((s_in[3] << 4) | (s_in[3][13] << 18)) 
                                         - bsum_ext;

//
// FIR filter
//

// filter input port
wire[75:0] fin_p = {s_cor[3], s_cor[2], s_cor[1], s_cor[0]};
wire[123:0] fout_p;
wire raw_valid_out;
wfm_filter filt(
  	.clk(clk),
  	.reset_n(reset_n),
  	.valid_in(valid_in && bsum_valid_out),
  	.in_data(fin_p),
  	.valid_out(raw_valid_out),
  	.out_err(out_err),
  	.out_data(fout_p),
  	.coeff_in_clk(clk),
  	.coeff_in_areset(coeff_in_areset),
  	.coeff_in_we(coeff_in_we),
  	.coeff_in_adr(coeff_in_adr),
  	.coeff_in_data(coeff_in_data),
  	.coeff_in_read(coeff_in_read),
  	.coeff_out_valid(coeff_out_valid),
  	.coeff_out_data(coeff_out_data)
  	);

// wfm_filter is happy to provide filtered outputs with 
// intermediate samples missing. 
// For this application, I want the output to be considered valid
// only if four contiguous, baseline corrected input samples were included
// in the output. The logic below achieves this 
wire fout_invalid;
pulse_extender #(.N_TO_EXTEND(4)) 
    invalid_extender (
   	.clk(clk),
   	.reset_n(reset_n),
   	.in(!raw_valid_out), 
   	.out(fout_invalid)
       );
assign fvalid_out = !fout_invalid;

// wire up output data and TOTs 
wire signed[30:0] fout_a[0:3];
wire[13:0] out_a[0:3];
wire tot_a[0:3];
generate
	genvar i;
	for (i = 0; i < 4; i = i + 1) begin: assign_outputs
	  assign fout_a[i] = fout_p[31*(i+1)-1:31*i];
	  assign out_a[i] = d_wfm_p[14*(i+1)-1:14*i];

	  // TOT: if output is valid, compare f_out to threshold 
	  assign tot_a[i] = fvalid_out && 
	                    (fout_a[i] > thresh);
	end
endgenerate

assign fout_0 = fout_a[0];
assign fout_1 = fout_a[1];
assign fout_2 = fout_a[2];
assign fout_3 = fout_a[3];

assign out_0 = out_a[0];
assign out_1 = out_a[1];
assign out_2 = out_a[2];
assign out_3 = out_a[3];

assign tot_0 = tot_a[0];
assign tot_1 = tot_a[1];
assign tot_2 = tot_a[2];
assign tot_3 = tot_a[3];
 
endmodule  
