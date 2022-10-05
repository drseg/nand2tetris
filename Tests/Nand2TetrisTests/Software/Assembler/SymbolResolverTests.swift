import XCTest
@testable import Nand2Tetris

class SymbolResolverTests: XCTestCase {
    func resolve(_ assembly: String) -> String {
        SymbolResolver().resolve(assembly)
    }
    
    func testResolvesEmpty() {
        resolve("") => ""
        resolve(" ") => " "
    }
    
    func testResolvesSinglePseudoCommand() {
        resolve("(LOOP)\n@LOOP") => "@0"
    }

    func testResolvesMultiplePseudoCommands() {
        resolve("(A)\n@A\n(B)\n@B\n(C)\n@C") => "@0\n@1\n@2"
    }

    func testOnlyResolvesOneCommandPerLine() {
        resolve("(LOOP)(LOOP)\n@LOOP") => "@0"
    }

    func testIgnoresSymbolWithLeadingDigit() {
        resolve("(1LOOP)\n@1LOOP") => "(1LOOP)\n@1LOOP"
        resolve("(LOOP1)\n@LOOP1") => "@0"
    }
    
    func testResolvesPredefinedSymbols() {
        resolve("@SP") => "@0"
        resolve("@LCL") => "@1"
        resolve("@ARG") => "@2"
        resolve("@THIS") => "@3"
        resolve("@THAT") => "@4"
        resolve("@SCREEN") => "@16384"
        resolve("@KBD") => "@24576"
        
        for i in 0...15 {
            resolve("@R\(i)") => "@\(i)"
        }
    }
    
    func testResolvesSymbols() {
        resolve("@i") => "@16"
        resolve("@i\n@i") => "@16\n@16"
        resolve("@i\n@j") => "@16\n@17"
    }
    
    func testDoesNotResolveNumbers() {
        resolve("@256") => "@256"
    }
    
    func testDeletesResolvedCommands() {
        resolve("(LOOP)\n(END)") => ""
    }
    
    func testReplacesStaticSymbols() {
        resolve("@R1\n@SP") => "@1\n@0"
    }
    
    func testReplacesDifferentSymbolsWithSamePrefix() {
        /// This is a race condition - 100 iterations seems to expose it consistently
        (1...100).forEach { _ in
            resolve("@A\n@A1") => "@16\n@17"
        }
    }
    
    func testAcceptance() throws {
        let assembly = AssemblyCleaner().clean(
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
        )
        
        let resolvedAssembly =
        """
        @0
        D=M
        @1
        D=D-M
        @10
        D;JGT
        @1
        D=M
        @12
        0;JMP
        @0
        D=M
        @2
        M=D
        @14
        0;JMP
        """
        
        resolve(assembly) => resolvedAssembly
    }
}
