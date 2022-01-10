import XCTest
@testable import Nand2Tetris

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
        assembler.padComputation("0;JMP") => ("null=0;JMP")
        assembler.padComputation("D=M") => ("D=M;null")
        assembler.padComputation("D") => ("null=D;null")
    }
    
    func testConvertsComputations() {
        assembler.assemble("D=M") => ["1111110000010000"]
        assembler.assemble("0;JMP") => ["1110101010000111"]
        assembler.assemble("D=D-M") => ["1111010011010000"]
        assembler.assemble("D=D-A") => ["1110010011010000"]
        assembler.assemble("D=D-A;JNE") => ["1110010011010101"]
    }
    
    func testAcceptance() throws {
        let assembly = """
                    @256
                    D=A
                    @SP
                    M=D
                    @133
                    0;JMP
                    @1
                    D=M
                    @R13
                    A=M
                    M=D
                    @1
                    0;JMP
                    (ball.setdestination$if_false0)
                    @THIS
                    A=M
                    D=M
                    @THIS
                    A=M+1
                    D=M
                    @SP
                    AM=M+1
                    A=A-1
                    M=D
                    @ARG
                    A=M+1
                    A=A+1
                    D=M
                    @SP
                    AM=M+1
                    A=A-1
                    M=D
                    @RET_ADDRESS_LT4
                    D=A
                    @38
                    0;JMP
                    (RET_ADDRESS_LT4)
                    @THIS
                    D=M
                    @9
                    D=D+A
                    @R13
                    M=D
                    @SP
                    AM=M-1
                    D=M
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
        let resolvedAssembly = resolver.resolve(cleaner.clean(assembly))
        
        assembler.assemble(resolvedAssembly) => binary
    }
}
