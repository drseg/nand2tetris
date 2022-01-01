import XCTest
@testable import Nand2Tetris

class ComputerTests: CPUTestCase {
    var c: Computer!
    
    override func setUp() {
        super.setUp()
        c = Computer(cpu: cpu)
    }
    
    func testComputerCanLoadProgramme() {
        c.load(["1111111111111111"])
        c.instructions[0] => "1111111111111111"
        c.instructions[1] => "0000000000000000"
        c.instructions.count => 32768
    }
    
    func testLoadErasesPreviousInstructions() {
        c.load(["0000000000000001",
                "1111111111111111"])
        c.load(["0000000000000001"])
        c.instructions[1] => "0000000000000000"
    }
    
    func testClock() {
        
    }
}
