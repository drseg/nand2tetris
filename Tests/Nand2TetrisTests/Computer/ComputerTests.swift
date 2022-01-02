import XCTest
@testable import Nand2Tetris

class ComputerTests: CPUTestCase {
    var c: Computer!
    var screen: FastRAM!
    var keyboard: Keyboard!
    
    override func setUp() {
        super.setUp()
        screen = FastRAM(16384)
        keyboard = MockKeyboard()
        c = Computer(cpu: cpu,
                     memory: Memory(keyboard: keyboard,
                                    screen: screen))
    }
    
    func testCanRunDEqualsA() {
        let aEquals12345 = 12345.b
        let dEqualsA = "1110110000010000"
        
        c.load([aEquals12345,
                dEqualsA])
        c.reset("0")
        
        cpu.dRegister.value => 12345.b
    }
    
    func testCanRunMEqualsD() {
        let aEquals12345 = 12345.b
        let dEqualsA = "1110110000010000"
        let mEqualsD = "1110001100001000"
        
        c.load([aEquals12345,
                dEqualsA,
                mEqualsD])
        c.reset("0")
        
        c.memory(0.b, "0", 12345.b, "1") => 12345.b
    }
}
