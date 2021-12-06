@testable import Nand2Tetris
import XCTest

final class Tests: XCTestCase {

    func test_halfAdder() {
        halfAdder(0, 0) => [0, 0].x2
        halfAdder(0, 1) => [0, 1].x2
        halfAdder(1, 0) => [0, 1].x2
        halfAdder(1, 1) => [1, 0].x2
    }
    
    func test_fullAdder() {
        fullAdder(0, 0, 0) => [0, 0].x2
        fullAdder(0, 0, 1) => [0, 1].x2
        fullAdder(0, 1, 0) => [0, 1].x2
        fullAdder(0, 1, 1) => [1, 0].x2
        
        fullAdder(1, 0, 0) => [0, 1].x2
        fullAdder(1, 0, 1) => [1, 0].x2
        fullAdder(1, 1, 0) => [1, 0].x2
        fullAdder(1, 1, 1) => [1, 1].x2
    }
}

private func =><T: Equatable>(_ actual: T, _ expected: T) {
    XCTAssertEqual(actual, expected)
}
