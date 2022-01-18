import XCTest
@testable import Nand2Tetris

class AssemblerTests: XCTestCase {
    var assembler: Assembler!
    
    override func setUp() {
        assembler = Assembler()
    }
    
    func assemble(_ assembly: String) -> [String] {
        assembler.toBinary(assembly)
    }
    
    func testConvertsACommands() {
        assemble("@0") => ["0000000000000000"]
        assemble("@1") => ["0000000000000001"]
        assemble("@1024") => ["0000010000000000"]
    }
    
    func testPadComputation() {
        assembler.padComputation("0;JMP") => ("null=0;JMP")
        assembler.padComputation("D=M") => ("D=M;null")
        assembler.padComputation("D") => ("null=D;null")
    }
    
    func testConvertsComputations() {
        assemble("D=M") => ["1111110000010000"]
        assemble("0;JMP") => ["1110101010000111"]
        assemble("D=D-M") => ["1111010011010000"]
        assemble("D=D-A") => ["1110010011010000"]
        assemble("D=D-A;JNE") => ["1110010011010101"]
    }
    
    func testAcceptance() {
        let assembly = """
                    // I'm a hungry little hippo but does it matter?
                    
                    @25  6
                    D                               =A
                    @SP
                    M     =D
                    @13     3
                    0       ;J MP
                    @1
                    D   =M
                    @R   13
                    A=M
                    M=D
                    @1   /  / HE  LP! Someone messed with my assembleee
                    0;J MP
                    (b  all.s etdestin    ation$i f_false 0)
                    @TH IS
                    A=M
                    D   =M
                    @T  HIS
                    A=M+1
                    D=  M
                    @  SP
                    A M=    M+1
                    A       =A-1
                    M=D
                    
                    @   ARG
                    A=      M+      1
                    A=  A+1
                    D=M
                    @   S  P
                    AM =M           +1
                    A=A    -1
                    M=D // Why are cats so strange?
                    @RET_A  DDRESS_LT4
                    D=A
                    // D=A
                    // M=MYCAT
                    @3      8
                    0;    JMP
                    (   RET_A   DD   RESS_LT4)
                    @T  HI  S
                    D=M
                    @   9
                    
                    D  =D+A
                    @R13
                    M=D
                    @   SP
                    AM= M-1
                    D =   M
                    // I'm a very small fish
                    @R13
                    A=M
                    """
        let binary = """
                    0000000100000000
                    1110110000010000
                    0000000000000000
                    1110001100001000
                    0000000010000101
                    1110101010000111
                    0000000000000001
                    1111110000010000
                    0000000000001101
                    1111110000100000
                    1110001100001000
                    0000000000000001
                    1110101010000111
                    0000000000000011
                    1111110000100000
                    1111110000010000
                    0000000000000011
                    1111110111100000
                    1111110000010000
                    0000000000000000
                    1111110111101000
                    1110110010100000
                    1110001100001000
                    0000000000000010
                    1111110111100000
                    1110110111100000
                    1111110000010000
                    0000000000000000
                    1111110111101000
                    1110110010100000
                    1110001100001000
                    0000000000100011
                    1110110000010000
                    0000000000100110
                    1110101010000111
                    0000000000000011
                    1111110000010000
                    0000000000001001
                    1110000010010000
                    0000000000001101
                    1110001100001000
                    0000000000000000
                    1111110010101000
                    1111110000010000
                    0000000000001101
                    1111110000100000
                    """.components(separatedBy: "\n")
        
        let resolver = SymbolResolver()
        let cleaner = AssemblyCleaner()
        
        assemble(
            resolver.resolvingSymbols(
                in: cleaner.clean(
                    assembly
                )
            )
        ) => binary
    }
}
