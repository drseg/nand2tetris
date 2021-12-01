@testable import Nand2Tetris
import XCTest

final class NandTests: XCTestCase {
    
    override func tearDown() {
        let gatesPerAssert = nandGatesUsed/assertsInTest
        let efficiency = gatesPerAssert - minimumNandCalls
        let percentEfficiency = minimumNandCalls.d / gatesPerAssert.d * 100
        print(
"""

** Nand gates used: \(gatesPerAssert)
** Composition cost: \(efficiency) extra gates (\(percentEfficiency)% efficiency)

"""
        )
        
        nandGatesUsed = 0
        assertsInTest = 0
        minimumNandCalls = 0
    }
    
    func test_nand() {
        minimumNandCalls = 1
        
        nand(0, 0) => 1
        nand(0, 1) => 1
        nand(1, 0) => 1
        nand(1, 1) => 0
    }
    
    func test_not() {
        minimumNandCalls = 1
        
        not(0) => 1
        not(1) => 0
    }
    
    func test_and() {
        minimumNandCalls = 2
        
        and(0, 0) => 0
        and(0, 1) => 0
        and(1, 0) => 0
        and(1, 1) => 1
    }
    
    func test_or() {
        minimumNandCalls = 3
        
        or(0, 0) => 0
        or(0, 1) => 1
        or(1, 0) => 1
        or(1, 1) => 1
    }
    
    func test_xor() {
        minimumNandCalls = 4
        
        xor(0, 0) => 0
        xor(0, 1) => 1
        xor(1, 0) => 1
        xor(1, 1) => 0
    }
    
    func test_efficientXor() {
        minimumNandCalls = 4
        
        efficientXor(0, 0) => 0
        efficientXor(0, 1) => 1
        efficientXor(1, 0) => 1
        efficientXor(1, 1) => 0
    }
}

private var assertsInTest = 0
private var minimumNandCalls = 0

infix operator =>

func =><T: Equatable>(_ actual: T, _ expected: T) {
    assertsInTest += 1
    XCTAssertEqual(actual, expected)
}
