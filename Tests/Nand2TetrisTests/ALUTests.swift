@testable import Nand2Tetris
import XCTest

final class ALUTests: XCTestCase {
    
    func testALUSignature() {
        
    }
}

private func =><T: Equatable>(_ actual: T, _ expected: T) {
    XCTAssertEqual(actual, expected)
}
