`timescale 1ns / 1ps

module ALUControl(ALUOp, Funct, rt, ALUControl, /*Link, Link31, FromHigh,*/ CondMov, ALUSrc1, InstructionBit_6, InstructionBit_9, InstructionBit_21);

	input [3:0] ALUOp;	
					// Operation   	 | 'ALUOp' value
					// ==========================
					// MADD(Funct)        | 00000
					// subtraction   			| 00001
					// determined by funct.     | 00010
					// MSUB(Funct)          | 00011
					// move to lo/hi            | 00100
					// multiplication           | 00101  
					// Shift Left				| 00110
					// slt                      | 00111
					// Sign Extend halfword     | 01000
					// LUI					    | 01001
					// ANDI						| 01010
					// ORI						| 01011
					// XORI						| 01100
					// SLTI						| 01101
					// BEQ						| 01110
					// BGTZ						| 01111
					// MFHI(Funct)			    | 10000
					// MTHI(Funct)		    | 10001
					// MFLO(Funct)         | 10010
					// MTLO(Funct)        | 10011
					// BNE 				    | 10100
					// BLTZ _BGEZ 	| 10101
					// BLEZ 						| 10110
					// addition (sw, lw, addi) | 10111
					// n/a                            | 11000
					// n/a                             | 11001
			
	input [5:0] Funct;	// to determine ALUControl for r-type operations (ALUOp == 0010)
	input [4:0] rt;        // to determine difference between BGEZ and BLTZ

        // To help differentiate instuctions that have the same OpCode and functCode
        input InstructionBit_6;        // to differentiate between ROTRV or SRLV
        input InstructionBit_9;        // to differentiate between SEB and SEH
        input InstructionBit_21;        // to differentiate between ROTR and SRL

	output reg [4:0] ALUControl; 
					// Op   | 'ALUControl' value
					// ==========================
					// AND  | 00000
					// OR   | 00001
					// ADD  | 00010
					// SHL  | 00011
					// SHR  | 00100
					// XOR  | 00101
					// SUB  | 00110
					// SLT  | 00111
					// NOR  | 01000  
					// MUL  | 01001
					// MOVTH| 01010
					// MOVTL| 01011
					// MFHI | 01100
					// MFLO | 01101
					// MADD | 01110
					// MSUB | 01111
					// BEQ  | 10000
					// BGTZ | 10001
					// BGEZ | 10010
					// BLEZ | 10011
					// BLTZ | 10100
					// BNE  | 10101
					// SEB	| 10110 ------ New Section
					// SEH	| 10111
					// ROTR	| 11000
					// MOVZ	| 11010
					// SRA	| 11011
					// SLTU	| 11100
					// MULTU| 11101	
					// MULT	| 11110

	/*output reg Link; 	// Link == 1 if a link instruction (jr, jal). Select bit for a mux between PC + 4 and Data Memory output.
	output reg Link31;	// Link31 == 1 if jump and link (jal). Together wih Link (And module),
					// it is the select bit for a mux between the previous register destination mux and $31 output to Write Data
	output reg FromHigh;// FromHigh == 1 if MFHI */
	output reg CondMov;	// CondMov == 1 if movn or movz. This bit is ANDed with /? ZERO flag and ORed with RegWrite signal
	output reg ALUSrc1;

	/* ALUOp values */
	parameter RTYPE = 'b00010,
				 /* function field codes */
				 ADD = 'b100000, SUB = 'b100010, AND = 'b100100, OR = 'b100101, XOR = 'b100110, NOR = 'b100111, SLT = 'b101010, 
				 MUL = 'b000010, MULT = 'b011000, MULTU = 'b011001, MTHI = 'b010001, MTLO = 'b010011, MFHI = 'b010000, MFLO = 'b010010,
				 
				 // Mubarak added
                                     SLL = 'b000_000,
                                     ROTR_SRL = 'b000_010,
                                     SLLV = 'b000_100,
                                     ROTRV_SRLV = 'b000_110,
                                     MOVN = 'b001_011,
                                     MOVZ = 'b001_010,
                                     ROTRV = 'b000_110,
                                     SRA = 'b000_011,
                                     SRAV = 'b000_111,
                                     SEB_SEH = 'b100_000,
                                     SLTU = 'b101_011,
            
               /* ALUOp codes */
			  ADDITION = 'b10111, SUBTRACTION = 'b00001, MULTIPLICATION = 'b00101,
			  ANDI = 'b01010, ORI = 'b01011, XORI = 'b01100, SLTI = 'b01101, LUI = 'b01001,
			  BEQ = 'b01110, BGTZ = 'b01111, BLEZ = 'b10110, BNE = 'b10100, BLTZ_BGEZ = 'b10101, 
			  MADD_SUB = 'b00011, 
			  	 /* function field codes */
			  	 MADD = 'b00000, MSUB = 'b000100 ;

	always @(*) begin
		case(ALUOp)
		    // determines ALU operation using function field code
			RTYPE: begin
					//Link <= 0;
					//Link31 <= 0;
					ALUControl <= 'b00000;
					CondMov <= 'b0;
					ALUSrc1 <= 'b0;
					//FromHigh <= 0;
				case(Funct)
					ADD: begin
						ALUControl <= 'b00010;
						ALUSrc1 <= 'b0;
					end
					SUB: begin
						ALUControl <= 'b00110;
						ALUSrc1 <= 'b0;
					end
					AND: begin
						ALUControl <= 'b00000;
						ALUSrc1 <= 'b0;
					end
					OR: begin
						ALUControl <= 'b00001;
						ALUSrc1 <= 'b0;
					end
					XOR: begin
						ALUControl <= 'b00101;
						ALUSrc1 <= 'b0;
					end
					NOR: begin
						ALUControl <= 'b01000;
						ALUSrc1 <= 'b0;
					end
					SLT: begin
						ALUControl <= 'b00111;
						ALUSrc1 <= 'b0;
					end
					MUL: begin
						ALUControl <= 'b01001;
						ALUSrc1 <= 'b0;
					end
					MULT: begin
						ALUControl <= 'b01001;
						ALUSrc1 <= 'b0;
					end
					MULTU: begin
						ALUControl <= 'b01001;
						ALUSrc1 <= 'b0;
					end
					MTHI: begin
						ALUControl <= 'b01011;
						ALUSrc1 <= 'b0;
					end
					MTLO: begin
						ALUControl <= 'b01100;
						ALUSrc1 <= 'b0;
					end
					MFHI: begin
						ALUControl <= 'b01100;
						ALUSrc1 <= 'b0;
						//FromHigh <= 1;
					end
					MFLO: begin
						ALUControl <= 'b01101;
						//FromHigh <= 0;
					end
					
                                        SEB_SEH: begin
                                            if(InstructionBit_9 == 'b0) begin    // means instruction is SEB
                                                ALUControl <= 'b10110;                    // SEB control signal
                                                CondMov <= 'b0;
                                                ALUSrc1 <= 'b0;
                                            end
                                            else if(InstructionBit_9 == 'b1) begin    // means instruction is SEH
                                                ALUControl <= 'b10111;                    // SEH control SIGNAL
                                                CondMov <= 'b0;
                                                ALUSrc1 <= 'b0;
                                            end
                                        end
                                        SLL: begin
                                            ALUControl <= 'b00011;        // SLL CONTROL SIGNAL
                                            CondMov <= 'b0;
                                            ALUSrc1 <= 'b1;
                                        end
                                        ROTR_SRL: begin
                                            if(InstructionBit_21 == 'b0) begin        // means instruction is SRL
                                                ALUControl <= 00100;        // SRL CONTROL SIGNAL
                                                CondMov <= 'b0;
                                                ALUSrc1 <= 'b1;
                                            end
                                            else if(InstructionBit_21 == 'b1) begin    // means instruction is ROTR
                                                ALUControl <= 'b11000;        // ROTR CONTROL SIGNAL
                                                CondMov <= 'b0;
                                                ALUSrc1 <= 'b1;       
                                            end
                                        end
                                        SLLV: begin
                                            ALUControl <= 'b00011;     // SLLV CONTROL SIGNAL
                                            CondMov <= 'b0;
                                            ALUSrc1 <= 'b0;
                                        end
                                        ROTRV_SRLV: begin
                                            if(InstructionBit_6 == 'b0) begin    // means the instruction is SRLV
                                                ALUControl<= 'b00100;        // SRLV CONTROL SIGNAL
                                                CondMov <= 'b0;
                                                ALUSrc1 <= 'b0;
                                            end
                                            else if(InstructionBit_6 == 'b1) begin    // means the instruction is ROTRV
                                                ALUControl <= 'b11000;        // ROTRV CONTROL SIGNAL
                                                CondMov <= 'b0 ;
                                                ALUSrc1 <= 'b0;
                                            end
                                        end
                                        SLT: begin
                                            ALUControl <= 'b00111;
                                            CondMov <= 'b0;
                                            ALUSrc1 <= 'b0;
                                        end
                                        MOVN: begin
                                            ALUControl <= 'b11001;     // MOVN CONTROL SIGNAL
                                            CondMov <= 'b1;
                                            ALUSrc1 <= 'b0;
                                        end
                                        MOVZ: begin
                                            ALUControl <= 'b11010;        // MOVZ CONTROL SIGNAL
                                            CondMov <= 'b1;
                                            ALUSrc1 <= 'b0;
                                        end
                                        SRA: begin
                                            ALUControl <= 'b11011;        // SRA CONTROL SIGNAL
                                            CondMov <= 'b0;
                                            ALUSrc1 <= 'b0;
                                        end
                                        SRAV: begin
                                            ALUControl <= 'b11011;        // SRAV CONTROL SIGNAL
                                            CondMov <= 'b0;
                                            ALUSrc1 <= 'b1;
                                        end
                                        SLTU: begin
                                            ALUControl <= 'b11100;        // SLTU CONTROL SIGNAL
                                            CondMov <= 'b0;
                                            ALUSrc1 <= 'b0;
                                        end
					
					default: begin
                        ALUControl <= 'b00000;
                        CondMov <= 'b0;
                        ALUSrc1 <= 'b0;
                         //Link <= 0;
                         //Link31 <= 0;
                         end
                endcase	
			end

			// determines MADD versus MSUB ALU operation using function field code
			MADD_SUB: begin
				case(Funct) 
					MADD: begin
						ALUControl <= 'b01110;
						ALUSrc1 <= 'b0;
					end
					MSUB: begin
						ALUControl <= 'b01111;
						ALUSrc1 <= 'b0;
					end
					default begin
					    ALUControl <= 'b01110;
					    ALUSrc1 <= 'b0;
					    end
				endcase
			end

			// Arithmetic ALU operations
			ADDITION: begin
				ALUControl <= 'b00010;	// ADD
				//Link <= 0;
				//Link31 <= 0;
				CondMov <= 0;
				ALUSrc1 <= 'b0;
			end

			SUBTRACTION: begin
				ALUControl <= 'b00110;
				//Link <= 0;
				//Link31 <= 0;
				CondMov <= 0;
				ALUSrc1 <= 'b0;
			end

			MULTIPLICATION: begin
				ALUControl <= 'b01001;
				//Link <= 0;
				//Link31 <= 0;
				CondMov <= 0;
				ALUSrc1 <= 'b0;
			end
			
			// Branch ALUOps
			BEQ: begin
				ALUControl <= 'b10000;
				//Link <= 0;
				//Link31 <= 0;
				CondMov <= 0;
				ALUSrc1 <= 'b0;
			end
			BGTZ: begin
				ALUControl <= 'b10001;
				//Link <= 0;
				//Link31 <= 0;
				CondMov <= 0;
				ALUSrc1 <= 'b0;
			end
			BLTZ_BGEZ: begin
			    if (rt <= 'b00001) begin   // BGEZ
				ALUControl <= 'b10010;
				ALUSrc1 <= 'b0;
				end
				else begin                       // BLTZ
				ALUControl <= 'b10100;
				//Link <= 0;
                //Link31 <= 0;
				CondMov <= 0;
				ALUSrc1 <= 'b0;
				end
			end
			BLEZ: begin
				ALUControl <= 'b10011;
				//Link <= 0;
                //Link31 <= 0;
				CondMov <= 0;
				ALUSrc1 <= 'b0;
			end
			BNE: begin
				ALUControl <= 'b10101;
				//Link <= 0;
				//Link31 <= 0;
				CondMov <= 0;
				ALUSrc1 <= 'b0;
			end

			// i-type ALUOps
			ANDI: begin
				ALUControl <= 'b00000;	//AND
				//Link <= 0;
				//Link31 <= 0;
				CondMov <= 0;
				ALUSrc1 <= 'b0;
			end
			ORI: begin
				ALUControl <= 'b00001;	//OR
				//Link <= 0;
				//Link31 <= 0;
				CondMov <= 0;
				ALUSrc1 <= 'b0;
			end
			XORI: begin
				ALUControl <= 'b00101;	//XOR
				//Link <= 0;
				//Link31 <= 0;
				CondMov <= 0;
				ALUSrc1 <= 'b0;
			end
			SLTI: begin
				ALUControl <= 'b00111;	//SLT
				//Link <= 0;
				//Link31 <= 0;
				CondMov <= 0;
				ALUSrc1 <= 'b0;
			end
			LUI: begin
				ALUControl <= 'b00011;	// SHL, shift left by 16 and add 16 0's
				//Link <= 0;
				//Link31 <= 0;
				CondMov <= 0;
				ALUSrc1 <= 'b0;
			end
			
			default begin   
			ALUControl <= 'b00000;
			//Link <= 0;
			//Link31 <= 0;
			CondMov <= 0;
			ALUSrc1 <= 'b0;
			end
		endcase
	end
endmodule
	

