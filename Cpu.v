`timescale 1ns / 1ps






module CPU(Clk, reset, PCResult, WB_WriteData, EX_ALUResult);

	input Clk, reset;
	output PCResult;
	output WB_WriteData;
	output EX_ALUResult;
	///////////////////////////////////////
  	// Signal Declarations
   ///////////////////////////////////////////
   /* Instruction fetch stage */
    wire [31:0] PCAddress;
    wire [31:0] Instruction, ID_Instruction, EX_Instruction;
    wire [31:0] PCResult, PCAddResult, ID_PCAddResult, EX_PCAddResult;
    // used in decode stage
    /*wire [3:0] EX_PCAddResultJump;	// PCAddResult[31:28] (used for jump instruction) */

    /* Instruction decode stage */
    wire [5:0] OPCode, Function, EX_Function;	// Instruction[31:26] and Instruction[5:0]
    wire [4:0] rs, rt, rd, EX_rt, EX_rd;			// Instruction[25:21], Instruction[20:16], and Instruction[15:11]
    wire [25:0] instr_index;		// Instruction[25:0] (used for jump instruction)
    wire [31:0] sa, EX_sa;					// Instruction[10:6] (used for immediate shift instructions)
    wire [15:0] imm;				// Instruction[15:0]
    wire [31:0] immExt, EX_immExt;
    
    wire InstructionBit_6, InstructionBit_9, InstructionBit_21, EX_InstructionBit_6, EX_InstructionBit_9, EX_InstructionBit_21;

    wire [4:0] WriteRegister, EX_WriteRegister, MEM_WriteRegister, WB_WriteRegister;
    wire [31:0] WB_WriteData;

    wire [31:0] ReadData1, EX_ReadData1;	// R[rs]
    wire [31:0] ReadData2, EX_ReadData2, MEM_ReadData2;	// R[rt]

    /* Execution stage */
    wire [31:0] EX_ALUResult, MEM_ALUResult, WB_ALUResult;
    wire [31:0] ALUSrcMuxResult_1;  // between EX_ReadData1 (R[rs] and EX_sa, shift amount, sel = ALUSrc1)
    wire [31:0]  ALUSrcMuxResult_2;	// between EX_ReadData2 (R[rt]) and EX_immExt, sel = ALUSrc
    wire ZeroFlag, MEM_ZeroFlag;

    wire [31:0] ShiftLeftResult;
    wire [31:0] EX_AdderResult, MEM_AdderResult;	// PC+4 + shift left 2 (immediate)

    /* Memory access stage */
    wire [31:0] MEM_DMResult, WB_DMResult;
    wire BranchAndResult; // AND between ZeroFlag and Branch signal; sent to PCSrcMux;
   // wire PCSrc;
    
    /* Control signals */
    wire RegDst, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, SignExt/*, Jump*/;
    wire EX_RegDst, EX_Branch, EX_MemRead, EX_MemtoReg, EX_MemWrite, EX_ALUSrc1, EX_ALUSrc,  EX_RegWrite;
    wire MEM_RegDst, MEM_Branch, MEM_MemtoReg, MEM_RegWrite, MEM_MemRead, MEM_MemWrite;
    wire WB_RegDst, WB_MemtoReg, WB_RegWrite;

    // CondMov AND and OR gates
    wire AndCondMovResult;
    wire RegWrite_Or; //OR of RegWrite from WB stage and AndCondMovResult

    wire [3:0] ALUOp, EX_ALUOp;
    wire [4:0] ALUControl;
    wire /*Link, Link31, FromHigh,*/ CondMov, EX_CondMov, MEM_CondMov;	// for now only need CondMov
    
    //////////////////////////////////////////
    // Module Instantitions 
    /////////////////////////////////////////////

    /* Instruction fetch stage */
    ///// set reset to 1 at the begining of the program //////////
    ProgramCounter ProgramCounter_1(PCAddress, PCResult, reset, Clk);
    InstructionMemory InstructionMemory_1(PCResult, Instruction); 
    PCAdder PCAdder_1(PCResult, PCAddResult); // PCAddResult = PCResult + 4
    Mux32Bit2To1 PCSrcMux(PCAddress, PCAddResult, MEM_AdderResult, BranchAndResult);

    /* IF/ID Register */
    // stores 32bit PC value and the 32bit instruction read from instruction memory

    IFID_reg IFID_RegFile(Clk, PCAddResult, Instruction, ID_PCAddResult, ID_Instruction );

    /* Instruction decode stage */
    assign OPCode = ID_Instruction[31:26];
    assign rs = ID_Instruction[25:21];
    assign rt = ID_Instruction[20:16];
    assign rd = ID_Instruction[15:11];
    assign imm = ID_Instruction[15:0];
    assign Function = ID_Instruction[5:0];
    assign instr_index = ID_Instruction[25:0];
    assign sa = ID_Instruction[10:6];
    assign  InstructionBit_6 = ID_Instruction[6];
    assign InstructionBit_9 = ID_Instruction[9];
    assign  InstructionBit_21 = ID_Instruction[21];

    Control MainControl(
    	OPCode, RegDst, Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite, SignExt, /*Jump*/
    	);

    RegisterFile RegisterFile_1(
    	rs,
    	rt,
    	WB_WriteRegister,
    	WB_WriteData,
    	RegWrite_Or,
    	Clk,
    	ReadData1,
    	ReadData2
    	);

    or (RegWrite_Or, WB_RegWrite, AndCondMovResult);

    // Jump Jump_1(instr_index, ID_PCAddResult[31:28], 2);	// need to learn how to concatenate PC+4[31:28] w/ I[25:0] >> 2

    SignExtension SignExtension_1(imm, immExt, SignExt);

    ///////////////////
    // JAL circuity
    ///////////////
    /*Mux32Bit2To1 JALSelectMux(WB_WriteData, PCWriteDataMuxOut, register31, AndLinkOut);
    AND and1(link, link31, AndLinkOut);
    Mux32Bit2To1 WriteDataSelectMux(PCWriteDataMuxOut, ID_PCAddResult, WB_WriteData, Link);	// PC + 4 or WriteData*/

    /* ID/EX Register */
    // stores all control signals generated by controller, the two register vales read(ReadData1 and ReadData2), 
    // sign-extended offset value, and potential register destinations rt and rd. 

    IDEX_reg IDEX_RegFile(
    /* inputs */ Clk, ReadData1, ReadData2, immExt, rt, rd, sa, ID_PCAddResult, Function,
                     RegDst, Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite, /*Jump,*/ CondMov,
                      InstructionBit_6, InstructionBit_9, InstructionBit_21,
    
        /* outputs */ EX_ReadData1, EX_ReadData2, EX_immExt, EX_rt, EX_rd, EX_sa, EX_PCAddResult, EX_Function,
                     EX_RegDst, EX_Branch, EX_MemRead, EX_MemtoReg, EX_ALUOp, EX_MemWrite, 
                     EX_ALUSrc, EX_RegWrite, /*EX_Jump,*/ EX_CondMov,
                      EX_InstructionBit_6, EX_InstructionBit_9, EX_InstructionBit_21
				 );

    /* Execution stage */

    ShiftLeft32Bit ShiftLeft2(EX_immExt, ShiftLeftResult);	// shift immediate (sign or zero) extended left by 2

    Adder32Bit Adder(ShiftLeftResult, EX_PCAddResult, EX_AdderResult);
    
    Mux32Bit2To1 ALUSrcMux_1(ALUSrcMuxResult_1, EX_ReadData1, EX_sa, EX_ALUSrc1);
    Mux32Bit2To1 ALUSrcMux_2(ALUSrcMuxResult_2, EX_ReadData2, EX_immExt, EX_ALUSrc);

    Mux5Bit2To1 RegDstMux(EX_WriteRegister, EX_rt, EX_rd, EX_RegDst);

    and (AndCondMovResult, MEM_ZeroFlag, MEM_CondMov);

    ALUControl ALUControl_1(EX_ALUOp, EX_Function, EX_rt, ALUControl, /*Link, Link31, FromHigh,*/ CondMov, EX_ALUSrc1, EX_InstructionBit_6, EX_InstructionBit_9, EX_InstructionBit_21 );
    
    ALU32Bit ALU(ALUControl, ALUSrcMuxResult_1, ALUSrcMuxResult_2, EX_ALUResult, ZeroFlag);

    /* EX/MEM Register */
    // stores WB and MEM control signals, the branch target adress (PCAddResult), ALU Output, zero flag, 
    // and destination register (mux controlled by EX_RegDst)

    EXMEM_reg EXMEM_RegFile(
	/* inputs */ Clk, EX_AdderResult, EX_ALUResult, EX_ReadData2, EX_WriteRegister, 
				 EX_Branch, EX_MemRead, EX_MemtoReg, EX_MemWrite, EX_RegWrite, /*EX_Jump,*/ ZeroFlag,

	/* outputs */ MEM_AdderResult, MEM_ALUResult, MEM_ReadData2, MEM_WriteRegister,
				 MEM_Branch, MEM_MemRead, MEM_MemtoReg, MEM_MemWrite, MEM_RegWrite, /*MEM_Jump,*/ MEM_ZeroFlag
			   );

    DataMemory DataMemory_1(
     MEM_ALUResult,
     MEM_ReadData2,
     Clk,
     MEM_MemWrite,
     MEM_MemRead,
     /*DMControl,*/
     MEM_DMResult);

    and (BranchAndResult, MEM_Branch, MEM_ZeroFlag);

    /* MEM/WB Register */
    // stores WB control signals, ALU output, Data Memory output (), and the destination register (WB_WriteRegister)

    MEMWB_reg MEMWB_RegFile(
	/* inputs */ Clk, MEM_DMResult, MEM_ALUResult, MEM_WriteRegister, 
				 MEM_MemtoReg, MEM_RegWrite,
	/* outputs */ WB_DMResult, WB_ALUResult, WB_WriteRegister,   
				 WB_MemtoReg, WB_RegWrite
			   );
			   
    /* Writeback stage */
    Mux32Bit2To1 MemtoRegMux(WB_WriteData, WB_DMResult, WB_ALUResult, WB_MemtoReg);
    
    always @(posedge Clk)
        begin
            $display("INSTRUCTION=%h - radd0[rs]=%d - radd1[rt]=%d - ReadData1=%-d - ReadData2=%-d",
               Instruction,
               rs,
               rt, 
                ReadData1, 
                ReadData2);
        end

endmodule
