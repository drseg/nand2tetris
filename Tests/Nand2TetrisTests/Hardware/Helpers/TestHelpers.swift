import XCTest

infix operator =>: BitwiseShiftPrecedence
infix operator !=>: BitwiseShiftPrecedence

func =><T: Equatable>(_ actual: T, _ expected: T) {
    XCTAssertEqual(actual, expected)
}

func !=><T: Equatable>(_ actual: T, _ expected: T) {
    XCTAssertNotEqual(actual, expected)
}

