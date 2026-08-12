`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.07.2026 19:25:01
// Design Name: 
// Module Name: register_8bit
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


module register_8bit(
    input clk,
    input reset,
    input load,
    input enable,
    input [7:0] I,
    output [7:0] B, // Continuous internal state monitor
    output [7:0] O  // Tri-state output bus
);
    reg [7:0] data_reg;

    always @(posedge clk or posedge reset) begin
        if (reset)
            data_reg <= 8'b00000000;
        else if (load)
            data_reg <= I;
    end

    assign B = data_reg;
    assign O = enable ? data_reg : 8'hzz;
endmodule
