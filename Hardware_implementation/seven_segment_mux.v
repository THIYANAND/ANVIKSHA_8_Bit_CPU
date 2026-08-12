`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.07.2026 19:31:31
// Design Name: 
// Module Name: seven_segment_mux
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


module seven_segment_mux(
    input clk_100MHz,
    input reset,
    input [7:0] out_reg_data,  // 8-bit data from your CPU's Out Register
    output reg [3:0] anode,    // Active-LOW digit selectors
    output reg [6:0] cathode   // Active-LOW segment selectors (A-G)
);

    // 1. Clock Divider for Refresh Rate
    // We need a refresh rate of ~60-100Hz per digit so it doesn't flicker.
    // A 19-bit counter running at 100MHz flips its top bits fast enough for this.
    reg [19:0] refresh_counter;
    wire [1:0] digit_select;
    
    always @(posedge clk_100MHz or posedge reset) begin
        if (reset)
            refresh_counter <= 0;
        else
            refresh_counter <= refresh_counter + 1;
    end
    
    assign digit_select = refresh_counter[19:18]; // 4 states (00, 01, 10, 11)

    // 2. Anode Activation and Data Routing
    // Basys 3 anodes are active-LOW (0 = ON, 1 = OFF)
    reg [3:0] hex_digit;
    
    always @(*) begin
        case(digit_select)
            2'b00: begin
                anode = 4'b1110;              // Turn ON digit 0 (rightmost)
                hex_digit = out_reg_data[3:0]; // Lower 4 bits of Out Register
            end
            2'b01: begin
                anode = 4'b1101;              // Turn ON digit 1
                hex_digit = out_reg_data[7:4]; // Upper 4 bits of Out Register
            end
            2'b10: begin
                anode = 4'b1011;              // Turn ON digit 2
                hex_digit = 4'b0000;          // Optional: Route PC or other data here
            end
            2'b11: begin
                anode = 4'b0111;              // Turn ON digit 3 (leftmost)
                hex_digit = 4'b0000;          // Optional: Route PC or other data here
            end
            default: begin
                anode = 4'b1111;
                hex_digit = 4'b0000;
            end
        endcase
    end

    // 3. Hexadecimal to 7-Segment Decoder
    // Basys 3 cathodes are active-LOW (0 = LED ON, 1 = LED OFF)
    // Segments are mapped as: {g, f, e, d, c, b, a}
    always @(*) begin
        case(hex_digit)
            4'h0: cathode = 7'b1000000; // 0
            4'h1: cathode = 7'b1111001; // 1
            4'h2: cathode = 7'b0100100; // 2
            4'h3: cathode = 7'b0110000; // 3
            4'h4: cathode = 7'b0011001; // 4
            4'h5: cathode = 7'b0010010; // 5
            4'h6: cathode = 7'b0000010; // 6
            4'h7: cathode = 7'b1111000; // 7
            4'h8: cathode = 7'b0000000; // 8
            4'h9: cathode = 7'b0010000; // 9
            4'hA: cathode = 7'b0001000; // A
            4'hB: cathode = 7'b0000011; // b
            4'hC: cathode = 7'b1000110; // C
            4'hD: cathode = 7'b0100001; // d
            4'hE: cathode = 7'b0000110; // E
            4'hF: cathode = 7'b0001110; // F
            default: cathode = 7'b1111111; // Blank
        endcase
    end

endmodule