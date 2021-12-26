import XCTest

@testable import Nand2Tetris
import AbstractTestCase

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

class RAMTestCase: AbstractTestCase {
    var ram: RAM!
    var addressLength: Int!
    var testFilePath: String!
    
    override var abstractTestClass: XCTest.Type {
        RAMTestCase.self
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

class RAM8Tests: RAMTestCase {
    override func setUp() {
        ram = RAM8()
        addressLength = 3
        testFilePath = "Registers/RAM8"
    }
}

class RAM64Tests: RAMTestCase {
    override func setUp() {
        ram = RAM64()
        addressLength = 6
        testFilePath = "Registers/RAM64"
    }
}

class RAM512Tests: RAMTestCase {
    override func setUp() {
        ram = RAM512()
        addressLength = 9
        testFilePath = "Registers/RAM512"
    }
}

class RAM4KTests: RAMTestCase {
    override func setUp() {
        ram = RAM4K()
        addressLength = 12
        testFilePath = "Registers/RAM4K"
    }
}

class RAM16KTests: RAMTestCase {
    override func setUp() {
        ram = RAM16K()
        addressLength = 14
        testFilePath = "Registers/RAM16K"
    }
}
