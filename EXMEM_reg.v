`timescale 1ns / 1ps

module EXMEM_reg(
	/* inputs */ Clk, EX_AdderResult, EX_ALUResult, EX_ReadData2, EX_WriteRegister, 
				 EX_Branch, EX_MemRead, EX_MemtoReg, EX_MemWrite, EX_RegWrite, /*EX_Jump,*/ ZeroFlag,

	/* outputs */ MEM_AdderResult, MEM_ALUResult, MEM_ReadData2, MEM_WriteRegister,
				 MEM_Branch, MEM_MemRead, MEM_MemtoReg, MEM_MemWrite, MEM_RegWrite, /*MEM_Jump,*/ MEM_ZeroFlag
			   );

input Clk;
input wire [31:0] EX_AdderResult, EX_ALUResult, EX_ReadData2;
input wire [4:0]  EX_WriteRegister; 
input EX_Branch, EX_MemRead, EX_MemtoReg, EX_MemWrite, EX_RegWrite, /*EX_Jump,*/ ZeroFlag; 

output reg [31:0] MEM_AdderResult, MEM_ALUResult, MEM_ReadData2;
output reg [4:0]  MEM_WriteRegister;
output reg MEM_Branch, MEM_MemRead, MEM_MemtoReg, MEM_MemWrite, MEM_RegWrite, /*MEM_Jump,*/ MEM_ZeroFlag;

always @(posedge Clk) begin
	MEM_AdderResult <= EX_AdderResult;
	MEM_ALUResult <= EX_ALUResult;
	MEM_ReadData2 <= EX_ReadData2;
	MEM_WriteRegister <= EX_WriteRegister;

	MEM_Branch <= EX_Branch;
	MEM_MemRead <= EX_MemRead;
	MEM_MemtoReg <= EX_MemtoReg;
	MEM_MemWrite <= EX_MemWrite;
	MEM_RegWrite <= EX_RegWrite;
	//MEM_Jump <= EX_Jump;
	MEM_ZeroFlag <= ZeroFlag;
end
endmodule