// Convert an offset binary int to a two's complement int
//
// Aaron Fienberg
// September 2019

module unsigned_to_signed #(parameter NBITS=14) 
  (
    input[NBITS-1:0] in,
    output[NBITS-1:0] out
  );


localparam ONE = {{NBITS-1{1'b0}}, 1'b1};

assign out = in - (ONE<<NBITS-1);

endmodule 