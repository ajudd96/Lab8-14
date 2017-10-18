`timescale 1ns / 1ps

module EXMEM_reg(
//		inputs
//			For internal use:
				Clk,
				
//			To pass through:
//				Control lines;
					EX_RegWrite,
					EX_MemtoReg,
					EX_MemWrite,
					EX_MemRead,
					ZeroFlag,
					
//				Data lines;
					EX_AdderResult,
					EX_ALUResult,
					EX_ReadData2,
					EX_WriteRegister,


//		outputs
//			To pass through:
//				Control lines;
					MEM_RegWrite,
					MEM_MemtoReg,
					MEM_MemWrite,
					MEM_MemRead,
					MEM_ZeroFlag,
				
//				Data lines;
					MEM_AdderResult,
					MEM_ALUResult,
					MEM_ReadData2,
					MEM_WriteRegister );

input Clk;
input EX_RegWrite, EX_MemtoReg, EX_MemWrite, EX_MemRead, ZeroFlag; 
input wire [31:0] EX_AdderResult, EX_ALUResult, EX_ReadData2;
input wire [4:0]  EX_WriteRegister; 

output reg MEM_RegWrite, MEM_MemtoReg, MEM_MemWrite, MEM_MemRead, MEM_ZeroFlag;
output reg [31:0] MEM_AdderResult, MEM_ALUResult, MEM_ReadData2;
output reg [4:0]  MEM_WriteRegister;


always @(posedge Clk) begin
	
	// Control
	MEM_RegWrite <= EX_RegWrite;
	MEM_MemtoReg <= EX_MemtoReg;
	MEM_MemWrite <= EX_MemWrite;
	MEM_MemRead <= EX_MemRead;
	MEM_ZeroFlag <= ZeroFlag;
	
	// Data
	MEM_AdderResult <= EX_AdderResult;
	MEM_ALUResult <= EX_ALUResult;
	MEM_ReadData2 <= EX_ReadData2;
	MEM_WriteRegister <= EX_WriteRegister;

end
endmodule