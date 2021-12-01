@testable import Nand2Tetris
import XCTest

final class NandTests: XCTestCase {
    
    override func tearDown() {
        let gatesPerAssert = gatesUsed/assertsInTest
        let efficiency = gatesPerAssert - gatesNeeded
        let percentEfficiency = Int(round(gatesNeeded.d / gatesPerAssert.d * 100))
        print(
"""

** Nand gates used: \(gatesPerAssert)
** Efficiency: \(efficiency) extra gates (\(percentEfficiency)% efficiency)

"""
        )
        
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
}

private var assertsInTest = 0
private var gatesNeeded = 0

infix operator =>

func =><T: Equatable>(_ actual: T, _ expected: T) {
    assertsInTest += 1
    XCTAssertEqual(actual, expected)
}
