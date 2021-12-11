import XCTest

class TestLoaderTests: XCTestCase {
    
    private func run(_ test: String, directory: String = "Gates", firstExpectedColumnIndex: Int? = nil, line: UInt = #line, assertionFactory: @escaping ActualsFactory = { _ in [] }) {
        AcceptanceTestRunner(name: test,
                             directory: directory,
                             firstExpectedColumn: firstExpectedColumnIndex,
                             swiftLine: line,
                             factory: assertionFactory)
            .run()
    }
    
    func testFailsIfFileNotFound() {
        var failures = [String]()
        XCTExpectFailure {
            failures.append($0.description)
            return true
        }

        run("cat")
        
        XCTAssertEqual(failures.count, 2)
        XCTAssertTrue(failures[0].contains("File not found"))
        XCTAssertTrue(failures[1].contains("Parsing error"))
    }
    
    func testPassesWhenActualAndExpectedMatch() {
        run("And") { givenThen in
            [givenThen[2]]
        }
    }
    
    func testFailsWhenActualAndExpectedDiffer_WithCorrectMessage() throws {
        let message =
"""
AcceptanceTests/Gates/And.cmp: comparison failure at line 5 column 3
"""
        XCTExpectFailure { $0.description.contains(message) }
        
        run("And") { _ in [0] }
    }
    
    func testFailsWhenActualAndExpectedCountDiffer() throws {
        let message = "Actual (0) and Expected (3) counts differ"
        XCTExpectFailure { $0.description.contains(message) }
        run("And", firstExpectedColumnIndex: 0)
    }
}
