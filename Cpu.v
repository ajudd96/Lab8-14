`timescale 1ns / 1ps

/*
Percent Effort:
	Aneesa Judd - 33 %
	Victor Reyes - 33 %
	Barak Hassan - 33 % 
*/

module CPU(Clk, reset, PCResult, EX_ALUResult, Hi, Lo, WB_ALUResult);

	// CPU Input and Output declaration
	input Clk, reset;
	output PCResult;		
	output EX_ALUResult, WB_ALUResult;
	output [31:0] Hi, Lo;
   
	/* Instruction fetch stage */
    wire [31:0] PCAddress;
    wire [31:0] IF_Instruction;
    wire [31:0] PCResult;
	wire [31:0] PCAddResult;
	wire [63:0] ALUResult_64bit;
	wire [31:0] Hi, Lo;
	
	ProgramCounter ProgramCounter_1(PCAddResult, PCResult, reset, Clk);
    InstructionMemory InstructionMemory_1(PCResult, IF_Instruction); 
    PCAdder PCAdder_1(PCResult, PCAddResult);
	
	/* IFID Pipeline Register */
	wire [31:0] ID_Instruction;
	IFID_reg IFID_RegFile(Clk, IF_Instruction, ID_Instruction );
	
	/* Instruction decode stage */
	wire [4:0] ID_rs, ID_rt, ID_rd;
	wire [15:0] ID_imm;
	wire [5:0] Function, OPCode;
	wire [31:0] ID_sa;
	assign OPCode = ID_Instruction[31:26];
    assign ID_rs = ID_Instruction[25:21];
    assign ID_rt = ID_Instruction[20:16];
    assign ID_rd = ID_Instruction[15:11];
    assign ID_imm = ID_Instruction[15:0];
    assign Function = ID_Instruction[5:0];
    assign ID_sa = {27'b0, ID_Instruction[10:6]};
    assign InstructionBit_6 = ID_Instruction[6];
    assign InstructionBit_9 = ID_Instruction[9];
    assign InstructionBit_21 = ID_Instruction[21];
	
	wire ID_RegDst, ID_ALUSrc2, ID_RegWrite, SignExt, ID_CondMov, ID_ALUSrc1;
	wire [4:0] ID_ALUControl;
	
	Control MainControl(
		// input
		OPCode, Function, InstructionBit_6, InstructionBit_9, InstructionBit_21,
		// output
		ID_RegDst, ID_ALUSrc2, ID_RegWrite, SignExt, ID_CondMov, ID_ALUSrc1,
		ID_ALUControl );
	
	wire [31:0] ID_ReadData1, ID_ReadData2, WB_ALUResult; 
	wire [4:0] WB_WriteRegister;
	wire WB_RegWriteResult;
	
	
	RegisterFile RegisterFile_1(
    	ID_rs,
    	ID_rt,
    	WB_WriteRegister,
    	WB_ALUResult,		
    	WB_RegWriteResult,		
    	Clk,
    	ID_ReadData1,
    	ID_ReadData2
    	);
	
	wire [31:0] ID_immExt;
	
	SignExtension SignExtension_1(ID_imm, ID_immExt, SignExt);
	
	/* IDEX Pipeline Register */
	wire [31:0] EX_ReadData1, EX_ReadData2, EX_immExt;
	wire [4:0] EX_rt, EX_rd;
	wire [31:0] EX_sa;
	wire EX_RegWrite, EX_CondMov, EX_RegDst, EX_ALUSrc1, EX_ALUSrc2;
	wire [4:0] EX_ALUControl;
	
	IDEX_reg IDEX_RegFile(
		Clk,
		ID_RegWrite,
		ID_CondMov,
		ID_RegDst,
		ID_ALUControl,
		ID_ALUSrc1,
		ID_ALUSrc2,

		ID_ReadData1,
		ID_ReadData2,
		ID_immExt,
		ID_rt,
		ID_rd,
		ID_sa,
			
		EX_RegWrite,
		EX_CondMov,
		EX_RegDst,
		EX_ALUControl,
		EX_ALUSrc1,
		EX_ALUSrc2,
			
		EX_ReadData1,	 
		EX_ReadData2, 
		EX_immExt,	
		EX_rt,			
		EX_rd,
		EX_sa );
	
	/* Execution Stage */
	wire [31:0] ALUSrcMuxResult_1, ALUSrcMuxResult_2;
	Mux32Bit2To1 ALUSrcMux_1(ALUSrcMuxResult_1, EX_ReadData1, EX_sa, EX_ALUSrc1);
    Mux32Bit2To1 ALUSrcMux_2(ALUSrcMuxResult_2, EX_ReadData2, EX_immExt, EX_ALUSrc2);
	
	wire [31:0] EX_ALUResult;
	wire EX_ZeroFlag;
	ALU32Bit ALU(EX_ALUControl, ALUSrcMuxResult_1, ALUSrcMuxResult_2, EX_ALUResult, EX_ZeroFlag, Hi, Lo, ALUResult_64bit);
	assign Hi = ALUResult_64bit[63:32];
	assign Lo = ALUResult_64bit[31:0];
	wire [4:0] EX_WriteRegister;
	Mux5Bit2To1 RegDstMux(EX_WriteRegister, EX_rt, EX_rd, EX_RegDst);
	
	/* EXMEM Pipeline Register */
	wire MEM_RegWrite, MEM_CondMov, MEM_ZeroFlag;
	wire [31:0] MEM_ALUResult;
	wire [4:0] MEM_WriteRegister;
	
	EXMEM_reg EXMEM_RegFile(
		Clk,				
		EX_RegWrite,
		EX_CondMov,
		
		EX_ZeroFlag,
		EX_ALUResult,
		EX_WriteRegister,


		MEM_RegWrite,
		MEM_CondMov,
		
		MEM_ZeroFlag,
		MEM_ALUResult,
		MEM_WriteRegister );
	
	/* Memory Stage */
	
	
	/* MEMWB Pipeline Register */
	wire WB_RegWrite, WB_CondMov;
	
	MEMWB_reg MEMWB_RegFile(
		Clk,
		MEM_RegWrite,
		MEM_CondMov,
		
		MEM_ZeroFlag,
		MEM_ALUResult,
		MEM_WriteRegister,
			
		WB_RegWrite,
		WB_CondMov,
		
		WB_ZeroFlag,			
		WB_ALUResult,
		WB_WriteRegister );
	
	/* Write Back Stage */		
	CondMov CondMovLogic(
		WB_RegWrite, 
		WB_CondMov, 
		WB_ZeroFlag, 
		WB_RegWriteResult );
endmodule