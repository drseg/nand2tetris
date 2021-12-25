import XCTest
@testable import Nand2TetrisTestLoader

class TestLoaderTests: XCTestCase {
    
    private var runner: ATR!
    
    private func run(
        _ test: String,
        directory: String = "Gates",
        firstExpectedColumn: Int? = nil,
        line: UInt = #line,
        actualsFactory: @escaping ActualsFactory = { _ in [] }
    ) throws {
        makeRunner(test,
                   directory: directory,
                   firstExpectedColumn: firstExpectedColumn,
                   actualsFactory: actualsFactory)
        
        try runner.run(swiftFile: #file, swiftLine: line)
    }
    
    private func makeRunner(
        _ test: String,
        directory: String = "Gates",
        firstExpectedColumn: Int? = nil,
        actualsFactory: @escaping ActualsFactory = { _ in [] }
    ) {
        runner = FileBasedATR(name: test,
                                      directory: directory,
                                      firstExpectedColumn: firstExpectedColumn,
                                      factory: actualsFactory)
    }
    
    private func assertFailureMessage(
        _ message: String,
        whenRunning test: () throws -> ()
    ) {
        XCTExpectFailure { $0.description.contains(message) }
        try? test()
    }
    
    private func assertThrows(
        _ message: String,
        whenRunning test: () throws -> ()
    ) {
        XCTAssertThrowsError(try test()) { error in
            XCTAssertEqual((error as! ATRError).message, message)
        }
    }
    
    private func and(_ a: String, _ b: String) -> String {
        a == b && a == "1" ? "1" : "0"
    }
    
    func testThrowsIfFileNotFound() throws {
        assertThrows("File not found") {
            try run("Cat", directory: "Gates")
        }
    }

    func testThrowsIfDirectoryNotFound() throws {
        assertThrows("File not found") {
            try run("And", directory: "Cat")
        }
    }

    func testThrowsWhenNoActualsFound() throws {
        assertThrows("No actual values found") {
            try run("And")
        }
    }

    func testThrowsWhenIncorrectExpectedColumnIsGiven() throws {
        assertThrows("Actual (1) and Expected (3) counts differ") {
            try run("And", firstExpectedColumn: 0) { _ in ["1"] }
        }
    }

    func testThrowsWhenOutOfBoundsExpectedColumnIsGiven() throws {
        assertThrows("Expected column index is out of bounds") {
            try run("And", firstExpectedColumn: 3) { _ in ["1"] }
        }
    }

    func testFailsWhenActualAndExpectedDiffer() throws {
        let message = "AcceptanceTests/Gates/And.cmp: comparison failure at line 5 column 3"
        assertFailureMessage(message) {
            try run("And") { _ in ["0"] }
        }
    }
    
    func testPassesWhenAllActualsAndExpectedsMatch() throws {
        try run("And") { [self.and($0[0], $0[1])] }
    }
    
    func testFactoryOnlyReceivesColumnsUpToExpectedColumn() throws {
        try run("And", firstExpectedColumn: 2) {
            XCTAssertEqual($0.count, 2)
            return [self.and($0[0], $0[1])]
        }
    }
}

extension Array where Element == String {
    
    func contains(partOf s: String) -> Bool {
        contains { s.contains($0) }
    }
}
