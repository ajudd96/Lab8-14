`timescale 1ns / 1ps

module IFID_reg(Clk, PCAddResult, Instruction, ID_PCAddResult, ID_Instruction );

input Clk;
input wire [31:0] PCAddResult;
input wire [31:0] Instruction;

output reg [31:0] ID_PCAddResult;
output reg [31:0] ID_Instruction;

always @(posedge Clk) begin
	ID_PCAddResult <= PCAddResult;
	ID_Instruction <= Instruction;
end
endmodule