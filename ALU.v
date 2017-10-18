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
// SHL  | 00011
// SHR  | 00100
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
//
// NOTE:-
// SLT (i.e., set on less than): ALUResult is '32'h000000001' if A < B.
// 
////////////////////////////////////////////////////////////////////////////////

module ALU32Bit(ALUControl, A, B, ALUResult, Zero);

	input [4:0] ALUControl; // control bits for ALU operation
	input [31:0] A, B;	    // inputs - Changed to signed input

	output reg [31:0] ALUResult;	// answer - Changed to 64 bits (Oct. 2)
	output reg Zero;	    // Zero=1 if ALUResult == 0
	
	// High/Lo Registers
	reg [31:0] Hi, Lo;
	
	// Variables
	reg [4:0] temp;
	reg [1:0] store;
	reg [31:0] upper, lower;
	reg signed [31:0] A_s, B_s;
	reg signed [63:0] product, registers, total;
    
	// ALU Operations
    parameter ADD = 5'b00010, SUB = 5'b00110, AND = 5'b000000;
    parameter OR = 5'b00001, SLT = 5'b00111;
    parameter SHL = 5'b00011, SHR = 5'b00100, XOR = 5'b00101;
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
	
	//-----------------------------------------------------------

    always @(ALUControl, A, B) begin
        A_s <= A; B_s <= B;
	    ALUResult <= 32'h0;
        Zero <= 1;
		store <= 1;
		
        case(ALUControl) 
			// Originl Operations
            ADD: begin ALUResult <= A_s + B_s; end // Sign-extend for immediate
            SUB: begin ALUResult <= A_s - B_s; end
            AND: begin ALUResult <= A & B; end // Zero-extend for immediate
            OR: begin ALUResult <= A | B; end // Zero-extend for immediate
			SLT: begin if(A_s < B_s) ALUResult <= 32'h1; end // Set Less than
			SLTU: begin if(A < B) ALUResult <= 32'h1; end
			// Additional Operations
            XOR: begin ALUResult <= A ^ B; end
            NOR: begin ALUResult <= ~(A | B); end
            MUL: begin 
				total <= A_s * B_s; 
				ALUResult <= total[31:0]; // mul does not care about Hi, Lo
			end
			MULT: begin 
				total <= A_s * B_s; 
				ALUResult <= total[31:0]; store <= 2; // Cares about Hi, Lo
			end
			MULTU: begin 
				total <= A * B; 
				ALUResult <= total[31:0]; store <= 2; // Cares about Hi, Lo
			end
			// (<< and >> inserts zeros)
            SHL: begin ALUResult <= A << B[4:0]; end // Same as SLL
            SHR: begin ALUResult <= A >> B[4:0]; end // Same as SRL
			// Comparison - 
			//			ALUResult = 1 when branch condition not met
			BEQ: begin if(!(A == B)) ALUResult <= 32'h1; end
			BGTZ: begin if(A[31] || (A != 0)) ALUResult <= 32'h1; end
			BGEZ: begin if(!A[31]) ALUResult <= 32'h1; end 
			BLEZ: begin if(!(A[31] || (A == 0))) ALUResult <= 32'h1; end
			BLTZ: begin if(!(A[31])) ALUResult <= 32'h1; end
			BNE: begin if(!(A != B)) ALUResult <= 32'h1; end
			// Complex Operations
			MTHI: begin Hi <= A; store <= 0; end // Move to High
            MTLO: begin Lo <= A; store <= 0; end // Move to Low
			MFHI: begin ALUResult <= Hi; store <= 0; end // Move from High
			MFLO: begin ALUResult <= Lo; store <= 0; end // Move from Low
			MADD: begin 
				registers = {Hi, Lo}; 
				product <= A_s * B_s; total <= registers + product;
				ALUResult <= total[32:0]; 
				store <= 2; 
			end
			MSUB: begin
				registers = {Hi, Lo};
				product <= A_s * B_s; total <= registers - product;
				ALUResult <= total[32:0]; 
				store <= 2;
			end
			// Other Operations
			SEB: begin ALUResult <= {{24{B[7]}}, B[7:0]}; end 
			SEH: begin ALUResult <= {{16{B[15]}}, B[15:0]}; end
			ROTR: begin // ROTR and ROTRV can use came state
				temp <= B[4:0] - 1;
				upper <= A << temp; lower <= A >> temp;
				ALUResult <= upper | lower;
			end
			// Can be done with SLT and contents moved outside ALU
			MOVN: begin if(B != 0) ALUResult <= A; end // True result of SLT
			MOVZ: begin if(B == 0) ALUResult <= A; end // False result of SLT
			// ----------------------------------------------
			SRA: begin // SRA and SRAV can use same state
				temp <= B[4:0];
				ALUResult <= A <<< temp; 
			end
			// Default
            default: begin 
                ALUResult <= 32'b0; 
                Zero <= 1;
            end
        endcase
        
        if(ALUResult != 0) begin
            Zero <= 0;
        end
		
		if(store == 1) begin
			Hi <= 32'h0;
			Lo <= ALUResult;
		end
		else if(store == 2) begin
			Hi <= total[63:32];
			Lo <= total[31:0];
		end
	end
endmodule