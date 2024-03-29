@testable import Nand2Tetris
import XCTest

final class AdderTests: XCTestCase {
    func test_halfAdder() {
        halfAdder("0", "0") => "00"
        halfAdder("0", "1") => "01"
        halfAdder("1", "0") => "01"
        halfAdder("1", "1") => "10"
    }
    
    func test_fullAdder() {
        fullAdder("0", "0", "0") => "00"
        fullAdder("0", "0", "1") => "01"
        fullAdder("0", "1", "0") => "01"
        fullAdder("0", "1", "1") => "10"
        
        fullAdder("1", "0", "0") => "01"
        fullAdder("1", "0", "1") => "10"
        fullAdder("1", "1", "0") => "10"
        fullAdder("1", "1", "1") => "11"
    }

    func test_add16() {
        add16("0000000000000000",
              "0000000000000000")
           => "0000000000000000"
        
        add16("0000000000000000",
              "1111111111111111")
           => "1111111111111111"
        
        add16("1010101010101010",
              "0101010101010101")
           => "1111111111111111"
        
        add16("0011110011000011",
              "0000111111110000")
           => "0100110010110011"
        
        add16("0001001000110100",
              "1001100001110110")
           => "1010101010101010"

        add16("1111111111111111",
              "1111111111111111")
           => "1111111111111110"
        
        add16("0000000000010001",
              "1111111111111111")
           => "0000000000010000"
        ///     17 + (-1) = 16
        
        add16("1111111111101110",
              "1111111111111111")
           => "1111111111101101"
        ///    (-18) + (-1) = -19
    }
    
    func testInc16() {
        inc16("0000000000000000")
           => "0000000000000001"
        
        inc16("1111111111111111")
           => "0000000000000000"
        
        inc16("0000000000000101")
           => "0000000000000110"
        
        inc16("1111111111111011")
           => "1111111111111100"
    }
}

final class ALUTests: XCTestCase {
    func testALU() throws {
        try FileBasedATR("ALU/ALU", firstOutputColumn: 8) {
            let x = $0[0]
            let y = $0[1]
            let zx = $0[2].toChar
            let nx = $0[3].toChar
            let zy = $0[4].toChar
            let ny = $0[5].toChar

            let f = $0[6].toChar
            let no = $0[7].toChar
            
            let actual = alu(x: x,
                             y: y,
                             zx: zx,
                             nx: nx,
                             zy: zy,
                             ny: ny,
                             f: f,
                             no: no)
            
            return [actual.out, actual.zr, actual.ng]
        }.run()
    }
}
