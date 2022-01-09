import XCTest
@testable import Nand2Tetris

class SymbolResolverTests: XCTestCase {
    private var resolver: SymbolResolver!
    
    override func setUp() {
        resolver = SymbolResolver()
    }
    
    func resolve(_ assembly: String) -> [String: String] {
        resolver.resolve(assembly)
    }
    
    func testResolvesEmpty() {
        resolve("") => [:]
    }
    
    func testDoesNotResolveComments() {
        resolve("//(LOOP)") => [:]
    }
}
