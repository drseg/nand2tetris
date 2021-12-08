import XCTest
@testable import Nand2Tetris

typealias AssertionFactory = (_ row: [String]) -> [Assertion]
typealias Assertion = (actual: Stringable, expected: Stringable, columnIndex: Int)

class TestLoaderTests: XCTestCase {
    
    private func run(_ resource: String = "And", directory dir: String = "Gates", assertionFactory: AssertionFactory) {
        runAcceptanceTest(named: resource, inside: dir, assertionFactory: assertionFactory)
    }
    
    func testDoesNotLoadNothing() {
        run("cat") { _ in fatalError() }
    }
    
    func testParsesRowsIgnoringHeader() {
        run() { row in
            [(actual: row[2],
              expected: "\(row[0] == "1" && row[1] == "1" ? 1 : 0)",
              columnIndex: 2)]
        }
    }

    func testFailureOutputsCorrectMessage() throws {
        //throw XCTSkip("Slow test - disable when not editing this file")
        
        XCTExpectFailure(issueMatcher: { issue in
            issue.description.contains("AcceptanceTests/Gates/And.cmp: comparison failure at line 5 column 3")
        })
        
        run() { row in
            [(actual: row[2],
              expected: "\(row[0] == "1" && row[1] == "1" ? 0 : 0)",
              columnIndex: 2)]
        }
    }
}

private let rootDirectory = "AcceptanceTests"
private let testFileExtension = "cmp"

func runAcceptanceTest(named name: String, inside dir: String, assertionFactory: AssertionFactory) {
    let tests = testFile(named: name, inside: dir).testableStatements.enumerated().map { lineIndex, statement in
        (assertions: assertionFactory(statement.cells), lineIndex: lineIndex)
    }
    
    tests.forEach { test in
        test.assertions.forEach { assertion in
            let message = failureMessage(fileName: name,
                                         directory: dir,
                                         lineIndex: test.lineIndex,
                                         columnIndex: assertion.columnIndex)
            assertEqual(assertion.actual, assertion.expected, message: message)
        }
    }
}

private func testFile(named name: String, inside dir: String) -> String {
    guard
        let url = url(testName: name, directory: dir),
        let test = try? String(contentsOf: url).trimmed
    else { return "" }
    
    return test
}

private func url(testName: String, directory dir: String) -> URL? {
    Bundle.module.url(forResource: testName,
                      withExtension: testFileExtension,
                      subdirectory: "\(rootDirectory)/\(dir)")
}

private func failureMessage(fileName name: String, directory dir: String, lineIndex: Int, columnIndex: Int) -> String {
    "\n\(rootDirectory)/\(dir)/\(name).\(testFileExtension): comparison failure at line \(lineIndex + 2) column \(columnIndex + 1)"
}

private func assertEqual(_ actual: Stringable, _ expected: Stringable, message: String, line: UInt = #line) {
    XCTAssertEqual(actual.toString, expected.toString, message, line: line)
}

extension String {
    
    var testableStatements: [String] {
        split(separator: "\n").dropFirst().toStrings
    }

    var cells: [String] {
        split(separator: "|").toStrings
    }
    
    var trimmed: String {
        replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\r", with: "")
    }
}

extension Sequence where Element: StringProtocol {
    
    var toStrings: [String] { map { $0.components(separatedBy: "").joined() } }
}

