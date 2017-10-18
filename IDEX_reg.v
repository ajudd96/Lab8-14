`timescale 1ns / 1ps

module IDEX_reg(
//	 	inputs
//			For internal use:
				Clk,
			
//			To Pass through:
//				Control Lines;
					RegWrite,
					MemtoReg,
					MemWrite,
					MemRead,
					RegDst,
					ALUOp,
					ALUSrc,

//				Data lines;
					ID_PCAddResult,
					ReadData1,
					ReadData2,
					immExt,
					rt,
					rd,
				
                
//		outputs
//			To Pass through:
//				Control Lines;
					EX_RegWrite,
					EX_MemtoReg,
					EX_MemWrite,
					EX_MemRead,
					EX_RegDst,
					EX_ALUOp,
					EX_ALUSrc,
					
//				Data lines;
					EX_PCAddResult,
					EX_ReadData1,
					EX_ReadData2,
					EX_immExt,
					EX_rt,
					EX_rd );


input Clk;
input RegWrite, MemtoReg, MemWrite, MemRead, RegDst, ALUSrc;
input wire [3:0] ALUOp;
input wire [31:0] ID_PCAddResult, ReadData1, ReadData2, immExt;
input wire [4:0] rt, rd;

output reg EX_RegWrite, EX_MemtoReg, EX_MemWrite, EX_MemRead, EX_RegDst, EX_ALUSrc;
output reg [3:0] EX_ALUOp;
output reg [31:0] EX_PCAddResult, EX_ReadData1, EX_ReadData2, EX_immExt;
output reg [4:0] EX_rt, EX_rd;



always @(posedge Clk) begin
	
	// Controls
	EX_RegWrite <= RegWrite;
	EX_MemtoReg <= MemtoReg;
	EX_MemWrite <= MemWrite;
	EX_MemRead <= MemRead;
	EX_RegDst <= RegDst;
	EX_ALUSrc <= ALUSrc;
	EX_ALUOp <= ALUOp;
	
	// Data
	EX_PCAddResult <= ID_PCAddResult;
	EX_ReadData1 <= ReadData1;
	EX_ReadData2 <= ReadData2;
	EX_immExt <= immExt;
	EX_rt <= rt;
	EX_rd <= rd;

end
endmodule