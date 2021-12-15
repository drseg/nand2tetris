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

class BinaryDecimalConversionTests: XCTestCase {
    
    func testTwosComplement() {
        XCTAssertEqual("-1".toBinary(16), "1111111111111111")
        XCTAssertEqual("-1".toBinary(8), "11111111")
        
        XCTAssertEqual("1".toBinary(16), "0000000000000001")
        XCTAssertEqual("1".toBinary(8), "00000001")
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


protocol RAMTest {
    
    var ram: RAM { get }
    var addressLength: Int { get }
    var testFilePath: String { get }
    
    func runAcceptanceTest() throws
}

extension RAMTest {
    
    func runAcceptanceTest() throws {
        try FileBasedATR(testFilePath) {
            let signal = $0[0].clockSignal
            let input = $0[1].toBinary(16)
            let load = $0[2].toChar
            let address = $0[3].toBinary(addressLength)
            
            return [self.ram(input, load, address, signal).toDecimal]
        }.run()
    }
}

class RAM8Tests: XCTestCase, RAMTest {
    
    let ram: RAM = RAM8()
    let addressLength = 3
    let testFilePath = "Registers/RAM8"
    
    func testAcceptance() throws {
        try runAcceptanceTest()
    }
}

class RAM64Tests: XCTestCase, RAMTest {
    
    let ram: RAM = RAM64()
    let addressLength = 6
    let testFilePath = "Registers/RAM64"
    
    func testAcceptance() throws {
        try runAcceptanceTest()
    }
}

class RAM512Tests: XCTestCase, RAMTest {
    
    let ram: RAM = RAM512()
    let addressLength = 9
    let testFilePath = "Registers/RAM512"
    
    func testAcceptance() throws {
        try runAcceptanceTest()
    }
}

class RAM4KTests: XCTestCase, RAMTest {
    
    let ram: RAM = RAM4K()
    let addressLength = 12
    let testFilePath = "Registers/RAM4K"
    
    func testAcceptance() throws {
        try runAcceptanceTest()
    }
}

class RAM16KTests: XCTestCase, RAMTest {
    
    let ram: RAM = RAM16K()
    let addressLength = 14
    let testFilePath = "Registers/RAM16K"
    
    func testAcceptance() throws {
        try runAcceptanceTest()
    }
}
