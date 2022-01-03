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
    
    #warning("nasty hack")
    func runProgramme() {
        c.run()
        usleep(20000)
    }
    
    func testCanRunDEqualsA() {
        let aEquals12345 = 12345.b
        let dEqualsA = "1110110000010000"
        
        c.load([aEquals12345,
                dEqualsA])
        
        runProgramme()
        cpu.dRegister.value => 12345.b
    }
    
    func testCanRunDEqualsM() {
        let aEquals12345 = 12345.b
        let dEqualsA = "1110110000010000"
        
        let aEquals0 = 0.b
        let mEqualsD = "1110001100001000"
        let dEqualsMplus1 = "1111110111010000"
        
        c.load([aEquals12345,
                dEqualsA,
                aEquals0,
                mEqualsD,
                dEqualsMplus1])
        
        runProgramme()
        cpu.dRegister.value => 12346.b
    }
    
    //    func testCanAddTwoAndThree() {
    //        c.load(["0000000000000010",
//                "1110110000010000",
//                "0000000000000011",
//                "1110000010010000",
//                "0000000000000000",
//                "1110001100001000"])
//        c.reset("0")
//
//    }
}
