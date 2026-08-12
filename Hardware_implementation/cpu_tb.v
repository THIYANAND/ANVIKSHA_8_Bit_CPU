`timescale 1ns / 1ps

module cpu_tb();

    // 1. Declare Testbench Signals
    reg clk_100MHz;
    reg reset_sw;
    reg prog_mode_sw;
    wire [7:0] leds;
    wire [3:0] anode;
    wire [6:0] cathode;

    // 2. Instantiate the CPU (Exactly matching your picture)
    cpu_8bit_top uut (
        .clk_100MHz(clk_100MHz),
        .reset_sw(reset_sw),
        .prog_mode_sw(prog_mode_sw),
        .leds(leds),
        .anode(anode),
        .cathode(cathode)
    );

    // 3. Generate the 100 MHz Master Clock (10ns period)
    always #5 clk_100MHz = ~clk_100MHz;

    // 4. Simulate the Human Switch Flips
    initial begin
        // A. INITIAL STATE: Hold Reset, Start in Programming Mode
        clk_100MHz = 0;
        reset_sw = 1;         // SW0 UP
        prog_mode_sw = 1;     // SW1 UP
        #100;
        
        // B. LOAD PROGRAM: Release Reset, let loader fill the SRAM
        reset_sw = 0;         // SW0 DOWN
        // Wait long enough for the fast simulation loader (clk_div[1]) to hit address 255
        #15000;               

        // C. EXECUTION MODE: Reset the CPU, flip SW1 down to start calculating
        reset_sw = 1;         // SW0 UP (Resets PC to 00)
        prog_mode_sw = 0;     // SW1 DOWN (Execution Mode)
        #100;
        reset_sw = 0;         // SW0 DOWN (Release reset)

        // D. WATCH IT RUN: Give the CPU time to loop through Fibonacci
        #50000;
        
        // End simulation safely
        $finish; 
    end

endmodule