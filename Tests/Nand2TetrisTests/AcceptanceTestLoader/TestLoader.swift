import XCTest
@testable import Nand2Tetris

typealias AssertionFactory = (_ givenThen: [String]) -> [AssertionTuple]
typealias AssertionTuple = (actual: Stringable, expected: Stringable, columnIndex: Int)

private let root = "AcceptanceTests"
private let fileExtension = "cmp"

class AcceptanceTestRunner {
    
    private let relativePath: String
    private let factory: AssertionFactory
    
    init(relativePath: String, factory: @escaping AssertionFactory) {
        self.relativePath = relativePath
        self.factory = factory
    }
    
    init(name: String, directory: String, factory: @escaping AssertionFactory) {
        self.relativePath = "\(directory)/\(name)"
        self.factory = factory
    }

    func run() {
        tests.forEach { $0.run() }
    }
    
    private var tests: [Test] {
        testFile
            .givenThenSentences
            .enumerated()
            .map { lineIndex, givenThens in
                Test(relativePath: relativePath,
                     assertions: factory(givenThens),
                     lineIndex: lineIndex)
            }
    }

    private var testFile: String {
        guard
            let url = url,
            let tests = try? String(contentsOf: url)
        else { return "" }
        
        return tests.whiteSpaceTrimmed
    }

    private var url: URL? {
        Bundle.module.url(forResource: relativePath,
                          withExtension: fileExtension,
                          subdirectory: root + "/")
    }
}

private struct Test {
    
    private let assertions: [Assertion]
    
    init(relativePath: String, assertions: [AssertionTuple], lineIndex: Int) {
        self.assertions = assertions.map {
            Assertion(assertionTuple: $0,
                      lineIndex: lineIndex,
                      path: relativePath)
        }
    }
    
    func run() {
        assertions.forEach { $0.assert() }
    }
}

private struct Assertion {
    
    private let actual: Stringable
    private let expected: Stringable
    
    private let columnIndex: Int
    private let lineIndex: Int
    private let path: String
    
    private var failureMessage: String {
        "\n\(root)/\(path).\(fileExtension): comparison failure at " +
        "line \(lineIndex+2) " +
        "column \(columnIndex+1)"
    }
    
    init(assertionTuple: AssertionTuple, lineIndex: Int, path: String) {
        self.actual = assertionTuple.actual
        self.expected = assertionTuple.expected
        self.columnIndex = assertionTuple.columnIndex
        
        self.lineIndex = lineIndex
        self.path = path
    }
    
    func assert() {
        XCTAssertEqual(actual.toString, expected.toString, failureMessage)
    }
}

private extension String {
    
    var givenThenSentences: [[String]] {
        split(separator: "\r\n")
            .dropFirst()
            .toStrings
            .map(\.components)
    }
    
    var components: [String] {
        split(separator: "|").toStrings
    }
    
    var whiteSpaceTrimmed: String {
        replacingOccurrences(of: " ", with: "")
    }
}

private extension Sequence where Element: StringProtocol {
    
    var toStrings: [String] {
        map {
            $0.components(separatedBy: "").joined()
        }
    }
}
