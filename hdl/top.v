module top(
	input OSC_60MHz,
	input RESET
	);

// instantiate the trigger module
wire coeff_in_areset, coeff_in_read;  
wire[1:0] coeff_in_adr;
wire[3:0] coeff_in_we;
wire[3:0] coeff_valid;
wire[63:0] coeff_out_port;  	                      
wire[63:0] coeff_in_port; 
wire tot[0:3]; 	
wire[30:0] fout[0:3];
fir_trig #(.BSUM_DELAY(10),
	   .TRIG_WFM_DELAY(6),
	   .BPAUSE_LEN(8)) 
   ftrig
       (
      	.clk(OSC_60MHz),
      	.reset_n(!RESET),
      	// input samples
      	.in_0(14'b1),
      	.in_1(14'b1),
      	.in_2(14'b1),
      	.in_3(14'b1),
      	// output samples
      	.out_0(),
      	.out_1(),
      	.out_2(),
      	.out_3(),
      	// filtered output samples
      	.fout_0(fout[0]),
      	.fout_1(fout[1]),
      	.fout_2(fout[2]),
      	.fout_3(fout[3]),
      	// trigger threshold (input)
      	.thresh(31'h800000),
      	// tot bits
        .tot_0(tot[0]),
      	.tot_1(tot[1]),
      	.tot_2(tot[2]),
      	.tot_3(tot[3]),
      	
      	// baseline sum pause override
      	.pause_override_in(1'b0),
      	.bsum_out(),
      	
      	// filter control and coefficient reloading 
      	.valid_in(1'b1),
      	.fvalid_out(),
      	.out_err(),
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
      	.clk(OSC_60MHz),
      	.reset_n(!RESET),
      	.req(1'b0),
      	.wr_op(1'b0),
      	.ack(),
      	.coeff_wr_data(127'b1),
      	.coeff_rd_data(),
      	.coeff_areset(coeff_in_areset),
      	.coeff_we(coeff_in_we),
      	.coeff_adr(coeff_in_adr),
      	.coeff_in_data(coeff_in_port),
      	.coeff_read(coeff_in_read),
      	.coeff_out_valid(coeff_valid),
      	.coeff_out_data(coeff_out_port)
      );

wire any_trig = tot[0] || tot[1] || tot[2] || tot[3];
wire Q_valid_out;
wire[30:0] Q_out;
Q_extractor Q_ext
   (
   .clk(OSC_60MHz),
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