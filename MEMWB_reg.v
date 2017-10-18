`timescale 1ns / 1ps

module MEMWB_reg(
	/* inputs */ Clk, MEM_DMResult, MEM_ALUResult, MEM_WriteRegister,
				 MEM_MemtoReg, MEM_RegWrite,
	/* outputs */ WB_DMResult, WB_ALUResult, WB_WriteRegister,   
				 WB_MemtoReg, WB_RegWrite
			   );

input Clk;
input wire [31:0] MEM_DMResult, MEM_ALUResult;
input wire [4:0]  MEM_WriteRegister; 
input MEM_MemtoReg, MEM_RegWrite; 

output reg [31:0] WB_DMResult, WB_ALUResult;
output reg [4:0]  WB_WriteRegister;
output reg WB_MemtoReg, WB_RegWrite;

always @(posedge Clk) begin
	WB_DMResult <= MEM_DMResult;
	WB_ALUResult <= MEM_ALUResult;
	WB_WriteRegister <= MEM_WriteRegister;

	WB_MemtoReg <= MEM_MemtoReg;
	WB_RegWrite <= MEM_RegWrite;
end
endmodule