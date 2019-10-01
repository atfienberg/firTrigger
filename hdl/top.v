module top(
	input OSC_60MHZ,
	input RESET,
	input[13:0] in0,
	input[13:0] in1,
	input[13:0] in2,
	input[13:0] in3,
	input[30:0] thresh,

	input coeff_wr_data,
	input coeff_req,
	input coeff_wr_op,
	input valid_in,
	input pause_override_in,

	output[13:0] o0,	
	output[13:0] o1,	
	output[13:0] o2,	
	output[13:0] o3,	
	output[30:0] fo1,	
	output[30:0] fo2,	
	output[30:0] fo3,	
	output tot0,	
	output tot1,	
	output tot2,	
	output tot3,	
	output[30:0] fo0,	
	output[17:0] bsum_out,
	output fvalid_out,
	output coeff_rd_data,
	output coeff_ack,
	output[7:0] out_err,

	output[30:0] Q_out,
	output Q_valid_out

	);

// instantiate the trigger module
wire coeff_in_areset, coeff_in_read;  
wire coeff_in_we, coeff_valid;
wire[63:0] coeff_out_port;  	                      
wire[63:0] coeff_in_port; 
wire coeff_in_adr;
wire tot[0:3]; 	
wire[30:0] fout[0:3];
assign fo0 = fout[0];
assign fo1 = fout[1];
assign fo2 = fout[2];
assign fo3 = fout[3];
assign tot0 = tot[0];
assign tot1 = tot[1];
assign tot2 = tot[2];
assign tot3 = tot[3];

fir_trig #(.BSUM_DELAY(10),
	   .TRIG_WFM_DELAY(6),
	   .BPAUSE_LEN(8)) 
   ftrig
       (
      	.clk(OSC_60MHZ),
      	.reset_n(!RESET),
      	// input samples
      	.in_0(in0),
      	.in_1(in1),
      	.in_2(in2),
      	.in_3(in3),
      	// output samples
      	.out_0(o0),
      	.out_1(o1),
      	.out_2(o2),
      	.out_3(o3),
      	// filtered output samples
      	.fout_0(fout[0]),
      	.fout_1(fout[1]),
      	.fout_2(fout[2]),
      	.fout_3(fout[3]),
      	// trigger threshold (input)
      	.thresh(thresh),
      	// tot bits
        .tot_0(tot[0]),
      	.tot_1(tot[1]),
      	.tot_2(tot[2]),
      	.tot_3(tot[3]),
      	
      	// baseline sum pause override
      	.pause_override_in(pause_override_in),
      	.bsum_out(bsum_out),
      	
      	// filter control and coefficient reloading 
      	.valid_in(valid_in),
      	.fvalid_out(fvalid_out),
      	.out_err(out_err),
      	.coeff_in_areset(coeff_in_areset),
      	.coeff_in_we(coeff_in_we),
      	.coeff_in_adr(coeff_in_adr),
      	.coeff_in_data(coeff_in_port),
      	.coeff_in_read(coeff_in_read),
      	.coeff_out_valid(coeff_valid),
      	.coeff_out_data(coeff_out_port)
       ); 

fir_coeff_master cm 
       (
      	.clk(OSC_60MHZ),
      	.reset_n(!RESET),
      	.req(coeff_req),
      	.wr_op(coeff_wr_op),
      	.ack(coeff_ack),
      	.coeff_wr_data(coeff_wr_data),
      	.coeff_rd_data(coeff_rd_data),
      	.coeff_areset(coeff_in_areset),
      	.coeff_we(coeff_in_we),
      	.coeff_adr(coeff_in_adr),
      	.coeff_in_data(coeff_in_port),
      	.coeff_read(coeff_in_read),
      	.coeff_out_valid(coeff_valid),
      	.coeff_out_data(coeff_out_port)
      );

wire any_trig = tot[0] || tot[1] || tot[2] || tot[3];
Q_extractor Q_ext
   (
   .clk(OSC_60MHZ),
   .reset_n(!RESET),
   .trig(any_trig),
   .in_0(fout[0]),
   .in_1(fout[1]),
   .in_2(fout[2]),
   .in_3(fout[3]),
   .valid_out(Q_valid_out),
   .Q(Q_out)
   );

endmodule