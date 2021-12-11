import XCTest
@testable import Nand2Tetris

typealias ActualsFactory = (_ givenThen: [String]) -> [Stringable]

private let testRoot = "AcceptanceTests"
private let testFileExtension = "cmp"

class AcceptanceTestRunner {
    
    private let relativePath: String
    private let getActuals: ActualsFactory
    private let firstExpectedColumn: Int?
    
    private let swiftFile: StaticString
    private let swiftLine: UInt
    
    convenience init(name: String, directory: String, firstExpectedColumn: Int? = nil, swiftFile: StaticString = #file, swiftLine: UInt = #line, factory: @escaping ActualsFactory) {
        self.init("\(directory)/\(name)",
                  firstExpectedColumn: firstExpectedColumn,
                  swiftFile: swiftFile,
                  swiftLine: swiftLine,
                  factory: factory)
    }
    
    init(_ relativePath: String, firstExpectedColumn: Int? = nil, swiftFile: StaticString = #file, swiftLine: UInt = #line, factory: @escaping ActualsFactory) {
        self.relativePath = relativePath
        self.firstExpectedColumn = firstExpectedColumn
        self.swiftFile = swiftFile
        self.swiftLine = swiftLine
        self.getActuals = factory
    }

    func run() {
        tests.forEach { $0.run() }
    }
    
    private var tests: [Test] {
        let givenThenSentences = testFile.givenThenSentences
        
        guard !givenThenSentences.isEmpty else {
            XCTFail("Parsing error"); return []
        }
        
        return makeTests(from: givenThenSentences)
    }
    
    private func makeTests(from givenThenSentences: [[String]]) -> [Test] {
        givenThenSentences.enumerated().compactMap { line, givenThens in
            let firstExpectedColumn = firstExpectedColumn ?? givenThens.count - 1
            
            guard firstExpectedColumn < givenThens.count else {
                XCTFail("Expected column index is out of bounds")
                return nil
            }

            let givens = Array(givenThens.prefix(upTo: firstExpectedColumn))
            let actuals = getActuals(givens).map(\.toString)
            let expecteds = Array(givenThens[firstExpectedColumn...])
            
            guard actuals.count != 0 else {
                XCTFail("No actual values found")
                return nil
            }
            
            guard actuals.count == expecteds.count else {
                XCTFail("Actual (\(actuals.count)) and Expected (\(expecteds.count)) counts differ")
                return nil
            }
            
            return Test(relativePath: relativePath,
                        actuals: actuals,
                        expecteds: expecteds,
                        line: line,
                        firstExpectedColumn: firstExpectedColumn,
                        swiftFile: swiftFile,
                        swiftLine: swiftLine)
        }
    }
    
    private var testFile: String {
        guard
            let url = url,
            let tests = try? String(contentsOf: url)
        else { XCTFail("File not found"); return "" }
        
        return tests.whiteSpaceTrimmed
    }

    private var url: URL? {
        Bundle.module.url(forResource: relativePath,
                          withExtension: testFileExtension,
                          subdirectory: testRoot + "/")
    }
}

private struct Test {
    
    private let assertions: [Assertion]
    
    private let swiftFile: StaticString
    private let swiftLine: UInt
    
    init(relativePath: String, actuals: [String], expecteds: [String] = [], line: Int, firstExpectedColumn: Int, swiftFile: StaticString = #file, swiftLine: UInt = #line) {
        self.swiftFile = swiftFile
        self.swiftLine = swiftLine
        
        self.assertions = zip(actuals, expecteds).enumerated().map {
            Assertion(actual: $0.element.0,
                      expected: $0.element.1,
                      column: firstExpectedColumn + $0.offset,
                      line: line,
                      path: relativePath)
        }
    }
    
    func run() {
        assertions.forEach { $0.assert(swiftFile: swiftFile,
                                       swiftLine: swiftLine) }
    }
}

private struct Assertion {
    
    private let actual: Stringable
    private let expected: Stringable
    
    private let column: Int
    private let line: Int
    private let path: String
    
    private var failureMessage: String {
        "\n\(testRoot)/\(path).\(testFileExtension): comparison failure at " +
        "line \(line+2) " +
        "column \(column+1)"
    }
    
    init(actual: Stringable, expected: Stringable, column: Int, line: Int, path: String) {
        self.actual = actual
        self.expected = expected
        self.column = column
        
        self.line = line
        self.path = path
    }
    
    func assert(swiftFile: StaticString = #file, swiftLine: UInt = #line) {
        XCTAssertEqual(actual.toString, expected.toString, failureMessage, file: swiftFile, line: swiftLine)
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
