`timescale 1ns / 1ps
module ShiftLeft32Bit(in, out, shmt);

input [31:0] in;
input shmt;

output reg [31:0] out;

 always@(*)
 begin
 	out = in << shmt;
 end
 endmodule

