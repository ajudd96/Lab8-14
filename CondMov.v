`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2017 02:58:42 PM
// Design Name: 
// Module Name: CondMov
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

 // or (RegWrite_Or, WB_RegWrite, AndCondMovResult);
   //and (BranchAndResult, MEM_Branch, MEM_ZeroFlag)
  // and (AndCondMovResult, MEM_ZeroFlag, MEM_CondMov);

module CondMov(RegWrite, CondMov, Zero, Write);
    
    input RegWrite, CondMov, Zero;
    output reg Write;
    
    reg And1, And2;
    
    always@(*) begin
        And1 <= RegWrite & ~CondMov; 
        And2 <= CondMov  & Zero;
        Write <= And1 | And2;
    end
    
endmodule
