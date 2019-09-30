// Extends an input pulse by N_TO_EXTEND clock cycles
//
// if "in" pulses again during the extension window,
// the extension counter will start over 
//
// "in" is assumed to be externally synchronized with clk
//
// Aaron Fienberg
// September 2019

module pulse_extender #(parameter N_TO_EXTEND=6) (
	input clk,
	input reset_n,
	input in,  // input pulse
	output out // output data
	);

reg hold_high = 0;

assign out = in | hold_high; 

localparam S_IDLE = 0,
           S_HIGH = 1,
           S_HOLD = 2;
reg[1:0] fsm = S_IDLE;

reg[31:0] counter;

always @(posedge clk) begin
	if (!reset_n) begin
	  fsm <= S_IDLE;
	  counter <= 0;
	  hold_high <= 0;
	end

	else begin
	  case (fsm)
	    S_IDLE: begin
	      counter <= 0;
	      hold_high <= 0;
	      if (in) begin
	        hold_high <= 1;
	        fsm <= S_HIGH;
	      end
	      else fsm <= S_IDLE;
	    end

	    S_HIGH: begin
	      counter <= 0;
	      hold_high <= 1;

	      if (!in) begin
	        if (N_TO_EXTEND > 1) fsm <= S_HOLD;
	        else begin
	          hold_high <= 0;
	          fsm <= S_IDLE;
	        end
	      end

	    end

	    S_HOLD: begin
	      counter <= counter + 1;
	      hold_high <= 1;
	      if (in) begin
	      	fsm <= S_HIGH;
	      end
	      else if (counter == N_TO_EXTEND - 2) begin
	      	hold_high <= 0;
	      	fsm <= S_IDLE;
	      end
	    end	 

	    default: begin
	      fsm <= S_IDLE;
	      hold_high <= 0;
	      counter <= 0;
	    end   
	    
	  endcase
	end
end

endmodule	                       