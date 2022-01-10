import XCTest
@testable import Nand2Tetris

/// Specs:
/// @xxx -> A command
/// dest=comp;jump => computation with jump and destination
///     dest= | comp | jump
///

/*
 """
 // Computes R2 = max(R0, R1)  (R0,R1,R2 refer to RAM[0],RAM[1],RAM[2])

    @R0
    D=M              // D = first number
    @R1
    D=D-M            // D = first number - second number
    @OUTPUT_FIRST
    D;JGT            // if D>0 (first is greater) goto output_first
    @R1
    D=M              // D = second number
    @OUTPUT_D
    0;JMP            // goto output_d
 (OUTPUT_FIRST)
    @R0
    D=M              // D = first number
 (OUTPUT_D)
    @R2
    M=D              // M[2] = D (greatest number)
 (INFINITE_LOOP)
    @INFINITE_LOOP
    0;JMP            // infinite loop
 """
 
 */

class AssemblerTests: XCTestCase {
    var assembler: Assembler!
    
    override func setUp() {
        assembler = Assembler()
    }
    
    func testConvertsACommands() {
        assembler.assemble("@0") => ["0000000000000000"]
        assembler.assemble("@1") => ["0000000000000001"]
        assembler.assemble("@1024") => ["0000010000000000"]
    }
    
    func testPadInstruction() {
        assembler.padInstruction("0;JMP") => ("null=0;JMP")
        assembler.padInstruction("D=M") => ("D=M;null")
        assembler.padInstruction("D") => ("null=D;null")
    }
    
    func testConvertsInstructionsWithoutJump() {
        assembler.assemble("D=M") => ["1111110000010000"]
    }
}
