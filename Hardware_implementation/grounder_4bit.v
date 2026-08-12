`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.07.2026 19:23:07
// Design Name: 
// Module Name: grounder_4bit
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


module grounder_4bit(
    input Enable,
    output [3:0] G
);
    // When Enable is HIGH, drive LOW (0). Otherwise, High-Z.
    assign G = Enable ? 4'b0000 : 4'bzzzz;
endmodule