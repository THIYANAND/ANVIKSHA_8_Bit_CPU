`timescale 1ns / 1ps

module program_loader(
    input clk,
    input reset,
    input enable,
    input [7:0] rom_data,
    output reg [7:0] rom_addr,
    output reg [7:0] out_bus,
    output reg programing,
    output reg addr_write,
    output reg ram_write
);
    reg [1:0] state;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= 0;
            rom_addr <= 0;
            programing <= 1;
            addr_write <= 0;
            ram_write <= 0;
            out_bus <= 0;
        end else if (enable && programing) begin
            case (state)
                0: begin 
                    // Step A: Send ROM Address to the Memory Address Register (MAR)
                    out_bus <= rom_addr;
                    addr_write <= 1;
                    ram_write <= 0;
                    state <= 1;
                end
                1: begin 
                    // Step B: Send ROM Data into the RAM
                    out_bus <= rom_data;
                    addr_write <= 0;
                    ram_write <= 1;
                    state <= 2;
                end
                2: begin 
                    // Step C: Move to the next line of code
                    addr_write <= 0;
                    ram_write <= 0;
                    if (rom_addr == 255) begin
                        programing <= 0; // Finish loading when RAM is full
                    end else begin
                        rom_addr <= rom_addr + 1;
                    end
                    state <= 0;
                end
            endcase
        end else if (!enable) begin
            // Reset the loader so it is ready for the next time you use SW1
            programing <= 1;
            rom_addr <= 0;
            state <= 0;
            addr_write <= 0;
            ram_write <= 0;
        end
    end
endmodule