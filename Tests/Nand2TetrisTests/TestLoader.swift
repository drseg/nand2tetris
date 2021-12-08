import XCTest
@testable import Nand2Tetris

typealias AssertionFactory = (_ row: [String]) -> [AssertionTuple]
typealias AssertionTuple = (actual: Stringable, expected: Stringable, columnIndex: Int)

class TestLoaderTests: XCTestCase {
    
    private func run(_ resource: String = "And", directory dir: String = "Gates", assertionFactory: AssertionFactory) {
        runAcceptanceTest(name: resource, directory: dir, factory: assertionFactory)
    }
    
    func testDoesNotLoadNothing() {
        run("cat") { _ in fatalError() }
    }
    
    func testParsesRowsIgnoringHeader() {
        run() { givenThen in
            [(actual: givenThen[2],
              expected: "\(givenThen[0] == "1" && givenThen[1] == "1" ? 1 : 0)",
              columnIndex: 2)]
        }
    }

    func testFailureOutputsCorrectMessage() throws {
        throw XCTSkip("Slow test - disable when not editing this file")
        
        XCTExpectFailure(issueMatcher: { issue in
            issue.description.contains("AcceptanceTests/Gates/And.cmp: comparison failure at line 5 column 3")
        })
        
        run() { givenThen in
            [(actual: givenThen[2],
              expected: "\(givenThen[0] == "1" && givenThen[1] == "1" ? 0 : 0)",
              columnIndex: 2)]
        }
    }
}

private let rootDirectory = "AcceptanceTests"
private let testFileExtension = "cmp"

func runAcceptanceTest(name: String, directory: String, factory: AssertionFactory) {
    let path = directory + "/" + name
    runAcceptanceTest(relativePath: path, factory: factory)
}

func runAcceptanceTest(relativePath: String, factory: AssertionFactory) {
    let tests = makeTestsFromFile(relativePath: relativePath,
                                  factory: factory)
    tests.forEach { $0.run() }
}

private func makeTestsFromFile(relativePath: String, factory: AssertionFactory) -> [Test] {
    testFile(relativePath: relativePath)
        .givenThenSentences
        .enumerated()
        .map { lineIndex, givenThens in
            Test(relativePath: relativePath,
                 assertions: factory(givenThens),
                 lineIndex: lineIndex)
        }
}

private func testFile(relativePath: String) -> String {
    guard
        let url = url(relativePath: relativePath),
        let test = try? String(contentsOf: url).trimmed
    else { return "" }
    
    return test
}

private func url(relativePath: String) -> URL? {
    Bundle.module.url(forResource: relativePath,
                      withExtension: testFileExtension,
                      subdirectory: "\(rootDirectory)/")
}

private struct Test {
    
    let assertions: [Assertion]

    init(relativePath: String, assertions: [AssertionTuple], lineIndex: Int) {
        self.assertions = assertions.map { Assertion(assertionTuple: $0, lineIndex: lineIndex, path: relativePath) }
    }
    
    func run() {
        assertions.forEach { $0.assert() }
    }
}

private struct Assertion {
    
    let actual: Stringable
    let expected: Stringable
    let columnIndex: Int
    let lineIndex: Int
    let path: String
    
    init(assertionTuple: AssertionTuple, lineIndex: Int, path: String) {
        self.actual = assertionTuple.actual
        self.expected = assertionTuple.expected
        self.columnIndex = assertionTuple.columnIndex
        
        self.lineIndex = lineIndex
        self.path = path
    }
    
    func assert(line: UInt = #line) {
        XCTAssertEqual(actual.toString, expected.toString, failureMessage, line: line)
    }
    
    var failureMessage: String {
        "\n\(rootDirectory)/\(path).\(testFileExtension): comparison failure at line \(lineIndex + 2) column \(columnIndex + 1)"
    }
}

extension String {
    
    var givenThenSentences: [[String]] {
        split(separator: "\n").dropFirst().toStrings.map(\.components)
    }

    var components: [String] {
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
