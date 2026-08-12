`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.07.2026 19:26:26
// Design Name: 
// Module Name: alu_8bit
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


module alu_8bit(
    input [7:0] A, // First operand (e.g., Accumulator)
    input [7:0] B, // Second operand
    input Su,      // Subtract control
    input En,      // Output Enable
    output [7:0] O, // Tri-state output
    output CF,     // Carry Flag
    output ZF      // Zero Flag
);
    wire [7:0] b_xor;
    wire [7:0] sum;
    wire carry_out;
    
    // Two's complement preparation: Invert B if subtracting
    assign b_xor = B ^ {8{Su}}; 
    
    // Arithmetic computation (Ripple-carry behavior synthesized by Vivado)
    assign {carry_out, sum} = A + b_xor + Su; 
    
    // Flag assignments
    assign CF = carry_out;
    assign ZF = (sum == 8'b00000000) ? 1'b1 : 1'b0;
    
    // Tri-state buffer output
    assign O = En ? sum : 8'hzz;
endmodule
