import XCTest

class TestLoaderTests: XCTestCase {
    private func run(
        _ test: String,
        directory: String = "Gates",
        firstOutputColumn: Int? = nil,
        line: UInt = #line,
        actualsFactory: @escaping ActualsFactory = { _ in [] }
    ) throws {
        try FileBasedATR(name: test,
                         directory: directory,
                         firstOutputColumn: firstOutputColumn,
                         factory: actualsFactory)
            .run(swiftFile: #filePath, swiftLine: line)
    }
    
    private func assertFailure(
        _ message: String,
        test: () throws -> ()
    ) {
        XCTExpectFailure {
            $0.description.contains(message)
        }
        try? test()
    }
    
    private func assertThrows(
        _ message: String,
        test: () throws -> ()
    ) {
        XCTAssertThrowsError(try test()) { error in
            XCTAssertEqual((error as! ATRError).message,
                           message)
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

    func testThrowsWhenIncorrectOutputColumnIsGiven() throws {
        assertThrows("Actual (1) and Expected (3) counts differ") {
            try run("And", firstOutputColumn: 0) { _ in ["1"] }
        }
    }

    func testThrowsWhenOutOfBoundsOutputColumnIsGiven() throws {
        assertThrows("Expected column index is out of bounds") {
            try run("And", firstOutputColumn: 3) { _ in ["1"] }
        }
    }
    
    func testFactoryOnlyReceivesInputColumns() throws {
        try run("And", firstOutputColumn: 2) {
            XCTAssertEqual($0.count, 2)
            return [self.and($0[0], $0[1])]
        }
    }

    func testFailsWhenActualAndExpectedDiffer() throws {
        throw XCTSkip("Too slow for general use")
        let message = "Line 5 column 3: Gates/And.cmp"
        assertFailure(message) {
            try run("And") { _ in ["0"] }
        }
    }
    
    func testPassesWhenAllActualsAndExpectedsMatch() throws {
        try run("And") { [self.and($0[0], $0[1])] }
    }
}
