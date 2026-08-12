`timescale 1ns / 1ps

module cpu_8bit_top(
    input clk_100MHz,    // Basys 3 master clock
    input reset_sw,      // Physical switch for system reset
    input prog_mode_sw,  // Physical switch for programming mode
    output [7:0] leds,   // Debug out
    output [3:0] anode,
    output [6:0] cathode
);

    // ==========================================
    // 1. SMART CLOCK DIVIDER (SIM & HARDWARE)
    // ==========================================
    reg [26:0] clk_div = 0;
    wire clk_cpu;
    always @(posedge clk_100MHz) clk_div <= clk_div + 1;
    
    // Automatically switch clock speeds based on environment!
    `ifndef SYNTHESIS
        // FOR SIMULATION: Extremely fast clock so you don't wait hours
        assign clk_cpu = prog_mode_sw ? clk_div[1] : clk_div[2]; 
    `else
        // FOR BASYS 3 BOARD: Human-visible speed
        assign clk_cpu = prog_mode_sw ? clk_div[22] : clk_div[24]; 
    `endif

    // ==========================================
    // 2. SHARED SYSTEM BUS & OUTPUT WIRES
    // ==========================================
    wire [7:0] main_bus;
    wire [7:0] out_reg_val; 
    
    // Connect output register to LEDs for clean output reading
    assign leds = prog_mode_sw ? main_bus : out_reg_val;
    
    // ==========================================
    // 3. INSTRUCTION DECODER & CONTROL WORDS
    // ==========================================
    wire [16:0] ctrl_word;
    wire [7:0] ir_val;
    wire alu_cf, alu_zf;
    
    instruction_decoder micro_ctrl (
        .clk(clk_cpu),
        .clear(reset_sw),
        .pm(prog_mode_sw),
        .zf(alu_zf),
        .cf(alu_cf),
        .opcode(ir_val[7:3]), 
        .ctrl_out(ctrl_word)
    );

    // Extract individual control signals from the 17-bit control word
    wire sig_OI = ctrl_word[16]; // Output In
    wire sig_JP = ctrl_word[15]; // Jump (PC Load)
    wire sig_CO = ctrl_word[14]; // Counter Out
    wire sig_CE = ctrl_word[13]; // Count Enable
    wire sig_IR = ctrl_word[12]; // Instruction Register In
    wire sig_II = ctrl_word[11]; // Instruction Register Out
    wire sig_RR = ctrl_word[10]; // RAM Read
    wire sig_RW = ctrl_word[9];  // RAM Write
    wire sig_MI = ctrl_word[8];  // MAR In
    wire sig_BO = ctrl_word[7];  // Register B Out
    wire sig_BI = ctrl_word[6];  // Register B In
    wire sig_SU = ctrl_word[5];  // ALU Subtract Mode
    wire sig_EO = ctrl_word[4];  // ALU Out Enable
    wire sig_AO = ctrl_word[3];  // Register A Out
    wire sig_AI = ctrl_word[2];  // Register A In
    wire sig_HL = ctrl_word[1];  // Halt Clock
    wire sig_FI = ctrl_word[0];  // Flags In

    // ==========================================
    // 4. HALT LOGIC 
    // ==========================================
    reg halted = 0;
    always @(posedge clk_cpu or posedge reset_sw) begin
        if (reset_sw) 
            halted <= 1'b0;      // Un-halt on reset
        else if (sig_HL) 
            halted <= 1'b1;      // Freeze CPU when HLT executes
    end

    // ==========================================
    // 5. PROGRAM LOADER MULTIPLEXING
    // ==========================================
    wire prog_mar_load, prog_ram_write, prog_active;
    wire [7:0] rom_addr, rom_data;
    wire [7:0] loader_bus;
    
    // During programming, the loader controls the MAR and RAM Write
    wire mar_load  = prog_mode_sw ? prog_mar_load  : sig_MI;
    wire mem_write = prog_mode_sw ? prog_ram_write : sig_RW;
    
    // During programming, RAM Read is disabled so the loader can drive the bus
    wire mem_read  = prog_mode_sw ? 1'b0 : sig_RR;

    program_loader loader (
        .clk(clk_cpu),
        .reset(reset_sw),
        .enable(prog_mode_sw),
        .rom_data(rom_data),
        .rom_addr(rom_addr),
        .out_bus(loader_bus), 
        .programing(prog_active),
        .addr_write(prog_mar_load),
        .ram_write(prog_ram_write)
    );

    rom_memory #(
        .WIDTH(8), 
        .DEPTH(256), 
        .FILE("rom_data.mem")
    ) prog_rom (
        .addr(rom_addr),
        .data(rom_data)
    );

    // ==========================================
    // 6. BUS ARBITRATION
    // ==========================================
    // Only one component can drive the bus at a time.
    assign main_bus = prog_mode_sw ? loader_bus : 8'hzz;
    assign main_bus = (sig_CO && !prog_mode_sw && !halted) ? pc_val : 8'hzz; 
    
    // FIX: Force ONLY the 4-bit address to the bus during Instruction Out
    assign main_bus = (sig_II && !prog_mode_sw && !halted) ? {4'b0000, ir_val[3:0]} : 8'hzz; 

    // ==========================================
    // 7. CPU COMPONENTS
    // ==========================================
    
    // Register A (Accumulator)
    wire [7:0] regA_out;
    register_8bit regA (
        .clk(clk_cpu), .reset(reset_sw), 
        .load(sig_AI), .enable(prog_mode_sw ? 1'b0 : sig_AO),
        .I(main_bus), .B(regA_out), .O(main_bus)
    );

    // Register B
    wire [7:0] regB_out;
    register_8bit regB (
        .clk(clk_cpu), .reset(reset_sw), 
        .load(sig_BI), .enable(prog_mode_sw ? 1'b0 : sig_BO),
        .I(main_bus), .B(regB_out), .O(main_bus)
    );

    // ALU
    alu_8bit alu (
        .A(regA_out), .B(regB_out), .Su(sig_SU), .En(prog_mode_sw ? 1'b0 : sig_EO),
        .O(main_bus), .CF(alu_cf), .ZF(alu_zf)
    );

    // Program Counter (Frozen if CPU is halted)
    wire [7:0] pc_val;
    counter_8bit pc_reg (
        .clk(clk_cpu), .CReset(reset_sw), 
        .CEnable(sig_CE & ~halted), .CWrite(sig_JP & ~halted),
        .I(main_bus), .O(pc_val)
    );
    
    // Instruction Register (Frozen if CPU is halted)
    register_8bit ir_reg (
        .clk(clk_cpu), .reset(reset_sw), 
        .load(sig_IR & ~halted), .enable(1'b0), // FIX: Disconnected full 8-bit output     
        .I(main_bus), .B(ir_val), .O()
    );
    
    // Memory Address Register (MAR)
    wire [7:0] mem_addr;
    register_8bit mar_reg (
        .clk(clk_cpu), .reset(reset_sw), 
        .load(mar_load), .enable(1'b1),     
        .I(main_bus), .B(), .O(mem_addr)
    );
    
    // 256-Byte SRAM
    sram_256byte ram (
        .clk(clk_cpu), .Clear(1'b0), .Write(mem_write), .Read(mem_read),
        .A(mem_addr), .D(main_bus), .O(main_bus)
    );

    // Output Register
    register_8bit out_reg (
        .clk(clk_cpu), .reset(reset_sw), 
        .load(sig_OI & ~halted), .enable(1'b0),     
        .I(main_bus), .B(out_reg_val), .O()                
    );
    
    // 7-Segment Display Multiplexer (Uses fast clock!)
    seven_segment_mux display_unit (
        .clk_100MHz(clk_100MHz),       // Connects to fast clock
        .reset(reset_sw),              // Connects to your physical reset switch
        .out_reg_data(out_reg_val),    // EXACT MATCH: Maps the module's port to your wire
        .cathode(cathode),
        .anode(anode)
    );
    
endmodule