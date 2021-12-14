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
            let input = Int16($0[1])!.x16
            let load = $0[2].int
            
            return [register(input, load, signal).dec]
        }.run()
    }
}

class Ram8Tests: XCTestCase {
    
    var ram8: RAM8!
    
    override func setUp() {
        ram8 = RAM8()
    }
    
    func testMultiDemux() {
        deMux8Way16("1111111111111111".x16, 0, 0, 1)
        => ["0000000000000000".x16, "1111111111111111".x16, "0000000000000000".x16, "0000000000000000".x16, "0000000000000000".x16, "0000000000000000".x16, "0000000000000000".x16, "0000000000000000".x16]
    }
    
    func testAcceptance() throws {
        try FileBasedATR("Registers/RAM8") {
            let signal = $0[0].clockSignal
            let input = Int16($0[1])!.x16
            let load = $0[2].int
            let address = Int16($0[3])!.x3
            
            return [self.ram8(input, load, address, signal).dec]
        }.run()
    }
}

class Ram64Tests: XCTestCase {
    
    private var ram64: RAM64!
    
    override func setUp() {
        ram64 = RAM64()
    }
    
    func testSingleOutput() {
        ram64("0000000000000000".x16, 1, "000000".x6, 1)
        => "0000000000000000".x16
    }
    
    func testSequentialOutput() {
        let _ = ram64("1111111111111111".x16, 1, "000001".x6, 1)
        
        ram64("0000000000000000".x16, 0, "000001".x6, 0)
        => "1111111111111111".x16
    }
    
    func testAcceptance() throws {
        let ram64 = RAM64()
        
        try FileBasedATR("Registers/RAM8") {
            let signal = $0[0].clockSignal
            let input = Int16($0[1])!.x16
            let load = $0[2].int
            let address = Int16($0[3])!.x6
            
            return [ram64(input, load, address, signal).dec]
        }.run()
    }
}

class Ram512Tests: XCTestCase {
    
    func testAcceptance() throws {
        let ram512 = CheatingRAM512()
        
        try FileBasedATR("Registers/RAM8") {
            let signal = $0[0].clockSignal
            let input = Int16($0[1])!.x16
            let load = $0[2].int
            let address = Int16($0[3])!.x9
            
            return [ram512(input, load, address, signal).dec]
        }.run()
    }
}
