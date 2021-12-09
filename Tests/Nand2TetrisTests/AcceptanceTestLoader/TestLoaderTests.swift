import XCTest

class TestLoaderTests: XCTestCase {
    
    private func run(_ test: String, directory: String = "Gates", assertionFactory: @escaping AssertionFactory = { _ in [] }, shouldDoNothing: Bool = false) {
        let e = expectation(description: "")
        e.assertForOverFulfill = false
        e.isInverted = shouldDoNothing
        
        AcceptanceTestRunner(name: test, directory: directory) {
            e.fulfill()
            return assertionFactory($0)
        }.run()
        
        waitForExpectations(timeout: 0.01, handler: nil)
    }
    
    func testDoesNothingIfFileNotFound() {
        run("cat", shouldDoNothing: true)
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
        let expectedMessage =
"""
AcceptanceTests/Gates/And.cmp: comparison failure at line 5 column 3
"""
        XCTExpectFailure { issue in
            issue.description.contains(expectedMessage)
        }
        
        run("And") { givenThen in
            [(actual: givenThen[2],
              expected: "0",
              columnIndex: 2)]
        }
    }
}
