// Aaron Fienberg
//
// Test of the FIR_TRIG module
//
//

`timescale 1ns/1ns

//////////////////////////////////////////////////////////////////////////////////////////////////
// Test cases
//////////////////////////////////////////////////////////////////////////////////////////////////
`define TEST_CASE_2

module tb();
   
   // 0 for pause override test, 
   // 1 for bsum_reset test
   localparam PAUSE_OVERRIDE_MODE=0;

   localparam RAMP_TEST = 0;

   // trig threshold
   reg[30:0] thresh = 31'h18000;
   
   parameter CLK_PERIOD = 20;
   reg clk;

   parameter COEFF_CLK_PERIOD = 100;
   reg coeff_clk;
   
   //////////////////////////////////////////////////////////////////////
   // Clock Drivers
   //////////////////////////////////////////////////////////////////////
   always @(clk)
     #(CLK_PERIOD / 2.0) clk <= !clk;


   always @(coeff_clk)
     #(COEFF_CLK_PERIOD / 2.0) coeff_clk <= !coeff_clk;

   // input/output data
   reg rst;
   reg[13:0] din[0:3];
   wire[13:0] dout[0:3];
   wire[30:0] fout[0:3];
   wire[17:0] bsum_out;
   wire[3:0] tot;

   // wires for coefficient reloading 
   wire coeff_in_areset, coeff_in_read;
   wire[7:0] err_out;
   wire[1:0] coeff_in_adr;
   wire[3:0] coeff_in_we;
   wire[3:0] coeff_valid;
   wire[15:0] coeff_in_data[0:3];
   wire[15:0] coeff_out_data[0:3];
   wire[63:0] coeff_out_port;  	                      
   wire[63:0] coeff_in_port;  	                      
   generate
  	genvar k;
  	for (k = 0; k < 4; k = k + 1) begin
  	  assign coeff_out_data[k] =
  	    coeff_out_port[16*(k+1) - 1 : 16 * k];
  	  assign coeff_in_data[k] =
  	    coeff_in_port[16*(k+1) - 1 : 16 * k];  	  
  	end
   endgenerate

   // filter input flags
   reg valid_in = 0;
   reg pause_override = 0;
   reg bsum_reset = 0;
   // filter output flags
   wire fvalid_out;

   // instantiate the trigger module
   fir_trig #(.BSUM_DELAY(11),
   	      .TRIG_WFM_DELAY(7),
   	      .BPAUSE_LEN(8)) 
      ftrig(
      	   .clk(clk),
      	   .reset_n(!rst),
      	   // input samples
      	   .in_0(din[0]),
      	   .in_1(din[1]),
      	   .in_2(din[2]),
      	   .in_3(din[3]),
      	   // output samples
      	   .out_0(dout[0]),
      	   .out_1(dout[1]),
      	   .out_2(dout[2]),
      	   .out_3(dout[3]),
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
      	   .pause_override_in(pause_override),
      	   .bsum_reset(bsum_reset),
      	   .bsum_out(bsum_out),
      	   
      	   // filter control and coefficient reloading 
      	   .valid_in(valid_in),
      	   .fvalid_out(fvalid_out),
      	   .out_err(err_out),
      	   .coeff_in_clk(coeff_clk),
      	   .coeff_in_areset(coeff_in_areset),
      	   .coeff_in_we(coeff_in_we),
      	   .coeff_in_adr(coeff_in_adr),
      	   .coeff_in_data(coeff_in_port),
      	   .coeff_in_read(coeff_in_read),
      	   .coeff_out_valid(coeff_valid),
      	   .coeff_out_data(coeff_out_port)
           ); 

   // coefficient reloading master
   reg coeff_req = 0;
   reg coeff_wr_op = 0;
   wire coeff_ack;

   reg[127:0] coeff_wr_data;
   wire[127:0] coeff_rd_data;

   fir_coeff_master cm 
      (
      	.clk(coeff_clk),
      	.reset_n(!rst),
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

   // Q extractor
   wire any_trig = tot[0] || tot[1] || tot[2] || tot[3];
   wire Q_valid_out;
   wire[30:0] Q_out;
   Q_extractor Q_ext
      (
      .clk(clk),
      .reset_n(!rst),
      .trig(any_trig),
      .in_0(fout[0]),
      .in_1(fout[1]),
      .in_2(fout[2]),
      .in_3(fout[3]),
      .valid_out(Q_valid_out),
      .Q(Q_out)
      );

   wire[7:0] coeff_read_array[0:15];
   
   generate
     genvar i_rd;
     for (i_rd = 0; i_rd < 16; i_rd = i_rd + 1) begin
     	assign coeff_read_array[i_rd] = 
     	  coeff_rd_data[8*(i_rd+1) - 1:8*i_rd];
     end
   endgenerate	

   // test the cfd_t_extractor
   // reg[31:0] group_num = -30; // sample group number
   reg[31:0] group_num = -1; // sample group number
   wire t_valid_out;
   wire[37:0] t_out;

   reg cfd_valid_in;
   reg[13:0] cfd_in[0:3];
   reg cfd_tot_in[0:3];
   reg[17:0] cfd_bsum_in;

   reg[31:0] cfd_ltc;

   cfd_t_extractor t_ext
     (
       .clk(clk),
       .reset_n(!rst),
       .ltc(cfd_ltc),
       .in_0(cfd_in[0]),
       .in_1(cfd_in[1]),
       .in_2(cfd_in[2]),
       .in_3(cfd_in[3]),
       .tot_0(cfd_tot_in[0]),
       .tot_1(cfd_tot_in[1]),
       .tot_2(cfd_tot_in[2]),
       .tot_3(cfd_tot_in[3]),
       .bsum_in(cfd_bsum_in),
       .valid_in(cfd_valid_in),
       .valid_out(t_valid_out),
       .t_out(t_out)
     );


   reg coeff_op_req = 0;
   reg reading_samples=0;
   integer data_file;
   integer scan_file;
   reg[7:0] new_coeff;
   initial begin
        // Initializations
        clk = 1'b0;
        coeff_clk = 1'b1;
  	rst = 1'b0;
  	din[0] = 0;
  	din[1] = 0;
  	din[2] = 0;
  	din[3] = 0;

   	data_file = $fopen("coeffs.txt", "r");
   	if (data_file == 0) begin
   	  $display("could not open file");
   	  $finish();
   	end

   	// load coeffs into variable
   	while (!$feof(data_file)) begin
	    scan_file = $fscanf(data_file, "%d\n", new_coeff);
  	    coeff_wr_data = {new_coeff, coeff_wr_data[127:8]};
	end

	$fclose(data_file);
   end

   reg coeff_op_done = 0;
   initial begin
	// Logging
        $display("");
        $display("------------------------------------------------------");
        $display("FIR FILTER & CFD TEST");

        coeff_req <= 0;

        #(CLK_PERIOD)
        rst = 1'b1;

        // Reset
	#(2 * CLK_PERIOD);
        rst = 1'b0;
      
        #(1.5*CLK_PERIOD)
        coeff_wr_op <= 1;
        coeff_op_req = 1;

        @(posedge coeff_op_done) #(1*CLK_PERIOD);
        coeff_wr_data <= 0;
       	coeff_wr_op <= 0;
       	coeff_op_req <= 1;

       	@(posedge coeff_op_done) #(2*CLK_PERIOD);

        reading_samples <= 1;
        if (RAMP_TEST)
	  data_file = $fopen("../../jupyter-notebooks/ramp_wfm.txt", "r");
        else
	  data_file = $fopen("../../jupyter-notebooks/fake_pulse.txt", "r");
   end

   // block for handling coeff ops
   reg ack_prev = 0;
   always @(posedge clk) begin
     ack_prev <= coeff_ack;
    
     if (coeff_op_req) begin
     	coeff_req <= 1;
     	coeff_op_done <= 0;
     	coeff_op_req <= 0;
     end

     if (coeff_ack == 1) coeff_req <= 0;

     // ack negative edge -> op done
     if (ack_prev && !coeff_ack) begin
       coeff_op_done <= 1;       
     end
   end

   // block for reading samples
   reg[31:0] sample;
 
   always @(posedge clk) begin
     	if (reading_samples) begin
          rst <= 0;
     	  group_num <= group_num + 1;
     	  
          valid_in <= 1;
  	  if (!$feof(data_file)) begin
  	    scan_file = $fscanf(data_file, "%d\n", sample);
  	    din[0] <= sample;
  	  end
  	  if (!$feof(data_file)) begin
  	    scan_file = $fscanf(data_file, "%d\n", sample);
  	    din[1] <= sample;
  	  end
  	  if (!$feof(data_file)) begin
  	    scan_file = $fscanf(data_file, "%d\n", sample);
  	    din[2] <= sample;
  	  end
  	  if (!$feof(data_file)) begin
  	    scan_file = $fscanf(data_file, "%d\n", sample);
  	    din[3] <= sample;
  	  end
  	  else begin
  	    $fclose(data_file);
  	    reading_samples <= 0;
  	  end  	  
  	end
   end

// monitor for infinite triggering
reg[31:0] trig_len = 0;
reg[31:0] override_counter;

parameter OVERRIDE_LEN = 20;

always @(posedge clk) begin
 	override_counter <= 0;
 	pause_override <= 0;
 	bsum_reset <= 0;
 	if (any_trig && trig_len != OVERRIDE_LEN - 1)
 	  trig_len <= trig_len + 1;
 
 	else if (!any_trig)
 	  trig_len <= 0;

 	else if (trig_len == OVERRIDE_LEN - 1) begin
 	  // fix w/ pause override
 	  if (PAUSE_OVERRIDE_MODE == 0) 
 	    pause_override <= 1;
 	  else if (PAUSE_OVERRIDE_MODE == 1) begin
 	    // fix w/ bsum_reset
 	    bsum_reset <= 1;
 	    trig_len <= 0; // comment out for pause_override mode
 	  end

 	  override_counter = override_counter + 1;
 	  if (override_counter == OVERRIDE_LEN - 1) begin
 	    trig_len <= 0;
 	  end
 	end
end


// inputs to the cfd
`ifdef TEST_CASE_1
// test 1: just put the filter outputs directly into it
integer i_cfd;
always @(*) begin
	for (i_cfd = 0; i_cfd < 4; i_cfd = i_cfd + 1) begin
	  cfd_in[i_cfd] = dout[i_cfd];
	  cfd_tot_in[i_cfd] = tot[i_cfd];	  
	end

	cfd_bsum_in = bsum_out;
     cfd_valid_in = fvalid_out;
     cfd_ltc = group_num;
end 

`endif

`ifdef TEST_CASE_2
// test 2: toggle the cfd input on and off
localparam TOG_PERIOD = 4;
reg[55:0] dout_buffer[0:100];
reg[17:0] bsum_out_buffer[0:100];
reg[3:0] tot_out_buffer[0:100];
reg[31:0] grp_num_buf[0:100];
integer i_buf = 0;
integer i_samp = 0;
integer i_toggle;
always @(posedge clk) begin
  if (fvalid_out) begin
    dout_buffer[i_buf] <= {dout[3], dout[2], dout[1], dout[0]};
    tot_out_buffer[i_buf] <= {tot[3], tot[2], tot[1], tot[0]};
    bsum_out_buffer[i_buf] <= bsum_out;
    grp_num_buf[i_buf] <= group_num;
    i_buf <= i_buf + 1;
  end

  if (i_buf % TOG_PERIOD == 1) begin
    i_toggle = i_buf / TOG_PERIOD;

    cfd_in[0] <= dout_buffer[i_toggle][13:0];
    cfd_in[1] <= dout_buffer[i_toggle][27:14];
    cfd_in[2] <= dout_buffer[i_toggle][41:28];
    cfd_in[3] <= dout_buffer[i_toggle][55:42];
    
    cfd_tot_in[0] <= tot_out_buffer[i_toggle][0];
    cfd_tot_in[1] <= tot_out_buffer[i_toggle][1];
    cfd_tot_in[2] <= tot_out_buffer[i_toggle][2];
    cfd_tot_in[3] <= tot_out_buffer[i_toggle][3];
    
    cfd_bsum_in <= bsum_out_buffer[i_toggle];

    cfd_ltc <= grp_num_buf[i_toggle];

    cfd_valid_in <= 1;
  end
  else cfd_valid_in <= 0;
end
`endif

endmodule