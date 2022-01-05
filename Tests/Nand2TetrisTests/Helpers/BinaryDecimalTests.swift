import XCTest
@testable import Nand2Tetris

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
