`timescale 1ns / 1ps

module MEMWB_reg(
//		inputs
//			For internal use:
				Clk,

//			To Pass through:
//				Control lines;
					MEM_RegWrite,
					MEM_MemtoReg,
				
//				Data lines;
					MEM_DMResult,
					MEM_ALUResult,
					MEM_WriteRegister,
					

//		outputs
//			To pass through:
// 				Control lines;
					WB_RegWrite,
					WB_MemtoReg,
				
//				Data lines;				
					WB_DMResult,
					WB_ALUResult,
					WB_WriteRegister );

input Clk;
input MEM_RegWrite, MEM_MemtoReg; 
input wire [31:0] MEM_DMResult, MEM_ALUResult;
input wire [4:0]  MEM_WriteRegister; 

output reg WB_RegWrite, WB_MemtoReg;
output reg [31:0] WB_DMResult, WB_ALUResult;
output reg [4:0]  WB_WriteRegister;

always @(posedge Clk) begin
	
	// Control
	WB_RegWrite <= MEM_RegWrite;
	WB_MemtoReg <= MEM_MemtoReg;
	
	// Data
	WB_DMResult <= MEM_DMResult;
	WB_ALUResult <= MEM_ALUResult;
	WB_WriteRegister <= MEM_WriteRegister;

end
endmodule