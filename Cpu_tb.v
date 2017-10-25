`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////


module Cpu_tb();

reg Clk, reset;

CPU Cpu1(Clk, reset);

initial begin
		Clk <= 1'b0;
		forever #10 Clk <= ~Clk;
	end
	
	initial begin 
	reset <= 1'b1;
	
	@(posedge Clk);
	@(posedge Clk);
	@(posedge Clk);
	#10 reset <= 1'b0;
	
	@(posedge Clk);
	@(posedge Clk);
	@(posedge Clk);
	@(posedge Clk);
	@(posedge Clk);
	@(posedge Clk);
	@(posedge Clk);
	@(posedge Clk);
	@(posedge Clk);
	@(posedge Clk);
	@(posedge Clk);
	@(posedge Clk);
	@(posedge Clk);
end
endmodule
