import XCTest
@testable import Nand2Tetris

class AssemblyCleanerTests: XCTestCase {
    var cleaner: AssemblyCleaner!
    
    override func setUp() {
        cleaner = AssemblyCleaner()
    }
    
    func clean(_ assembly: String) -> String {
        cleaner.clean(assembly)
    }
    
    func testReturnsCleanAssemblyAsIs() {
        clean("") => ""
        clean("a\nb") => "a\nb"
    }
    
    func testDropsLeadingAndTrailingWhitespaces() {
        clean(" a ") => "a"
    }
    
    func testDropsTabs() {
        clean("\ta\t") => "a"
    }
    
    func testDropsEmptyNewLines() {
        clean("\n\n\n\n\n\n\n") => ""
        clean("a\n\na") => "a\na"
        clean("a\n   \na") => "a\na"
    }
    
    func testDropsCommentsOnEachLine() {
        clean("//") => ""
        clean("a //\nb //") => "a\nb"
    }
}
