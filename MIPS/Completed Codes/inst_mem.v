`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: inst_mem
// Description: Instruction memory for MIPS processor
//              Pre-loaded with 4 test instructions:
//              1. OR r3, r1, r2
//              2. SUBI r4, r5, 21
//              3. SW r6, 5(r7)
//              4. BEQ r9, r8, 7
//////////////////////////////////////////////////////////////////////////////////

module inst_mem(
    input [31:0] read_address,
    output reg [31:0] inst_out
    );
    
    // Instruction memory: 4 instructions
    reg [31:0] inst [0:3];
    
    // Initialize instructions
    initial begin
        // Instruction 1: OR r3, r1, r2 (R-type)
        // Format: [opcode][rs][rt][rd][shamt][funct]
        // opcode=000000, rs=r1(00001), rt=r2(00010), rd=r3(00011), shamt=00000, funct=100101(OR)
        // Binary: 000000_00001_00010_00011_00000_100101
        inst[0] = 32'b00000000001000100001100000100101;  // 0x00221825
        
        // Instruction 2: SUBI r4, r5, 21 (I-type)
        // Format: [opcode][rs][rt][immediate]
        // opcode=001001(SUBI), rs=r5(00101), rt=r4(00100), immediate=21(0x0015)
        // Binary: 001001_00101_00100_0000000000010101
        inst[1] = 32'b00100100101001000000000000010101;  // 0x24A40015
        
        // Instruction 3: SW r6, 5(r7) (I-type)
        // Format: [opcode][rs][rt][immediate]
        // opcode=101011(SW), rs=r7(00111), rt=r6(00110), immediate=5(0x0005)
        // Binary: 101011_00111_00110_0000000000000101
        inst[2] = 32'b10101100111001100000000000000101;  // 0xACE60005
        
        // Instruction 4: BEQ r9, r8, 7 (I-type)
        // Format: [opcode][rs][rt][immediate]
        // opcode=000100(BEQ), rs=r9(01001), rt=r8(01000), immediate=7(0x0007)
        // Binary: 000100_01001_01000_0000000000000111
        inst[3] = 32'b00010001001010000000000000000111;  // 0x11280007
    end
    
    // Combinational read based on address
    always @(*) begin
        case (read_address)
            32'd0:  inst_out = inst[0];  // OR instruction
            32'd4:  inst_out = inst[1];  // SUBI instruction
            32'd8:  inst_out = inst[2];  // SW instruction
            32'd12: inst_out = inst[3];  // BEQ instruction
            default: inst_out = 32'd0;   // NOP for undefined addresses
        endcase
    end
    
endmodule
