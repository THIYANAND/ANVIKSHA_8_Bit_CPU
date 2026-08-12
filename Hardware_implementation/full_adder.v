module full_adder(
    input A, B, Ci,
    output E, Co
);
    assign E = A ^ B ^ Ci;
    assign Co = (A & B) | (Ci & (A ^ B));
endmodule