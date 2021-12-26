import XCTest

@testable import Nand2Tetris
import AbstractTestCase

class BinaryDecimalConversionTests: XCTestCase {
    func testTwosComplement16() {
        "-1".toBinary() => "1111111111111111"
        "1".toBinary() => "0000000000000001"
        
        "1111111111111111".toDecimal() => "-1"
        "1000000000000000".toDecimal() => "-32768"
        
        "0000000000000001".toDecimal() => "1"
        "0111111111111111".toDecimal() => "32767"
    }
    
    func testTwosComplement8() {
        "-1".toBinary(8) => "11111111"
        "1".toBinary(8) => "00000001"
        
        "11111111".toDecimal(8) => "-1"
        "10000000".toDecimal(8) => "-128"
        
        "00000001".toDecimal(8) => "1"
        "01111111".toDecimal(8) => "127"
    }
    
    func testTwosComplement2() {
        "-1".toBinary(2) => "11"
        "1".toBinary(2) => "01"
        
        "01".toDecimal(2) => "1"
        "11".toDecimal(2) => "-1"
    }
    
    func testTwosComplementAcceptance() {
        (Int8.min...Int8.max).forEach {
            XCTAssertEqual("\($0)".toBinary(8).toDecimal(8), "\($0)")
        }
    }
}

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
    func testAcceptance() throws {
        let register = Register()

        try FileBasedATR("Registers/Register") {
            let signal = $0[0].clockSignal
            let input = $0[1].toBinary()
            let load = $0[2].toChar

            return [register(input, load, signal).toDecimal()]
        }.run()
    }
}

class AbstractRAMTest: AbstractTestCase {
    var ram: RAM!
    var addressLength: Int!
    var testFilePath: String!
    
    override var abstractTestClass: XCTest.Type {
        AbstractRAMTest.self
    }
    
    func testAbstractly() throws {
        try FileBasedATR(testFilePath) { [self] in
            let signal = $0[0].clockSignal
            let input = $0[1].toBinary()
            let load = $0[2].toChar
            let address = $0[3].toBinary(addressLength)
            
            return [ram(input,
                        load,
                        address,
                        signal).toDecimal()]
        }.run()
    }
}

class RAM8Tests: AbstractRAMTest {
    override func setUp() {
        ram = RAM8()
        addressLength = 3
        testFilePath = "Registers/RAM8"
    }
}

class RAM64Tests: AbstractRAMTest {
    override func setUp() {
        ram = RAM64()
        addressLength = 6
        testFilePath = "Registers/RAM64"
    }
}

class RAM512Tests: AbstractRAMTest {
    override func setUp() {
        ram = RAM512()
        addressLength = 9
        testFilePath = "Registers/RAM512"
    }
}

class RAM4KTests: AbstractRAMTest {
    override func setUp() {
        ram = RAM4K()
        addressLength = 12
        testFilePath = "Registers/RAM4K"
    }
}

class RAM16KTests: AbstractRAMTest {
    override func setUp() {
        ram = RAM16K()
        addressLength = 14
        testFilePath = "Registers/RAM16K"
    }
}
