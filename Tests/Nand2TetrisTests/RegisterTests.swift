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
    
    func testRegisterDefaults() {
        XCTAssertEqual(register.input, "0000000000000000".x16)
        XCTAssertEqual(register.load, 0)
    }
    
    func testRegisterCanAcceptInt16Input() {
        register.update(32123, 1)
        XCTAssertEqual(register.input, "0111110101111011".x16)
        XCTAssertEqual(register.load, 1)
    }
    
    func testRegisterCanAcceptNegativeInput() {
        register.update(-32123, 1)
        XCTAssertEqual(register.input, "1000001010000101".x16)
        XCTAssertEqual(register.load, 1)
    }
    
    func testRegisterDefaultOutput() {
        XCTAssertEqual(register.run(0).toString, "0000000000000000")
    }
    
//    func testRegisterLoad() {
//        register.update(1, 1)
//        XCTAssertEqual(register.run(0).toString, "0000000000000000")
//        XCTAssertEqual(register.run(1).toString, "0000000000000001")
//    }

    func testRegisterAcceptance() {
//        let register = Register()
//        let clock = Clock(register)
//
//        FileBasedATR("Registers/Register") {
//            let time = $0[0]
//            let input = Int16($0[1])!
//            let load = $0[2]
//
//            register.update(input, load)
//
//            return [""]
//        }
    }
}
