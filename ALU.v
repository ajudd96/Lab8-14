`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// 
// Module - ALU32Bit.v
// Description - 32-Bit wide arithmetic logic unit (ALU).
//
// INPUTS:-
// ALUControl: 4-Bit input control bits to select an ALU operation.
// A: 32-Bit input port A.
// B: 32-Bit input port B.
//
// OUTPUTS:-
// ALUResult: 32-Bit ALU result output.
// ZERO: 1-Bit output flag. 
//
// FUNCTIONALITY:-
// Design a 32-Bit ALU behaviorally, so that it supports addition,  subtraction,
// AND, OR, and set on less than (SLT). The 'ALUResult' will output the 
// corresponding result of the operation based on the 32-Bit inputs, 'A', and 
// 'B'. The 'Zero' flag is high when 'ALUResult' is '0'. The 'ALUControl' signal 
// should determine the function of the ALU based on the table below:-
// Op   | 'ALUControl' value
// ==========================
// AND  | 00000
// OR   | 00001
// ADD  | 00010
// SLL  | 00011
// SRL  | 00100
// XOR  | 00101
// SUB  | 00110
// SLT  | 00111
// NOR  | 01000
// MUL  | 01001
// MTHI | 01010
// MTLO | 01011
// MFHI | 01100
// MFLO | 01101
// MADD | 01110
// MSUB | 01111
// BEQ  | 10000
// BGEZ | 10010
// BLEZ | 10011
// BLTZ | 10100
// BNE  | 10101
// SEB	| 10110 ------ New Section
// SEH	| 10111
// ROTR	| 11000
// MOVN	| 11001
// MOVZ	| 11010
// SRA	| 11011
// SLTU	| 11100
//
// MULTU| 11101	
// MULT	| 11110
// ADDU | 11111

// Test
// NOTE:-
// SLT (i.e., set on less than): ALUResult is '32'h000000001' if A < B.
// 
////////////////////////////////////////////////////////////////////////////////

module ALU32Bit(ALUControl, A, B, Temp_ALUResult, Temp_Zero, Hi, Lo, Temp_64bit_ALUResult);

	input [4:0] ALUControl; 
	input [31:0] A, B, Hi, Lo;	    
	
	output reg [31:0] Temp_ALUResult;
	output reg [63:0] Temp_64bit_ALUResult;
	output reg Temp_Zero;
 	/*
	output [31:0] ALUResult;
	output Zero;
	output [63:0] ALUResult_64bit;
   */
	// ALU Operations
    parameter ADD = 5'b00010, SUB = 5'b00110, AND = 5'b000000, ADDU = 5'b11111;
    parameter OR = 5'b00001, SLT = 5'b00111;
    parameter SLL = 5'b00011, SRL = 5'b00100, XOR = 5'b00101;
    parameter NOR = 5'b01000, MUL = 5'b01001;
	
	// More Complex Operations
	parameter MTHI = 5'b01010, MTLO = 5'b01011;
	parameter MFHI = 5'b01100, MFLO = 5'b01101;
	parameter MADD = 5'b01110, MSUB = 5'b01111;
	
	// Comparison
	parameter BEQ = 5'b10000, BGTZ = 5'b10001, BGEZ = 5'b10010;
	parameter BLEZ = 5'b10011, BLTZ = 5'b10100, BNE = 5'b10101;
	
	// More Operations
	parameter SEB = 5'b10110, SEH = 5'b10111, ROTR = 5'b11000;
	parameter MOVN	= 5'b11001, MOVZ = 5'b11010, SRA = 5'b11011;
	parameter MULT = 5'b11110;
	
	// Unsigned
	parameter SLTU	= 5'b11100, MULTU = 5'b11101;

    initial begin
            Temp_Zero <= 0;
            Temp_ALUResult <= 0;
            Temp_64bit_ALUResult<= 0;
     end
     
	always @(ALUControl, A, B) begin
//        Temp_Zero <= 0;
//	    Temp_ALUResult <= 0;
//	    Temp_64bit_ALUResult<= 0;
	    
        case(ALUControl) 
			// Originl Operations
            ADD: Temp_ALUResult = $signed(A) + $signed(B); 
            ADDU: Temp_ALUResult = $unsigned(A) + $unsigned(B);
			SUB: Temp_ALUResult = $signed(A) - $signed(B);
            AND: Temp_ALUResult = A & B;
            OR: Temp_ALUResult = A | B;
			SLT: Temp_ALUResult = $signed(A) < $signed(B);
			SLTU: Temp_ALUResult = $unsigned(A) < $unsigned(B); 
            XOR: Temp_ALUResult = A ^ B;
            NOR: Temp_ALUResult = ~(A | B);
            MUL: begin 
				Temp_64bit_ALUResult = $signed(A) * $signed(B); 
				Temp_ALUResult = Temp_64bit_ALUResult[31:0]; // mul does not care about Hi, Lo
			end
			
			MULT: Temp_64bit_ALUResult = $signed(A) * $signed(B);
			MULTU: Temp_64bit_ALUResult = $unsigned(A) * $unsigned(B);
			// (<< and >> inserts zeros)
            
            SLL: Temp_ALUResult = B << A;
            SRL: Temp_ALUResult = B >> A;
			/*
			// Comparison - 
			//			ALUResult = 1 when branch condition not met
			BEQ: begin if(!(A == B)) ALUResult <= 32'h1; end
			BGTZ: begin if(A[31] || (A != 0)) ALUResult <= 32'h1; end
			BGEZ: begin if(!A[31]) ALUResult <= 32'h1; end 
			BLEZ: begin if(!(A[31] || (A == 0))) ALUResult <= 32'h1; end
			BLTZ: begin if(!(A[31])) ALUResult <= 32'h1; end
			BNE: begin if(!(A != B)) ALUResult <= 32'h1; end
			// Complex Operations
			*/
			MTHI: Temp_64bit_ALUResult[63:32] = $signed(A); 
            MTLO: Temp_64bit_ALUResult[31:0] = $signed(A); 
            
            MFHI: Temp_ALUResult = $signed(Temp_64bit_ALUResult[63:32]); // Move from High
			MFLO: Temp_ALUResult = $signed(Temp_64bit_ALUResult[31:0]); // Move from Low
			
			//MADD: Temp_64bit_ALUResult = $signed(Temp_64bit_ALUResult) + ( $signed(A) * $signed(B) ); 
			MADD: Temp_64bit_ALUResult = $signed({Hi, Lo}) + ( $signed(A) * $signed(B) ); 
			
			//MSUB: Temp_64bit_ALUResult = $signed(Temp_64bit_ALUResult) - ( $signed(A) * $signed(B) );
			MSUB: Temp_64bit_ALUResult = $signed({Hi, Lo}) - ( $signed(A) * $signed(B) ); 
			// Other Operations
			SEB: Temp_ALUResult = {{24{B[7]}}, B[7:0]};
			/*
			begin
                    Temp_ALUResult[7:0] = B[7:0];
                    Temp_ALUResult[31:8] = {24{B[7]}};
                end
                */
            SEH: Temp_ALUResult = {{16{B[15]}}, B[15:0]};
            /*begin
                    Temp_ALUResult[15:0] = B[15:0];
                    Temp_ALUResult[31:16] = {16{B[15]}};
                end */

			// {32{1'b0}}, (A << 32-B) | (A >> B)}
			ROTR: Temp_ALUResult = { {32{1'b0}}, (B << 32-A[4:0]) | (B >> A[4:0])};
			
			// Can be done with SLT and contents moved outside ALU
			MOVN: if(B != 0) Temp_ALUResult <= A; // how to set flag to value with out getting changed
			MOVZ: if(B == 0) Temp_ALUResult <= A; // how to set flag to value with out getting changed
			// ----------------------------------------------
			
			SRA: Temp_ALUResult <= B >>> A; 
			
			/*
			*/
			// Default
            default: Temp_ALUResult = 32'bX;
        endcase
        

        if(Temp_ALUResult == 0) Temp_Zero <= 1;

/*		
		if(store == 1) begin
			Hi <= 32'h0;
			Lo <= ALUResult;
		end
		else if(store == 2) begin
			Hi <= total[63:32];
			Lo <= total[31:0];
		end
*/
	end
	
//    assign ALUResult = Temp_ALUResult;
//    assign Zero = Temp_Zero;
//    assign ALUResult_64bit = Temp_64bit_ALUResult;

endmodule