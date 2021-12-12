import XCTest
@testable import Nand2Tetris

class BitTests: XCTestCase {
    
    func testAcceptance() throws {
        let bit = Bit()
        
        try FileBasedATR("Registers/Bit") {
            let cycle = $0[0].isTock
            let input = $0[1].int
            let load = $0[2].int
            
            return [bit.update(input, load, cycle)]
        }.run()
    }
}

class RegisterTests: XCTestCase {
    
    var register: Register!
    
    override func setUp() {
        register = Register()
    }
    
    func testRegisterCanAcceptInt16Input() {
        XCTAssertEqual(register.update(32123, 1, 0), "0111110101111011".x16)
    }
    
    func testRegisterCanAcceptNegativeInput() {
        XCTAssertEqual(register.update(-32123, 1, 0), "1000001010000101".x16)
    }
    
    func testNegativeInputSpecialCase() {
        XCTAssertEqual(register.update(-32768, 1, 0), "1000000000000000".x16)
    }
    
    func testCanConvertNegativeIntX16BackToInt16() {
        XCTAssertEqual("1111111111111111".x16.dec, -1)
    }
    
    func testCanConvertNegativeMax() {
        XCTAssertEqual("1000000000000000".x16.dec, -32768)
    }
    
    func testCanConvertPositiveIntX16() {
        XCTAssertEqual("0111111111111111".x16.dec, 32767)
    }

    func testRegisterAcceptance() throws {
        let register = Register()

        try FileBasedATR("Registers/Register") {
            let time = $0[0].isTock
            let input = Int16($0[1])!
            let load = $0[2].int
            
            return [register.update(input, load, time).dec]
        }.run()
    }
}
