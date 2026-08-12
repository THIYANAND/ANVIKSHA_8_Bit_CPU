`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: instruction_decoder
// Description: 1024x17 Microcode ROM with Zero-Initialization and Step Counter
//////////////////////////////////////////////////////////////////////////////////

module instruction_decoder(
    input clk,
    input clear,
    input pm,             // Program Mode switch
    input zf,             // Zero Flag from ALU
    input cf,             // Carry Flag from ALU
    input [4:0] opcode,   // 5-bit Opcode from Instruction Register
    output [16:0] ctrl_out // 17-bit control word out to CPU
);

    // 1. 3-bit Step Counter (0 to 7 sequence for instruction execution)
    reg [2:0] step_counter;
    
    initial begin
        step_counter = 3'b000; // Prevent 'X' on startup!
    end

    always @(posedge clk or posedge clear) begin
        if (clear)
            step_counter <= 3'b000;
        else
            step_counter <= step_counter + 1'b1;
    end

    // 2. 10-bit ROM Address: {ZF, CF, Opcode[4:0], Step[2:0]}
    wire [9:0] rom_addr = {2'b00, opcode, step_counter};

    // 3. 1024 x 17 Microcode ROM Array (Zero-Initialized!)
    reg [16:0] micro_rom [0:1023];
    integer i;

    initial begin
        // Zero out every memory slot first so unused addresses never output 'X'
        for (i = 0; i < 1024; i = i + 1) begin
            micro_rom[i] = 17'b0;
        end
        // Load your microcode file over the zeros
        $readmemb("microcode.mem", micro_rom);
    end

    // 4. Look up the control word from ROM
    wire [16:0] raw_ctrl = micro_rom[rom_addr];

    // 5. Output Assignment:
    // When in Program Mode (pm = 1), output all zeros so the CPU stays quiet.
    // When in Execution Mode (pm = 0), output the active microcode control word.
    assign ctrl_out = pm ? 17'b0 : raw_ctrl;

endmodule