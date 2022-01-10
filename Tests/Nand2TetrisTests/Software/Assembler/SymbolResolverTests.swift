import XCTest
@testable import Nand2Tetris

class SymbolResolverTests: XCTestCase {
    private var resolver: SymbolResolver!
    
    override func setUp() {
        resolver = SymbolResolver()
    }
    
    func resolveCommands(_ assembly: String) -> [String: Int] {
        resolver.resolveCommands(assembly)
        return resolver.commands
    }
    
    func resolveSymbols(_ assembly: String) -> [String: Int] {
        resolver.resolveSymbols(assembly)
        return resolver.symbols
    }
    
    func testResolvesEmpty() {
        resolveCommands("") => [:]
        resolveCommands(" ") => [:]
    }
    
    func testResolvesSinglePseudoCommand() {
        resolveCommands("LOOP") => [:]
        resolveCommands("(LOOP)") => ["LOOP": 1]
    }
    
    func testResolvesMultiplePseudoCommands() {
        resolveCommands("(LOOP)\n(END)") => ["LOOP": 1, "END": 2]
    }
    
    func testIncrementsCommandAddressCorrectly() {
        resolveCommands("(LOOP)\nM=A\n(END)") => ["LOOP": 1, "END": 3]
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
        
        for i in 0...15 {
            resolver.staticSymbols["R\(i)"] => i
        }
        
        resolver.staticSymbols["SCREEN"] => 16384
        resolver.staticSymbols["KBD"] => 24576
    }
    
    func testResolvesSymbol() {
        resolveSymbols("@i") => ["i": 1024]
    }
}
