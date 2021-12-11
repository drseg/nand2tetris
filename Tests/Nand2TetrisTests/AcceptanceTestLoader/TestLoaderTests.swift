import XCTest

class TestLoaderTests: XCTestCase {
    
    private func run(_ test: String, directory: String = "Gates", line: UInt = #line, assertionFactory: @escaping AssertionFactory = { _ in [] }) {
        AcceptanceTestRunner(name: test,
                             directory: directory,
                             line: line,
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
        func and(_ a: String, _ b: String) -> String {
            a == "1" && b == "1" ? "1" : "0"
        }
        
        run("And") { givenThen in
            [(actual: givenThen[2],
              expected: and(givenThen[0], givenThen[1]),
              columnIndex: 2)]
        }
    }
    
    func testFailsWhenActualAndExpectedDiffer_WithCorrectMessage() throws {
        let message =
"""
AcceptanceTests/Gates/And.cmp: comparison failure at line 5 column 3
"""
        XCTExpectFailure { $0.description.contains(message) }
        
        run("And") { givenThen in
            [(actual: givenThen[2],
              expected: "0",
              columnIndex: 2)]
        }
    }
}
