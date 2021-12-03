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
    
    func test_demux() {
        gatesNeeded = 5

        demux(0, 0) => (0, 0)
        demux(1, 0) => (1, 0)
        demux(0, 1) => (0, 0)
        demux(1, 1) => (0, 1)
    }
}

let onesAndZeros = 0.x(n: 8) + 1.x(n: 8)
let zerosAndOnes = 1.x(n: 8) + 0.x(n: 8)

final class MultiBitTests: XCTestCase {
    
    func test_not16() {
        let zeros = 0.x16
        let ones = 1.x16
        
        not16(zeros) => ones
        not16(ones) => zeros
        
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
        mux16(0.x16, 1.x16, 0) => 0.x16
        mux16(1.x16, 0.x16, 0) => 1.x16
        mux16(1.x16, 1.x16, 0) => 1.x16
        mux16(0.x16, 0.x16, 1) => 0.x16
        mux16(0.x16, 1.x16, 1) => 1.x16
        mux16(1.x16, 0.x16, 1) => 0.x16
        mux16(1.x16, 1.x16, 1) => 1.x16
    }
}

final class MultiWayTests: XCTestCase {
    
    func test_or8way() {
        or8Way(0.x8) => 0
        or8Way(1.x8) => 1
        
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
        mux4Way16(1.x16, 0.x16, 0.x16, 0.x16, 0, 0) => 1.x16
        mux4Way16(0.x16, 1.x16, 0.x16, 0.x16, 0, 1) => 1.x16
        mux4Way16(0.x16, 0.x16, 1.x16, 0.x16, 1, 0) => 1.x16
        mux4Way16(0.x16, 0.x16, 0.x16, 1.x16, 1, 1) => 1.x16
        
        mux4Way16(onesAndZeros, onesAndZeros, zerosAndOnes, zerosAndOnes, 0, 1) => onesAndZeros
    }
    
    func test_mux8Way16() {
        mux8Way16(1.x16, 0.x16, 0.x16, 0.x16, 0.x16, 0.x16, 0.x16, 0.x16,
                  0, 0, 0)
        => 1.x16
        
        mux8Way16(0.x16, 1.x16, 0.x16, 0.x16, 0.x16, 0.x16, 0.x16, 0.x16,
                  0, 0, 1)
        => 1.x16
        
        mux8Way16(0.x16, 0.x16, 1.x16, 0.x16, 0.x16, 0.x16, 0.x16, 0.x16,
                  0, 1, 0)
        => 1.x16
        
        mux8Way16(0.x16, 0.x16, 0.x16, 1.x16, 0.x16, 0.x16, 0.x16, 0.x16,
                  0, 1, 1)
        => 1.x16
        
        mux8Way16(0.x16, 0.x16, 0.x16, 0.x16, 1.x16, 0.x16, 0.x16, 0.x16,
                  1, 0, 0)
        => 1.x16
        
        mux8Way16(0.x16, 0.x16, 0.x16, 0.x16, 0.x16, 1.x16, 0.x16, 0.x16,
                  1, 0, 1)
        => 1.x16
        
        mux8Way16(0.x16, 0.x16, 0.x16, 0.x16, 0.x16, 0.x16, 1.x16, 0.x16,
                  1, 1, 0)
        => 1.x16
        
        mux8Way16(0.x16, 0.x16, 0.x16, 0.x16, 0.x16, 0.x16, 0.x16, 1.x16,
                  1, 1, 1)
        => 1.x16
    }
}

extension Array where Element == Int {
    func randomCombination(length: Int) -> [Int] {
        (0..<length).reduce(into: [Int]()) { result, _ in
            result.append(randomElement()!)
        }
    }
}

extension Int {
    var x8: [Int] {
        x(n: 8)
    }
    
    var x16: [Int] {
        x(n: 16)
    }
    
    func x(n: Int) -> [Int] {
        Array(repeating: self, count: n)
    }
}

private var assertsInTest = 0
private var gatesNeeded = 0

infix operator =>

func =>(_ lhs: Any, _ rhs: Any) {
    assertsInTest += 1
    XCTAssertTrue(haveSameValue(lhs, rhs), "Expected \(rhs) but received \(lhs)")
}
