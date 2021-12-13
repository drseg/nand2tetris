import XCTest
@testable import Nand2Tetris

class BitTests: XCTestCase {
    
    func testAcceptance() throws {
        let bit = Bit()
        
        try FileBasedATR("Registers/Bit") {
            let signal = $0[0].clockSignal
            let input = $0[1].int
            let load = $0[2].int
            
            return [bit(input, load, signal)]
        }.run()
    }
}

class RegisterTests: XCTestCase {
    
    var register: Register!
    
    override func setUp() {
        register = Register()
    }
    
    func testRegisterCanAcceptInt16Input() {
        register(32123, 1, 1) => "0111110101111011".x16
    }
    
    func testRegisterCanAcceptNegativeInput() {
        register(-32123, 1, 1) => "1000001010000101".x16
    }
    
    func testMinInput() {
        register(-32768, 1, 1) => "1000000000000000".x16
    }
    
    func testCanConvertNegativeIntX16BackToInt16() {
        "1111111111111111".x16.dec => -1
    }
    
    func testCanConvertMin() {
        "1000000000000000".x16.dec => -32768
    }
    
    func testCanConvertMax() {
        "0111111111111111".x16.dec => 32767
    }

    func testAcceptance() throws {
        let register = Register()

        try FileBasedATR("Registers/Register") {
            let signal = $0[0].clockSignal
            let input = Int16($0[1])!
            let load = $0[2].int
            
            return [register(input, load, signal).dec]
        }.run()
    }
}
