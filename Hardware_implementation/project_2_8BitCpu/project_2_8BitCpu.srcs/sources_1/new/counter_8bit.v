`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.07.2026 19:25:55
// Design Name: 
// Module Name: counter_8bit
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


module counter_8bit(
    input clk,
    input CReset,
    input CEnable,
    input CWrite,
    input [7:0] I,
    output reg [7:0] O
);
    always @(posedge clk or posedge CReset) begin
        if (CReset)
            O <= 8'b00000000;
        else if (CWrite)
            O <= I;          // Parallel Load override
        else if (CEnable)
            O <= O + 1'b1;   // Standard synchronous count
    end
endmodule
