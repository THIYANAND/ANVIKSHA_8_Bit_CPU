module reverser_8bit(
    input [7:0] I,
    output [7:0] O
);
    // Structurally reverses the bits with zero propagation delay
    assign O[7] = I[0];
    assign O[6] = I[1];
    assign O[5] = I[2];
    assign O[4] = I[3];
    assign O[3] = I[4];
    assign O[2] = I[5];
    assign O[1] = I[6];
    assign O[0] = I[7];
endmodule