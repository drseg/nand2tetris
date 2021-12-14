import XCTest
import Nand2TetrisTestLoader
@testable import Nand2Tetris

class BitTests: XCTestCase {
    
    func testAcceptance() throws {
        let bit = Bit()
        
        try FileBasedATR("Registers/Bit") {
            let signal = $0[0].clockSignal
            let input = $0[1].toChar
            let load = $0[2].toChar
            
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
        register(decimalInput: "32123", "1", "1") => "0111110101111011"
    }
    
    func testRegisterCanAcceptNegativeInput() {
        register(decimalInput: "-32123", "1", "1") => "1000001010000101"
    }
    
    func testMinInput() {
        register(decimalInput: "-32768", "1", "1") => "1000000000000000"
    }
    
    func testCanConvertNegativeIntX16BackToInt16() {
        max.toDecimal => "-1"
    }
    
    func testCanConvertMin() {
        "1000000000000000".toDecimal => "-32768"
    }
    
    func testCanConvertMax() {
        "0111111111111111".toDecimal => "32767"
    }

    func testAcceptance() throws {
        let register = Register()

        try FileBasedATR("Registers/Register") {
            let signal = $0[0].clockSignal
            let input = $0[1].toBinary(16)
            let load = $0[2].toChar

            return [register(input, load, signal).toDecimal]
        }.run()
    }
}

class Ram8Tests: XCTestCase {
    
    var ram8: RAM8!
    
    override func setUp() {
        ram8 = RAM8()
    }
    
    func testMultiDemux() {
        deMux8Way16(max, "0", "0", "1")
        => [min, max, min, min, min, min, min, min]
    }
    
    func testAcceptance() throws {
        try FileBasedATR("Registers/RAM8") {
            let signal = $0[0].clockSignal
            let input = $0[1].toBinary(16)
            let load = $0[2].toChar
            let address = $0[3].toBinary(3)
            
            return [self.ram8(input, load, address, signal).toDecimal]
        }.run()
    }
}

class Ram64Tests: XCTestCase {
    
    func testAcceptance() throws {
        let ram64 = RAM64()
        
        try FileBasedATR("Registers/RAM64") {
            let signal = $0[0].clockSignal
            let input = $0[1].toBinary(16)
            let load = $0[2].toChar
            let address = $0[3].toBinary(6)
            
            return [ram64(input, load, address, signal).toDecimal]
        }.run()
    }
}

class Ram512Tests: XCTestCase {
    
    func testAcceptance() throws {
        let ram512 = RAM512()
        
        try FileBasedATR("Registers/RAM512") {
            let signal = $0[0].clockSignal
            let input = $0[1].toBinary(16)
            let load = $0[2].toChar
            let address = $0[3].toBinary(9)
            
            return [ram512(input, load, address, signal).toDecimal]
        }.run()
    }
}

class Ram4KTests: XCTestCase {
    
    func testAcceptance() throws {
        let ram4K = RAM4K()

        try FileBasedATR("Registers/RAM4K") {
            let signal = $0[0].clockSignal
            let input = $0[1].toBinary(16)
            let load = $0[2].toChar
            let address = $0[3].toBinary(12)

            return [ram4K(input, load, address, signal).toDecimal]
        }.run()
    }
}

class Ram16KTests: XCTestCase {
    
    func testAcceptance() throws {
        let ram16K = RAM16K()

        try FileBasedATR("Registers/RAM16K") {
            let signal = $0[0].clockSignal
            let input = $0[1].toBinary(16)
            let load = $0[2].toChar
            let address = $0[3].toBinary(14)

            return [ram16K(input, load, address, signal).toDecimal]
        }.run()
    }
}
