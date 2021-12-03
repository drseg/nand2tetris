@testable import Nand2Tetris
import XCTest
import ReflectiveEquality

final class OneBitTests: XCTestCase {
    
    override func tearDown() {
        if gatesUsed != 0 && assertsInTest != 0 && gatesNeeded != 0 {
            let gatesPerAssert = gatesUsed/assertsInTest
            let efficiency = gatesPerAssert - gatesNeeded
            let percentEfficiency = Int(round(gatesNeeded.d / gatesPerAssert.d * 100))
            print(
"""

** Nand gates used: \(gatesPerAssert)
** Efficiency: \(percentEfficiency)% (\(efficiency) extra gates)

"""
            )
        }
        
        gatesUsed = 0
        assertsInTest = 0
        gatesNeeded = 0
    }
    
    func test_nand() {
        gatesNeeded = 1
        
        nand(0, 0) => 1
        nand(0, 1) => 1
        nand(1, 0) => 1
        nand(1, 1) => 0
    }
    
    func test_not() {
        gatesNeeded = 1
        
        not(0) => 1
        not(1) => 0
    }
    
    func test_and() {
        gatesNeeded = 2
        
        and(0, 0) => 0
        and(0, 1) => 0
        and(1, 0) => 0
        and(1, 1) => 1
    }
    
    func test_or() {
        gatesNeeded = 3
        
        or(0, 0) => 0
        or(0, 1) => 1
        or(1, 0) => 1
        or(1, 1) => 1
    }
    
    func test_xor() {
        gatesNeeded = 4
        
        xor(0, 0) => 0
        xor(0, 1) => 1
        xor(1, 0) => 1
        xor(1, 1) => 0
    }
    
    func test_efficientXor() {
        gatesNeeded = 4
        
        efficientXor(0, 0) => 0
        efficientXor(0, 1) => 1
        efficientXor(1, 0) => 1
        efficientXor(1, 1) => 0
    }
    
    func test_mux() {
        gatesNeeded = 4
        
        mux(0, 0, 0) => 0
        mux(0, 1, 0) => 0
        mux(1, 0, 0) => 1
        mux(1, 1, 0) => 1
        mux(0, 0, 1) => 0
        mux(0, 1, 1) => 1
        mux(1, 0, 1) => 0
        mux(1, 1, 1) => 1
    }
    
    func test_efficientMux() {
        gatesNeeded = 4
        
        efficientMux(0, 0, 0) => 0
        efficientMux(0, 1, 0) => 0
        efficientMux(1, 0, 0) => 1
        efficientMux(1, 1, 0) => 1
        efficientMux(0, 0, 1) => 0
        efficientMux(0, 1, 1) => 1
        efficientMux(1, 0, 1) => 0
        efficientMux(1, 1, 1) => 1
    }
    
    func test_deMux() {
        gatesNeeded = 5

        deMux(0, 0) => (0, 0)
        deMux(1, 0) => (1, 0)
        deMux(0, 1) => (0, 0)
        deMux(1, 1) => (0, 1)
    }
}

class MultiTests: XCTestCase {
    
    let onesAndZeros = 0[8] + 1[8]
    let zerosAndOnes = 1[8] + 0[8]
}

final class MultiBitTests: MultiTests {
    
    func test_not16() {
        
        not16(0[16]) => 1[16]
        not16(1[16]) => 0[16]
        
        not16(onesAndZeros) => zerosAndOnes
        not16(zerosAndOnes) => onesAndZeros
    }
    
    func test_and16() {
        and16(0[16], 0[16]) => 0[16]
        and16(0[16], 1[16]) => 0[16]
        and16(1[16], 0[16]) => 0[16]
        and16(1[16], 1[16]) => 1[16]
        
        and16(onesAndZeros, zerosAndOnes) => 0[16]
    }
    
    func test_or16() {
        or16(0[16], 0[16]) => 0[16]
        or16(0[16], 1[16]) => 1[16]
        or16(1[16], 0[16]) => 1[16]
        or16(1[16], 1[16]) => 1[16]
        
        or16(onesAndZeros, zerosAndOnes) => 1[16]
    }
    
    func test_mux16() {
        mux16(0[16], 0[16], 0) => 0[16]
        mux16(0[16], 0[16], 0) => 0[16]
        mux16(1[16], 0[16], 0) => 1[16]
        mux16(1[16], 1[16], 0) => 1[16]
        mux16(0[16], 0[16], 1) => 0[16]
        mux16(0[16], 1[16], 1) => 1[16]
        mux16(1[16], 0[16], 1) => 0[16]
        mux16(1[16], 1[16], 1) => 1[16]
    }
}

final class MultiWayTests: MultiTests {
    
    func test_or8way() {
        or8Way(0[8]) => 0
        or8Way(1[8]) => 1
        
        or8Way([1,1,1,1,0,0,0,0]) => 1
        or8Way([0,0,0,0,1,1,1,1]) => 1
        or8Way([1,0,1,0,1,0,1,0]) => 1
        or8Way([0,1,0,1,0,1,0,1]) => 1
        or8Way([1,0,0,0,0,0,0,0]) => 1
        or8Way([1,1,1,1,1,1,1,0]) => 1
        or8Way([0,1,1,1,1,1,1,1]) => 1
        or8Way([0,0,0,0,0,0,0,1]) => 1
    }
    
    func test_mux4Way16() {
        mux4Way16(1[16], 0[16], 0[16], 0[16], 0, 0) => 1[16]
        mux4Way16(0[16], 1[16], 0[16], 0[16], 0, 1) => 1[16]
        mux4Way16(0[16], 0[16], 1[16], 0[16], 1, 0) => 1[16]
        mux4Way16(0[16], 0[16], 0[16], 1[16], 1, 1) => 1[16]
        
        mux4Way16(onesAndZeros, onesAndZeros, zerosAndOnes, zerosAndOnes,
                  0, 1)
        => onesAndZeros
    }
    
    func test_mux8Way16() {
        mux8Way16(1[16],0[16],0[16],0[16],0[16],0[16],0[16],0[16],
                  0,0,0)
        => 1[16]
        
        mux8Way16(0[16],1[16],0[16],0[16],0[16],0[16],0[16],0[16],
                  0,0,1)
        => 1[16]
        
        mux8Way16(0[16],0[16],1[16],0[16],0[16],0[16],0[16],0[16],
                  0,1,0)
        => 1[16]
        
        mux8Way16(0[16],0[16],0[16],1[16],0[16],0[16],0[16],0[16],
                  0,1,1)
        => 1[16]
        
        mux8Way16(0[16],0[16],0[16],0[16],1[16],0[16],0[16],0[16],
                  1,0,0)
        => 1[16]
        
        mux8Way16(0[16],0[16],0[16],0[16],0[16],1[16],0[16],0[16],
                  1,0,1)
        => 1[16]
        
        mux8Way16(0[16],0[16],0[16],0[16],0[16],0[16],1[16],0[16],
                  1,1,0)
        => 1[16]
        
        mux8Way16(0[16],0[16],0[16],0[16],0[16],0[16],0[16],1[16],
                  1,1,1)
        => 1[16]
    }
    
    func test_deMux4Way() {
        deMux4Way(1, 0, 0) => (1, 0, 0, 0)
        deMux4Way(1, 0, 1) => (0, 1, 0, 0)
        deMux4Way(1, 1, 0) => (0, 0, 1, 0)
        deMux4Way(1, 1, 1) => (0, 0, 0, 1)
    }
    
    func test_deMux8Way() {
        deMux8Way(1,
                  0, 0, 0)
        => (1, 0, 0, 0, 0, 0, 0, 0)
        
        deMux8Way(1,
                  0, 0, 1)
        => (0, 1, 0, 0, 0, 0, 0, 0)
        
        deMux8Way(1,
                  0, 1, 0)
        => (0, 0, 1, 0, 0, 0, 0, 0)
        
        deMux8Way(1,
                  0, 1, 1)
        => (0, 0, 0, 1, 0, 0, 0, 0)
        
        deMux8Way(1,
                  1, 0, 0)
        => (0, 0, 0, 0, 1, 0, 0, 0)
        
        deMux8Way(1,
                  1, 0, 1)
        => (0, 0, 0, 0, 0, 1, 0, 0)
        
        deMux8Way(1,
                  1, 1, 0)
        => (0, 0, 0, 0, 0, 0, 1, 0)
        
        deMux8Way(1,
                  1, 1, 1)
        => (0, 0, 0, 0, 0, 0, 0, 1)
    }
}

extension Int {
    subscript(_ count: Int) -> [Int] {
        get { x(n: count) }
    }
    
    func x(n: Int) -> [Int] {
        Array(repeating: self, count: n)
    }
}

private var assertsInTest = 0
private var gatesNeeded = 0

infix operator =>

func =>(_ actual: Any, _ expected: Any) {
    assertsInTest += 1
    assertSameValue(actual, expected)
}
