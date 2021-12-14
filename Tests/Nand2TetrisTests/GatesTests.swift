@testable import Nand2Tetris
import XCTest
import Nand2TetrisTestLoader

final class OneBitTests: XCTestCase {
    
    func test_nand() {
        nand(0, 0) => 1
        nand(0, 1) => 1
        nand(1, 0) => 1
        nand(1, 1) => 0
    }
    
    func test_not() {
        not(0) => 1
        not(1) => 0
    }
    
    func test_and() {
        and(0, 0) => 0
        and(0, 1) => 0
        and(1, 0) => 0
        and(1, 1) => 1
    }
    
    func test_or() {
        or(0, 0) => 0
        or(0, 1) => 1
        or(1, 0) => 1
        or(1, 1) => 1
    }
    
    func test_xor() {
        xor(0, 0) => 0
        xor(0, 1) => 1
        xor(1, 0) => 1
        xor(1, 1) => 0
    }
    
    func test_mux() {
        mux(0, 0, 0) => 0
        mux(0, 1, 0) => 0
        mux(1, 0, 0) => 1
        mux(1, 1, 0) => 1
        mux(0, 0, 1) => 0
        mux(0, 1, 1) => 1
        mux(1, 0, 1) => 0
        mux(1, 1, 1) => 1
    }
    
    func test_deMux() {
        deMux(0, 0) => [0, 0].x2
        deMux(1, 0) => [1, 0].x2
        deMux(0, 1) => [0, 0].x2
        deMux(1, 1) => [0, 1].x2
    }
}

class MultiTests: XCTestCase {
    
    let onesAndZeros = (0[8] + 1[8]).x16
    let zerosAndOnes = (1[8] + 0[8]).x16
}

final class MultiBitTests: MultiTests {
    
    func test_not16() {
        
        not16(0.x16) => 1.x16
        not16(1.x16) => 0.x16

        not16(onesAndZeros) => zerosAndOnes
        not16(zerosAndOnes) => onesAndZeros
    }
    
    func test_and16() {
        and16(0.x16, 0.x16) => 0.x16
        and16(0.x16, 1.x16) => 0.x16
        and16(1.x16, 0.x16) => 0.x16
        and16(1.x16, 1.x16) => 1.x16
        
        and16(onesAndZeros, zerosAndOnes) => 0.x16
    }
    
    func test_or16() {
        or16(0.x16, 0.x16) => 0.x16
        or16(0.x16, 1.x16) => 1.x16
        or16(1.x16, 0.x16) => 1.x16
        or16(1.x16, 1.x16) => 1.x16
        
        or16(onesAndZeros, zerosAndOnes) => 1.x16
    }
    
    func test_mux16() {
        mux16(0.x16, 0.x16, 0) => 0.x16
        mux16(0.x16, 0.x16, 0) => 0.x16
        mux16(1.x16, 0.x16, 0) => 1.x16
        mux16(1.x16, 1.x16, 0) => 1.x16
        mux16(0.x16, 0.x16, 1) => 0.x16
        mux16(0.x16, 1.x16, 1) => 1.x16
        mux16(1.x16, 0.x16, 1) => 0.x16
        mux16(1.x16, 1.x16, 1) => 1.x16
    }
}

final class MultiWayTests: MultiTests {
    
    func test_or8way() {
        or8Way(0.x8) => 0
        or8Way(1.x8) => 1
        
        or8Way([1,1,1,1,0,0,0,0].x8) => 1
        or8Way([0,0,0,0,1,1,1,1].x8) => 1
        or8Way([1,0,1,0,1,0,1,0].x8) => 1
        or8Way([0,1,0,1,0,1,0,1].x8) => 1
        or8Way([1,0,0,0,0,0,0,0].x8) => 1
        or8Way([1,1,1,1,1,1,1,0].x8) => 1
        or8Way([0,1,1,1,1,1,1,1].x8) => 1
        or8Way([0,0,0,0,0,0,0,1].x8) => 1
    }
    
    func test_mux4Way16() {
        mux4Way16(1.x16, 0.x16, 0.x16, 0.x16, 0, 0) => 1.x16
        mux4Way16(0.x16, 1.x16, 0.x16, 0.x16, 0, 1) => 1.x16
        mux4Way16(0.x16, 0.x16, 1.x16, 0.x16, 1, 0) => 1.x16
        mux4Way16(0.x16, 0.x16, 0.x16, 1.x16, 1, 1) => 1.x16
        
        mux4Way16(onesAndZeros, onesAndZeros, zerosAndOnes, zerosAndOnes,
                  0, 1)
        => onesAndZeros
    }
    
    func test_mux8Way16() {
        mux8Way16(1.x16,0.x16,0.x16,0.x16,0.x16,0.x16,0.x16,0.x16,
                  0,0,0)
        => 1.x16
        
        mux8Way16(0.x16,1.x16,0.x16,0.x16,0.x16,0.x16,0.x16,0.x16,
                  0,0,1)
        => 1.x16
        
        mux8Way16(0.x16,0.x16,1.x16,0.x16,0.x16,0.x16,0.x16,0.x16,
                  0,1,0)
        => 1.x16
        
        mux8Way16(0.x16,0.x16,0.x16,1.x16,0.x16,0.x16,0.x16,0.x16,
                  0,1,1)
        => 1.x16
        
        mux8Way16(0.x16,0.x16,0.x16,0.x16,1.x16,0.x16,0.x16,0.x16,
                  1,0,0)
        => 1.x16
        
        mux8Way16(0.x16,0.x16,0.x16,0.x16,0.x16,1.x16,0.x16,0.x16,
                  1,0,1)
        => 1.x16
        
        mux8Way16(0.x16,0.x16,0.x16,0.x16,0.x16,0.x16,1.x16,0.x16,
                  1,1,0)
        => 1.x16
        
        mux8Way16(0.x16,0.x16,0.x16,0.x16,0.x16,0.x16,0.x16,1.x16,
                  1,1,1)
        => 1.x16
    }
    
    func test_deMux4Way() {
        deMux4Way(1, 0, 0) => [1, 0, 0, 0].x4
        deMux4Way(1, 0, 1) => [0, 1, 0, 0].x4
        deMux4Way(1, 1, 0) => [0, 0, 1, 0].x4
        deMux4Way(1, 1, 1) => [0, 0, 0, 1].x4
    }
    
    func test_deMux8Way() {
        deMux8Way(1,
                  0, 0, 0)
        => [1, 0, 0, 0, 0, 0, 0, 0].x8
        
        deMux8Way(1,
                  0, 0, 1)
        => [0, 1, 0, 0, 0, 0, 0, 0].x8
        
        deMux8Way(1,
                  0, 1, 0)
        => [0, 0, 1, 0, 0, 0, 0, 0].x8
        
        deMux8Way(1,
                  0, 1, 1)
        => [0, 0, 0, 1, 0, 0, 0, 0].x8
        
        deMux8Way(1,
                  1, 0, 0)
        => [0, 0, 0, 0, 1, 0, 0, 0].x8
        
        deMux8Way(1,
                  1, 0, 1)
        => [0, 0, 0, 0, 0, 1, 0, 0].x8
        
        deMux8Way(1,
                  1, 1, 0)
        => [0, 0, 0, 0, 0, 0, 1, 0].x8
        
        deMux8Way(1,
                  1, 1, 1)
        => [0, 0, 0, 0, 0, 0, 0, 1].x8
    }
}

extension Int {
    subscript(_ count: Int) -> [Int] {
        x(n: count)
    }
    
    func x(n: Int) -> [Int] {
        Array(repeating: self, count: n)
    }
    
    var x8: IntX8 {
        x(n: 8).x8
    }
    
    var x16: IntX16 {
        x(n: 16).x16
    }
}
