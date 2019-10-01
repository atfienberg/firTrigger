//
// Module for managing filter coefficient reading/writing
//
// Aaron Fienberg
// September 2019

module fir_coeff_master
   (
   input clk,
   input reset_n,

   // operation req/ack
   input req,
   input wr_op, // 1 indicates write op, 0 read
   output reg ack,

   // input/output coeff data
   input[127:0] coeff_wr_data,
   output reg[127:0] coeff_rd_data = 0,

   // connections to the filter
   output reg coeff_areset,  
   output reg[3:0] coeff_we,
   output reg[1:0] coeff_adr, 
   
   output[63:0] coeff_in_data, // into the filter
   output reg coeff_read = 0,
   input[3:0] coeff_out_valid, // whether data from filter is valid
   input[63:0] coeff_out_data // out of the filter
   );

// connect wires to handle extra zeros
// in the filter input/output data
wire[31:0] last_read = {
  coeff_out_data[55:48], 
  coeff_out_data[39:32],
  coeff_out_data[23:16],
  coeff_out_data[7:0]};

// data buffered for writing
reg[127:0] next_write = 0;
assign coeff_in_data = {
	8'b0, next_write[31:24],
	8'b0, next_write[23:16],
	8'b0, next_write[15:8],
	8'b0, next_write[7:0]
};

localparam S_IDLE = 0,
           S_RESET = 1,
           S_POST_RST = 2,
           S_ADR_CYCLE = 3,
           S_RD_WAIT = 4,
           S_ACK = 5;
reg[2:0] fsm = S_IDLE; 

localparam[0:0] RD_OP = 0,
                WR_OP = 1;
reg op_type = RD_OP;

reg[31:0] counter = 0;
always @(posedge clk) begin
	if (!reset_n) begin
	  ack <= 0;
	  coeff_we <= 0;
	  coeff_adr <= 0;	  
	  counter <= 0;
	  coeff_read <= 0;
	  coeff_areset <= 0;
	  fsm <= S_IDLE;
	end

	else begin
	  ack <= 0;
	  counter <= 0;
	  coeff_we <= 0;
	  coeff_adr <= 0;	  
	  coeff_read <= 0;
	  coeff_areset <= 0;
	  
	  case (fsm)
	    S_IDLE: begin
	      if (req) begin
	      	op_type <= wr_op;

 		next_write <= coeff_wr_data;
	      	coeff_areset <= 1;

	      	fsm <= S_RESET;	      	
	      end
	    end

	    S_RESET: begin
	      coeff_areset <= 1;
	      counter <= counter + 1;

	      if (counter == 1) begin
	      	coeff_areset <= 0;
	      	counter <= 0;
	      	fsm <= S_POST_RST;
	      end
	    end

	    S_POST_RST: begin
	      counter <= counter + 1;

	      if (counter == 3) begin
	        if (op_type == WR_OP) coeff_we <= 4'hf;
	        else coeff_read <= 1;
	      	
	      	counter <= 0;
	      	fsm <= S_ADR_CYCLE;
	      end
	    end

	    S_ADR_CYCLE: begin
	      counter <= counter + 1;
	      coeff_adr <= counter + 1;

	      next_write <= {32'b0, next_write[127:32]};	    
	      coeff_rd_data <= 
	         {last_read, coeff_rd_data[127:32]};

	      if (op_type == WR_OP) 
	        coeff_we <= 4'hf;
	      else 
	        coeff_read <= 1;

	      if (counter == 3) begin
	        coeff_we <= 0;
	        counter <= 0;
	        coeff_adr <= 0;
	        fsm <= S_RD_WAIT;
	      end
	    end

	    S_RD_WAIT: begin
	      counter <= counter + 1;
	      if (op_type == RD_OP) begin
	      	coeff_read <= 1;
	      end

	      coeff_rd_data <= 
	         {last_read, coeff_rd_data[127:32]};

	      if (counter == 2) begin
	      	ack <= 1;
	      	coeff_read <= 0;
	      	fsm <= S_ACK;
	      end
	    end

	    S_ACK: begin
	      ack <= 1;
	      if (!req) begin
	        ack <= 0;
	        fsm <= S_IDLE;
	      end
	    end

	    default: fsm <= S_IDLE;

	  endcase
	end
end

endmodule