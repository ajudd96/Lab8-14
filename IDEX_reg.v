`timescale 1ns / 1ps

module IDEX_reg(
	/* inputs */ Clk, ReadData1, ReadData2, immExt, rt, rd, ID_PCAddResult,
				 RegDst, Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite, /*Jump,*/ CondMov,

	/* outputs */ EX_ReadData1, EX_ReadData2, EX_immExt, EX_rt, EX_rd, EX_PCAddResult,
				 EX_RegDst, EX_Branch, EX_MemRead, EX_MemtoReg, EX_ALUOp, EX_MemWrite, 
				 EX_ALUSrc, EX_RegWrite, /*EX_Jump,*/ EX_CondMov
			   );

input Clk;
input wire [31:0] ReadData1, ReadData2, immExt, ID_PCAddResult;
input wire [4:0] rt, rd;
input wire [3:0] ALUOp;
input RegDst, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, /*Jump,*/ CondMov; 

output reg [31:0] EX_ReadData1, EX_ReadData2, EX_immExt, EX_PCAddResult;
output reg [4:0] EX_rt, EX_rd;
output reg [3:0] EX_ALUOp;
output reg EX_RegDst, EX_Branch, EX_MemRead, EX_MemtoReg, EX_MemWrite, EX_ALUSrc, EX_RegWrite, /*EX_Jump,*/ EX_CondMov;

always @(posedge Clk) begin
	EX_ReadData1 <= ReadData1;
	EX_ReadData2 <= ReadData2;
	EX_immExt <= immExt;
	EX_PCAddResult <= ID_PCAddResult;
	EX_rt <= rt;
	EX_rd <= rd;
	EX_ALUOp <= ALUOp;

	EX_RegDst <= RegDst;
	EX_Branch <= Branch;
	EX_MemRead <= MemRead;
	EX_MemtoReg <= MemtoReg;
	EX_MemWrite <= MemWrite;
	EX_ALUSrc <= ALUSrc;
	EX_RegWrite <= RegWrite;
	//EX_Jump <= Jump;
	EX_CondMov <= CondMov;
end
endmodule