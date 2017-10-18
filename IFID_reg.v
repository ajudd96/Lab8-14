`timescale 1ns / 1ps

module IFID_reg(
//		inputs
//			For internal use:
				Clk,

//			To Pass through:
//				Data lines;
					PCAddResult,
					Instruction,


//		outputs
//			To Pass through:
//				Data lines;
					ID_PCAddResult,
					ID_Instruction );
					

input Clk;
input wire [31:0] PCAddResult;
input wire [31:0] Instruction;

output reg [31:0] ID_PCAddResult;
output reg [31:0] ID_Instruction;

always @(posedge Clk) begin
	
	// Data
	ID_PCAddResult <= PCAddResult;
	ID_Instruction <= Instruction;
	
end
endmodule