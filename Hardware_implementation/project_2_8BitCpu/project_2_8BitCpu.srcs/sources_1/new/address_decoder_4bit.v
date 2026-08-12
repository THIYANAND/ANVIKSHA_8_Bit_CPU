`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.07.2026 19:23:50
// Design Name: 
// Module Name: address_decoder_4bit
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


module address_decoder_4bit(
    input [3:0] A,
    input Enable,
    output [15:0] D
);
    wire [15:0] decoded;
    
    // 4-to-16 binary decoder logic
    assign decoded = 16'b1 << A; 
    
    // Tri-state buffer controlled by Enable
    assign D = Enable ? decoded : 16'hzzzz;
endmodule