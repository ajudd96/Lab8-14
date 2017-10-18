`timescale 1ns / 1ps


module Control(Op, RegDst, Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite, SignExt, Jump);

	input [5:0] Op; // control bits for ALU operation

	// Control Signals
	output reg RegDst;	    // RegDst == 1 if lw, 0 if r-type instruction, X if sw or branch
	output reg Branch;		// Branch == 1 if branch instruction, 0 if anything else
	output reg MemRead;		// MemRead == 1 if lw, 0 if anything else
	output reg MemtoReg;	// MemtoReg == 1 if lw, 0 if r-type instruction, X if sw or branch

	output reg [3:0] ALUOp;	
                        // Operation   	 | 'ALUOp' value
                        // ==========================
                        // MADD(Funct)        | 00000
                        // subtraction               | 00001
                        // determined by funct.     | 00010
                        // MSUB(Funct)          | 00011
                        // move to lo/hi            | 00100
                        // multiplication           | 00101  
                        // Shift Left                | 00110
                        // slt                      | 00111
                        // Sign Extend halfword     | 01000
                        // LUI                        | 01001
                        // ANDI                        | 01010
                        // ORI                        | 01011
                        // XORI                        | 01100
                        // SLTI                        | 01101
                        // BEQ                        | 01110
                        // BGTZ                        | 01111
                        // MFHI(Funct)                | 10000
                        // MTHI(Funct)            | 10001
                        // MFLO(Funct)         | 10010
                        // MTLO(Funct)        | 10011
                        // BNE                     | 10100
                        // BLTZ _BGEZ     | 10101
                        // BLEZ                         | 10110
                        // addition (sw, lw, addi) | 10111
                        // n/a                            | 11000
                        // n/a                             | 11001

	output reg MemWrite;		// MemWrite == 1 if sw and SS0 if anything else
	output reg ALUSrc;			// ALUSrc == 1 if sw or lw and 0 if r-type or branch   
	output reg RegWrite;		// RegWrite == 1 if r-type or lw instruction and 0 if sw or branch 
	//output reg PCSrc;			// PCSrc == 1 if jump needed to address[15:0], 0 if r-type
	output reg SignExt;			// SignExt == 1 if Sign Extend requires sign extension, 0 for 0 extension (unsigned numbers)
	output reg Jump;			// Jump == 1 if a jump instruction
	//output reg FromHigh; // FromHigh == 1 if MVHI else FromHigh == 0

    parameter 	RTYPE = 'b000000, SW = 'b101011, SB = 'b101000, SH = 'b101001,
    			LW = 'b100011, LB = 'b100000, LH ='b100001, LUI = 'b001111,
     	   	    BEQ = 'b000100, BNE = 'b000101, BGTZ = 'b000111, BLEZ = 'b000110, BLTZ_BGEZ= 'b000001,
     	   	    J = 'b000010, JAL = 'b000011, 
     	   	    ADDI = 'b001000, ADDIU = 'b001001, ANDI = 'b001100, ORI = 'b001101, XORI = 'b001110, 
     	   	    SEH = 'b011111, SLTI = 'b001010,
                MADD_SUB = 'b011100;
                
                // Mubarak added:
   parameter        SLTIU = 'b001_011, SEB_SEH = 'b011_111;
    // RTYPE instructions: add, addu, and, jr, mfhi, mflo, mult, multu, nor, xor, or, slt, sll, srl(0-extended), sllv?, srlv?, monv?, movz?, rotrv?, sra?, srav?, sub, subu
    //		format: op[31:26], rs[25:21], rt[20:16], rd[15:11], shamt[10:6], funct[5:0]
    // rotr vs srl differentiate using bit number 21
    
    always @(Op) begin
        case(Op)
        	RTYPE: begin
        		RegDst <= 1;
        		Branch <= 0;
        		MemRead <= 0;
        		MemtoReg <= 0;
        		ALUOp <= 'b00010;	//funct[5:0]
        		MemWrite <= 0;
        		ALUSrc <= 0;
        		RegWrite <= 1;
        		//PCSrc <= 0;	
        		SignExt <= 0;	// don't care
        		Jump <= 0;
        	end 
        // Load functions (differences handled in DMControl)
        	LW: begin
        		RegDst <= 0;
        		Branch <= 0;
        		MemRead <= 1;
        		MemtoReg <= 1;
        		ALUOp <= 'b10111; // addition
        		MemWrite <= 0;
        		ALUSrc <= 1;
        		RegWrite <= 1;
        		//PCSrc <= 0;
        		//FromHigh <= 0;
        		SignExt <= 1;
        		Jump <= 0;
        	end

        	LB: begin 	
        		RegDst <= 0;	
        		Branch <= 0;
        		MemRead <= 1;
        		MemtoReg <= 1;
        		ALUOp <= 'b10111;	
        		MemWrite <= 0;
        		ALUSrc <= 1;	// using offset value
        		RegWrite <= 1;
        		//PCSrc <= 0;
        		//FromHigh <= 0;
        		SignExt <= 1;
        		Jump <= 0;
        	end

        	LH: begin 	
        		RegDst <= 0;	
        		Branch <= 0;
        		MemRead <= 1;
        		MemtoReg <= 1;
        		ALUOp <= 'b10111;	
        		MemWrite <= 0;
        		ALUSrc <= 1;	
        		RegWrite <= 1;
        		//PCSrc <= 0;
        		//FromHigh <= 0;
        		SignExt <= 1;
        		Jump <= 0;
        	end

        	LUI: begin 	
        		RegDst <= 0;	
        		Branch <= 0;
        		MemRead <= 1;
        		MemtoReg <= 0;	// write data from ALUResult
        		ALUOp <= 'b00110;	// Shift Left, must shift left by 16 and concatenate 16 0's to the right side
        		MemWrite <= 0;
        		ALUSrc <= 1;	
        		RegWrite <= 1;
        		//PCSrc <= 0;
        		//FromHigh <= 0;
        		SignExt <= 1;	// don't care
        		Jump <= 0;
        	end

        // Store Functions (diferences handled in DMControl)	
        	SW: begin
        		RegDst <= 0;	// don't care
        		Branch <= 0;
        		MemRead <= 0;
        		MemtoReg <= 0;	// don't care
        		ALUOp <= 'b10111;
        		MemWrite <= 1;
        		ALUSrc <= 1;
        		RegWrite <= 0;
        		//PCSrc <= 0;
        		//FromHigh <= 0;
        		SignExt <= 1;
        		Jump <= 0;
        	end

        	SB: begin
        		RegDst <= 0;	// don't care
        		Branch <= 0;
        		MemRead <= 0;
        		MemtoReg <= 0;	// don't care
        		ALUOp <= 'b10111;	// should add [rs] and offset[15-0]
        		MemWrite <= 1;
        		ALUSrc <= 1;	// using offset value
        		RegWrite <= 0;
        		//PCSrc <= 0;
        		//FromHigh <= 0;
        		SignExt <= 1;
        		Jump <= 0;
        	end

        	SH: begin
        		RegDst <= 0;	// don't care
        		Branch <= 0;
        		MemRead <= 0;
        		MemtoReg <= 0;	// don't care
        		ALUOp <= 'b10111;	//  should add [rs] and offset[15-0]
        		MemWrite <= 1;
        		ALUSrc <= 1;	// using offset value
        		RegWrite <= 0;
        		//PCSrc <= 0;
        		//FromHigh <= 0;
        		SignExt <= 1;
        		Jump <= 0;
        	end

        // Branch instructions (each with a distinct ALUOp)
        	BEQ: begin
        		RegDst <= 0;	// don't care	
        		Branch <= 1;
        		MemRead <= 0;
        		MemtoReg <= 0;	// don't care
        		ALUOp <= 'b01110;
        		MemWrite <= 0;
        		ALUSrc <= 0;	
        		RegWrite <= 0;
        		//PCSrc <= 1;	// will branch only if, branch AND Zero flag AND PCSrc = 1
        		//FromHigh <= 0;	// don't care
        		SignExt <= 1;
        		Jump <= 0;
        	end

        	BNE: begin
        		RegDst <= 0;	// don't care	
        		Branch <= 1;
        		MemRead <= 0;
        		MemtoReg <= 0;	// don't care
        		ALUOp <= 'b10100;	
        		MemWrite <= 0;
        		ALUSrc <= 0;	
        		RegWrite <= 0;
        	//	PCSrc <= 1;	
        		//FromHigh <= 0;	// don't care
        		SignExt <= 1;
        		Jump <= 0;
        	end

        	BGTZ: begin
        		RegDst <= 0;	// don't care	
        		Branch <= 1;
        		MemRead <= 0;
        		MemtoReg <= 0;	// don't care
        		ALUOp <= 'b01111;	
        		MemWrite <= 0;
        		ALUSrc <= 0;	
        		RegWrite <= 0;
        		//PCSrc <= 1;	
        		//FromHigh <= 0;	// don't care
        		SignExt <= 1;
        		Jump <= 0;
        	end

        	BLEZ: begin
        		RegDst <= 0;	// don't care	
        		Branch <= 1;
        		MemRead <= 0;
        		MemtoReg <= 0;	// don't care
        		ALUOp <= 'b10110;	
        		MemWrite <= 0;
        		ALUSrc <= 0;	
        		RegWrite <= 0;
        		//PCSrc <= 1;	
        		//FromHigh <= 0;	// don't care
        		SignExt <= 1;
        		Jump <= 0;
        	end

        	BLTZ_BGEZ: begin
        		RegDst <= 0;	// don't care	
        		Branch <= 1;
        		MemRead <= 0;
        		MemtoReg <= 0;	// don't care
        		ALUOp <= 'b10101;	
        		MemWrite <= 0;
        		ALUSrc <= 0;	
        		RegWrite <= 0;
        		//PCSrc <= 1;	
        		//FromHigh <= 0;	// don't care
        		SignExt <= 1;
        		Jump <= 0;
        	end

        // jump functions
        	J: begin
        		RegDst <= 0;	// don't care	
        		Branch <= 0;	// don't care
        		MemRead <= 0;	// don't care
        		MemtoReg <= 0;	// don't care
        		ALUOp <= 'b10111;	// don't care
        		MemWrite <= 0;	
        		ALUSrc <= 0;	
        		RegWrite <= 0;
        		//PCSrc <= 0;		// don't care
        		//FromHigh <= 0;	// don't care
        		SignExt <= 1;	// don't care
        		Jump <= 1;
        	end

        	JAL: begin
        		RegDst <= 0;	// don't care	
        		Branch <= 0;	// don't care
        		MemRead <= 0;	// don't care
        		MemtoReg <= 0;	// don't care
        		ALUOp <= 'b10111;	// don't care
        		MemWrite <= 0;	
        		ALUSrc <= 0;	
        		RegWrite <= 0;
        		//PCSrc <= 0;		// don't care
        		//FromHigh <= 0;	// don't care
        		SignExt <= 1;	// don't care
        		Jump <= 1;
        		// handle Link31 in ALU Control
        		// handle Link (feeding PC + 4 into write data of $31) in ALU Control
        	end

        	// Immediate functions
        	ADDI: begin
        		RegDst <= 0;	
        		Branch <= 0;
        		MemRead <= 0;	// don't care
        		MemtoReg <= 0;
        		ALUOp <= 'b10111;	// addition
        		MemWrite <= 0;	
        		ALUSrc <= 1;	// use immediate value	
        		RegWrite <= 1;
        		//PCSrc <= 0;
        		//FromHigh <= 0;
        		SignExt <= 1;
        		Jump <= 0;
        	end

        	ADDIU: begin
        		RegDst <= 0;	
        		Branch <= 0;
        		MemRead <= 0;	// don't care
        		MemtoReg <= 0;
        		ALUOp <= 'b10111;	
        		MemWrite <= 0;
        		ALUSrc <= 1;	
        		RegWrite <= 1;
        		//PCSrc <= 0;
        		//FromHigh <= 0;
        		SignExt <= 0;	// unsigned
        		Jump <= 0;
        	end

        	ANDI: begin
        		RegDst <= 0;	
        		Branch <= 0;
        		MemRead <= 0;	// don't care
        		MemtoReg <= 0;
        		ALUOp <= 'b01010;
        		MemWrite <= 0;	
        		ALUSrc <= 1;	// use immediate value	
        		RegWrite <= 1;
        		//PCSrc <= 0;
        		//FromHigh <= 0;
        		SignExt <= 0;	// 16-bit immediate is zero-extended 
        		Jump <= 0;
        	end

        	ORI: begin
        		RegDst <= 0;	
        		Branch <= 0;
        		MemRead <= 0;	// don't care
        		MemtoReg <= 0;
        		ALUOp <= 'b01011;	
        		MemWrite <= 0;	
        		ALUSrc <= 1;	// use immediate value	
        		RegWrite <= 1;
        		//PCSrc <= 0;
        		//FromHigh <= 0;
        		SignExt <= 0;	// 16-bit immediate is zero-extended 
        		Jump <= 0;
        	end

        	XORI: begin
        		RegDst <= 0;	
        		Branch <= 0;
        		MemRead <= 0;	// don't care
        		MemtoReg <= 0;
        		ALUOp <= 'b01100;	
        		MemWrite <= 0;	
        		ALUSrc <= 1;	// use immediate value	
        		RegWrite <= 1;
        		//PCSrc <= 0;
        		//FromHigh <= 0;
        		SignExt <= 0;	// 16-bit immediate is zero-extended 
        		Jump <= 0;
        	end

        	SEH: begin
        		RegDst <= 1;	
        		Branch <= 0;
        		MemRead <= 0;	// don't care
        		MemtoReg <= 0;
        		ALUOp <= 'b01000;	// sign extension 1/2 word
        		MemWrite <= 0;	
        		ALUSrc <= 0;	// use immediate value	
        		RegWrite <= 1;
        		//PCSrc <= 0;
        		//FromHigh <= 0;
        		SignExt <= 0;	// don't care
        		Jump <= 0;
        	end

        	SLTI: begin
        		RegDst <= 0;	 
        		Branch <= 0;
        		MemRead <= 0;	// don't care
        		MemtoReg <= 0;
        		ALUOp <= 'b00111; 
        		MemWrite <= 0;	
        		ALUSrc <= 1;	// use immediate value	
        		RegWrite <= 1;
        		//PCSrc <= 0;
        		//FromHigh <= 0;
        		SignExt <= 1;
        		Jump <= 0;
        	end

            // Multiply and Add/Sub (difference determined in ALU Control)
            MADD_SUB: begin
                RegDst <= 0;    // don't care
                Branch <= 0;
                MemRead <= 0;
                MemtoReg <= 0;  // don't care
                ALUOp <= 'b00011;    // madd_sub
                MemWrite <= 0;
                ALUSrc <= 0;
                RegWrite <= 0; 
               // PCSrc <= 0; 
                //FromHigh <= 0;
                SignExt <= 0;   // don't care
                Jump <= 0;
            end
            
            SEB_SEH : begin
                            RegDst <= 1;    
                            Branch <= 0;
                            MemRead <= 0;    // don't care
                            MemtoReg <= 0;
                            ALUOp <= 'b01000;    // sign extension 1/2 word
                            MemWrite <= 0;    
                            ALUSrc <= 0;    // use immediate value    
                            RegWrite <= 1;
                            //PCSrc <= 0;
                            //FromHigh <= 0;
                            SignExt <= 0;    // don't care
                            Jump <= 0;
                        end
                        
            SLTIU: begin
                            RegDst <= 0;     
                            Branch <= 0;
                            MemRead <= 0;
                            MemtoReg <= 0;
                            ALUOp <= 'b10111; 
                            MemWrite <= 0;    
                            ALUSrc <= 1;
                            RegWrite <= 1;
                            //PCSrc <= 0;
                            //FromHigh <= 0;
                            SignExt <= 1;
                            Jump <= 0;
                        end
            
            default: begin  
                RegDst <= 0;
                Branch <= 0;
                MemRead <= 0;
                MemtoReg <= 0;
                ALUOp <= 'b00010;    
                MemWrite <= 0;
                ALUSrc <= 0;
                RegWrite <= 0;
               //PCSrc <= 0;    
               SignExt <= 0;   
               Jump <= 0;
               end
            
        endcase
end
endmodule


        	




