import XCTest
@testable import Nand2Tetris

class SymbolResolverTests: XCTestCase {
    private var resolver: SymbolResolver!
    
    override func setUp() {
        resolver = SymbolResolver()
    }
    
    func resolveCommands(_ assembly: String) -> [String: Int] {
        resolver = SymbolResolver()
        resolver.resolveCommands(assembly)
        return resolver.commands
    }
    
    func resolveSymbols(_ assembly: String) -> [String: Int] {
        resolver = SymbolResolver()
        resolver.resolveSymbols(assembly)
        return resolver.symbols
    }
    
    func resolve(_ assembly: String) -> String {
        resolver = SymbolResolver()
        return resolver.resolve(assembly)
    }
    
    func testResolvesEmpty() {
        resolveCommands("") => [:]
        resolveCommands(" ") => [:]
    }
    
    func testResolvesSinglePseudoCommand() {
        resolveCommands("LOOP") => [:]
        resolveCommands("(LOOP)") => ["LOOP": 1]
    }
    
    func testIncrementsCommandAddressCorrectly() {
        resolveCommands("(LOOP)\nM=A\n(END)") => ["LOOP": 1, "END": 2]
    }
    
    func testOnlyResolvesOneCommandPerLine() {
        resolveCommands("(LOOP)(LOOP)") => ["LOOP": 1]
    }
    
    func testDisallowsLeadingDigit() {
        resolveCommands("(1LOOP)") => [:]
        resolveCommands("(LOOP1)") => ["LOOP1": 1]
    }
    
    func testPredefinedSymbols() {
        resolver.staticSymbols["SP"] => 0
        resolver.staticSymbols["LCL"] => 1
        resolver.staticSymbols["ARG"] => 2
        resolver.staticSymbols["THIS"] => 3
        resolver.staticSymbols["THAT"] => 4
        resolver.staticSymbols["SCREEN"] => 16384
        resolver.staticSymbols["KBD"] => 24576
        
        for i in 0...15 {
            resolver.staticSymbols["R\(i)"] => i
        }
    }
    
    func testResolvesSymbols() {
        resolveSymbols("@i") => ["i": 1024]
        resolveSymbols("@i\n@i") => ["i": 1024]

        resolveSymbols("@i\n@j") => ["i": 1024, "j": 1025]
        resolveSymbols("@i\n@i\n@i\n@j") => ["i": 1024, "j": 1025]
    }
    
    func testDoesNotResolveSymbolIfActuallyCommand() {
        resolver.resolveCommands("(TEST)")
        resolver.resolveSymbols("@TEST")
        resolver.symbols => [:]
    }
    
    func testResolvesSymbolsAndCommands() {
        let assembly =
        """
        (LOOP)
        @i
        M=D
        @j
        D=M
        (END)
        @LOOP
        (TEST)
        M=D
        @TEST
        @END
        """
        
        resolver.resolveCommands(assembly)
        resolver.resolveSymbols(assembly)
        
        resolver.commands => ["LOOP": 1, "END": 5, "TEST": 6]
        resolver.symbols => ["i": 1024, "j": 1025]
    }
    
    func testDeletesResolvedCommands() {
        resolve("(LOOP)\n(END)") => ""
    }
    
    
    func testReplacesStaticSymbols() {
        resolve("@R1\n@SP") => "@1\n@0"
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
        @11
        D;JGT
        @1
        D=M
        @13
        0;JMP
        @0
        D=M
        @2
        M=D
        @15
        0;JMP
        """
        
        resolve(assembly) => resolvedAssembly
    }
}
