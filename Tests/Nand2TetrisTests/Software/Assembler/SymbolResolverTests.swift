import XCTest
@testable import Nand2Tetris

class SymbolResolverTests: XCTestCase {
    private var resolver: SymbolResolver!
    
    override func setUp() {
        resolver = SymbolResolver()
    }
    
    func resolve(_ assembly: String) -> [String: Int] {
        resolver.resolve(assembly)
    }
    
    func testResolvesEmpty() {
        resolve("") => [:]
        resolve(" ") => [:]
    }
    
    func testResolvesSinglePseudoCommand() {
        resolve("LOOP") => [:]
        resolve("(LOOP)") => ["LOOP": 1]
    }
    
    func testDoesNotResolveComments() {
        resolve("//(LOOP)") => [:]
    }
    
    func testResolvesMultiplePseudoCommands() {
        resolve("(LOOP)\n(END)") => ["LOOP": 1, "END": 2]
    }
    
    func testIncrementsCommandAddressCorrectly() {
        resolve("(LOOP)\nM=A\n(END)") => ["LOOP": 1, "END": 3]
    }
    
    func testDoesNotResolveCommentOnSameLineAsPseudoCommand() {
        resolve("(LOOP)//(NULL)\n(END)//(NULL)") => ["LOOP": 1, "END": 2]
    }
    
    func testOnlyResolvesOneCommandPerLine() {
        resolve("(LOOP)(LOOP)") => ["LOOP": 1]
    }
    
    func testDisallowsLeadingDigit() {
        resolve("(1LOOP)") => [:]
        resolve("(LOOP1)") => ["LOOP1": 1]
    }
}
