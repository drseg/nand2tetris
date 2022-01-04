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
    
    func runProgramme() {
        c.run()
        usleep(40000)
    }
    
    func testCanRunDEqualsA() {
        let aEquals12345 = 12345.b
        let dEqualsA = "111 0 110000 010 000".trimmed
        
        c.load([aEquals12345,
                dEqualsA])
        
        runProgramme()
        cpu.dRegister.value => 12345.b
    }
    
    func testCanRunDEqualsM() {
        let setA12345 = 12345.b
        let dEqualsA =      "111 0 110000 010 000".trimmed
        
        let setA0 = 0.b
        let mEqualsD =      "111 0 001100 001 000".trimmed
        let dEqualsMplus1 = "111 1 110111 010 000".trimmed
        
        c.load([setA12345,
                dEqualsA,
                setA0,
                mEqualsD,
                dEqualsMplus1])
        
        runProgramme()
        cpu.dRegister.value => 12346.b
    }
    
    func testCanSaveResultOfAddingTwoAndThreeToAddressZero() {
        c.load(["0000000000000010",
                "1110110000010000",
                "0000000000000011",
                "1110000010010000",
                "0000000000000000",
                "1110001100001000"])
        runProgramme()
        c.memory.value(0.b) => 5.b
    }
}

extension Memory {
    func value(_ address: String) -> String {
        self(0.b, "0", address, "0")
    }
}

extension String {
    var trimmed: String {
        replacingOccurrences(of: " ", with: "")
    }
}
