import XCTest

class TestLoaderTests: XCTestCase {
    
    private var runner: AcceptanceTestRunner!
    
    private func run(_ test: String, directory: String = "Gates", firstExpectedColumn: Int? = nil, line: UInt = #line, actualsFactory: @escaping ActualsFactory = { _ in [] }) {
        makeRunner(test,
                   directory: directory,
                   firstExpectedColumn: firstExpectedColumn,
                   line: line,
                   actualsFactory: actualsFactory)
        runner.run()
    }
    
    private func makeSuppressedRunner(_ test: String, firstExpectedColumn: Int? = nil, actualsFactory: @escaping ActualsFactory = { _ in [] }) {
        makeRunner(test,
                   firstExpectedColumn: firstExpectedColumn,
                   actualsFactory: actualsFactory)
        runner.shouldSuppressValidationFailures = true
    }
    
    private func makeRunner(_ test: String, directory: String = "Gates", firstExpectedColumn: Int? = nil, line: UInt = #line, actualsFactory: @escaping ActualsFactory = { _ in [] }) {
        runner = AcceptanceTestRunner(name: test,
                                      directory: directory,
                                      firstExpectedColumn: firstExpectedColumn,
                                      swiftFile: #file,
                                      swiftLine: line,
                                      factory: actualsFactory)
    }
    
    private func expectFailureMessage(_ message: String, whenRunning test: () -> ()) {
        expectFailureMessages([message], whenRunning: test)
    }
    
    private func expectFailureMessages(_ messages: [String], whenRunning test: () -> ()) {
        var failures = [String]()
        XCTExpectFailure { issue in
            failures.append(issue.description)
            return messages.contains(partOf: issue.description)
        }
        
        test()
        
        failures.forEach {
            XCTAssertTrue(messages.contains(partOf: $0))
        }
    }
    
    func testFailsIfFileNotFound() {
        expectFailureMessages(["File not found", "Parsing error"]) {
            run("cat")
            run("And", directory: "cat")
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
    
    func testFailsWhenActualAndExpectedDiffer() throws {
        let message = "AcceptanceTests/Gates/And.cmp: comparison failure at line 5 column 3"
        expectFailureMessage(message) {
            run("And") { _ in [0] }
        }
    }
    
    func testPassesWhenAllActualsAndExpectedsMatch() {
        func and(_ a: String, _ b: String) -> String {
            a == b && a == "1" ? "1" : "0"
        }
        
        run("And") { [and($0[0], $0[1])] }
    }
    
    func testCanSuppressValidationFailures() {
        makeSuppressedRunner("")
        runner.run()
    }
    
    func testFactoryOnlyReceivesColumnsUpToExpectedColumn() {
        func assert(numberOfFactoryArgs: Int, upToIndex i: Int) {
            makeSuppressedRunner("And", firstExpectedColumn: i) {
                XCTAssertEqual($0.count, numberOfFactoryArgs)
                return []
            }
            runner.run()
        }
        
        assert(numberOfFactoryArgs: 0, upToIndex: 0)
        assert(numberOfFactoryArgs: 1, upToIndex: 1)
        assert(numberOfFactoryArgs: 2, upToIndex: 2)
    }
}

extension Array where Element == String {
    
    func contains(partOf s: String) -> Bool {
        contains { s.contains($0) }
    }
}
