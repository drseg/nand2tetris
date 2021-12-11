import XCTest

class TestLoaderTests: XCTestCase {
    
    private func run(_ test: String, directory: String = "Gates", firstExpectedColumn: Int? = nil, line: UInt = #line, assertionFactory: @escaping ActualsFactory = { _ in [] }) {
        AcceptanceTestRunner(name: test,
                             directory: directory,
                             firstExpectedColumn: firstExpectedColumn,
                             swiftLine: line,
                             factory: assertionFactory)
            .run()
    }
    
    private func expectFailureMessage(_ message: String, whenRunning test: () -> ()) {
        expectFailureMessages([message], whenRunning: test)
    }
    
    private func expectFailureMessages(_ messages: [String], whenRunning test: () -> ()) {
        var failures = [String]()
        XCTExpectFailure { issue in
            failures.append(issue.description)
            return messages.contains { s in
                issue.description.contains(s)
            }
        }
        
        test()
        
        failures.forEach { issue in
            XCTAssertTrue(messages.contains {
                issue.contains($0)
            })
        }
    }
    
    private func and(_ a: String, _ b: String) -> String {
        a == b && a == "1" ? "1" : "0"
    }
    
    func testFailsIfFileNotFound() {
        expectFailureMessages(["File not found", "Parsing error"]) {
            run("cat")
        }
    }
    
    func testFailsWhenNoActualsFound() {
        expectFailureMessage("No actual values found") {
            run("And")
        }
    }
    
    func testFailsWhenIncorrectExpectedColumnIsGiven() {
        expectFailureMessage("Actual (1) and Expected (3) counts differ") {
            run("And", firstExpectedColumn: 0) { _ in ["1"] }
        }
    }
    
    func testFailsWhenOutOfBoundsExpectedColumnIsGiven() {
        expectFailureMessage("Expected column index is out of bounds") {
            run("And", firstExpectedColumn: 3) { _ in ["1"] }
        }
    }
    
    func testFactoryOnlyReceivesGivensInTestSentence() {
        expectFailureMessage("No actual values found") {
            run("And") {
                XCTAssertEqual($0.count, 2)
                return []
            }
        }
    }
    
    func testPassesWhenActualAndExpectedMatch() {
        run("And") { [self.and($0[0], $0[1])] }
    }
    
    func testFailsWhenActualAndExpectedDiffer_WithCorrectMessage() throws {
        let message = "AcceptanceTests/Gates/And.cmp: comparison failure at line 5 column 3"
        expectFailureMessage(message) {
            run("And") { _ in [0] }
        }
    }
}
