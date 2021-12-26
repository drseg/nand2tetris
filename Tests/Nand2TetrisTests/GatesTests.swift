@testable import Nand2Tetris
import XCTest

final class OneBitTests: XCTestCase {
    func test_nand() {
        nand("0", "0") => "1"
        nand("0", "1") => "1"
        nand("1", "0") => "1"
        nand("1", "1") => "0"
    }
    
    func test_not() {
        not("0") => "1"
        not("1") => "0"
    }
    
    func test_and() {
        and("0", "0") => "0"
        and("0", "1") => "0"
        and("1", "0") => "0"
        and("1", "1") => "1"
    }
    
    func test_or() {
        or("0", "0") => "0"
        or("0", "1") => "1"
        or("1", "0") => "1"
        or("1", "1") => "1"
    }
    
    func test_xor() {
        xor("0", "0") => "0"
        xor("0", "1") => "1"
        xor("1", "0") => "1"
        xor("1", "1") => "0"
    }
    
    func test_mux() {
        mux("0", "0", "0") => "0"
        mux("0", "1", "0") => "0"
        mux("1", "0", "0") => "1"
        mux("1", "1", "0") => "1"
        mux("0", "0", "1") => "0"
        mux("0", "1", "1") => "1"
        mux("1", "0", "1") => "0"
        mux("1", "1", "1") => "1"
    }
    
    func test_deMux() {
        deMux("0", "0") => "00"
        deMux("1", "0") => "10"
        deMux("0", "1") => "00"
        deMux("1", "1") => "01"
    }
}

let min = "0000000000000000"
let max = "1111111111111111"
let zerosAndOnes = "0000000011111111"
let onesAndZeros = "1111111100000000"

final class MultiBitTests: XCTestCase {
    func test_not16() {
        not16(min) => max
        not16(max) => min

        not16(onesAndZeros) => zerosAndOnes
        not16(zerosAndOnes) => onesAndZeros
    }
    
    func test_and16() {
        and16(min, min) => min
        and16(min, max) => min
        and16(max, min) => min
        and16(max, max) => max
        
        and16(onesAndZeros, zerosAndOnes) => min
    }
    
    func test_or16() {
        or16(min, min) => min
        or16(min, max) => max
        or16(max, min) => max
        or16(max, max) => max
        
        or16(onesAndZeros, zerosAndOnes) => max
    }
    
    func test_mux16() {
        mux16(min, min, "0") => min
        mux16(min, min, "0") => min
        mux16(max, min, "0") => max
        mux16(max, max, "0") => max
        mux16(min, min, "1") => min
        mux16(min, max, "1") => max
        mux16(max, min, "1") => min
        mux16(max, max, "1") => max
    }
}

final class MultiWayTests: XCTestCase {
    func test_or8way() {
        or8Way("00000000") => "0"
        or8Way("11111111") => "1"
        
        or8Way("11110000") => "1"
        or8Way("00001111") => "1"
        or8Way("10101010") => "1"
        or8Way("01010101") => "1"
        or8Way("10000000") => "1"
        or8Way("11111110") => "1"
        or8Way("01111111") => "1"
        or8Way("00000001") => "1"
    }
    
    func test_mux4Way16() {
        mux4Way16(max, min, min, min, "0", "0") => max
        mux4Way16(min, max, min, min, "0", "1") => max
        mux4Way16(min, min, max, min, "1", "0") => max
        mux4Way16(min, min, min, max, "1", "1") => max
        
        mux4Way16(onesAndZeros, onesAndZeros, zerosAndOnes, zerosAndOnes,
                  "0", "1")
        => onesAndZeros
    }
    
    func test_mux8Way16() {
        mux8Way16(max,min,min,min,min,min,min,min,
                  "0","0","0")
        => max
        
        mux8Way16(min,max,min,min,min,min,min,min,
                  "0","0","1")
        => max
        
        mux8Way16(min,min,max,min,min,min,min,min,
                  "0","1","0")
        => max
        
        mux8Way16(min,min,min,max,min,min,min,min,
                  "0","1","1")
        => max
        
        mux8Way16(min,min,min,min,max,min,min,min,
                  "1","0","0")
        => max
        
        mux8Way16(min,min,min,min,min,max,min,min,
                  "1","0","1")
        => max
        
        mux8Way16(min,min,min,min,min,min,max,min,
                  "1","1","0")
        => max
        
        mux8Way16(min,min,min,min,min,min,min,max,
                  "1","1","1")
        => max
    }
    
    func test_deMux4Way() {
        deMux4Way("1", "0", "0") => "1000"
        deMux4Way("1", "0", "1") => "0100"
        deMux4Way("1", "1", "0") => "0010"
        deMux4Way("1", "1", "1") => "0001"
    }
    
    func test_deMux8Way() {
        deMux8Way("1",
                  "0", "0", "0")
        => "10000000"
        
        deMux8Way("1",
                  "0", "0", "1")
        => "01000000"
        
        deMux8Way("1",
                  "0", "1", "0")
        => "00100000"
        
        deMux8Way("1",
                  "0", "1", "1")
        => "00010000"
        
        deMux8Way("1",
                  "1", "0", "0")
        => "00001000"
        
        deMux8Way("1",
                  "1", "0", "1")
        => "00000100"
        
        deMux8Way("1",
                  "1", "1", "0")
        => "00000010"
        
        deMux8Way("1",
                  "1", "1", "1")
        => "00000001"
    }
}
