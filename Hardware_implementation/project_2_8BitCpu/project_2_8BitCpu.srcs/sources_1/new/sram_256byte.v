`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.07.2026 19:26:56
// Design Name: 
// Module Name: sram_256byte
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


module sram_256byte(
    input clk,
    input Clear,
    input Write,
    input Read,
    input [7:0] A,   // 8-bit Address
    input [7:0] D,   // Data Input
    output [7:0] O   // Data Output
);
    reg [7:0] memory_array [0:255];
    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            memory_array[i] = 8'b00000000;
        end
    end
    always @(posedge clk or posedge Clear) begin
        if (Clear) begin
            for (i = 0; i < 256; i = i + 1)
                memory_array[i] <= 8'b00000000;
        end else if (Write) begin
            memory_array[A] <= D;
        end
    end

    // Tri-state output driven by Read pin
    assign O = Read ? memory_array[A] : 8'hzz;
endmodule

// Figure 7 & 8: ROM / Microcode / Program Loader Memory Placeholder
// Note: You must provide a .mem file to initialize this ROM in Vivado
module rom_memory #(parameter WIDTH=8, DEPTH=256, FILE="rom_data.mem")(
    input [$clog2(DEPTH)-1:0] addr,
    output [WIDTH-1:0] data
);
    reg [WIDTH-1:0] rom [0:DEPTH-1];
    
    initial begin
        $readmemb(FILE, rom); // Loads binary data from text file
    end
    
    assign data = rom[addr];
endmodule
