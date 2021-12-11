import XCTest
@testable import Nand2Tetris

typealias ActualsFactory = (_ givens: [String]) -> [Stringable]

private let testRoot = "AcceptanceTests"
private let testFileExtension = "cmp"

class ATR {
    
    var shouldSuppressValidationFailures = false
        
    private let getActuals: ActualsFactory
    private let firstExpectedColumn: Int?
    
    private let swiftFile: StaticString
    private let swiftLine: UInt
    
    init(firstExpectedColumn: Int? = nil, swiftFile: StaticString = #file, swiftLine: UInt = #line, factory: @escaping ActualsFactory) {
        self.firstExpectedColumn = firstExpectedColumn
        self.swiftFile = swiftFile
        self.swiftLine = swiftLine
        self.getActuals = factory
    }
    
    func run() {
        getTests().forEach { $0.run(in: swiftFile,
                                    at: swiftLine) }
    }
    
    private func getTests() -> [Test] {
        let givenThenSentences = testString.givenThenSentences
        
        guard !givenThenSentences.isEmpty else {
            return parsingError()
        }
        
        return makeTests(from: givenThenSentences)
    }
    
    private func makeTests(from givenThenSentences: [[String]]) -> [Test] {
        givenThenSentences.enumerated().compactMap { line, givenThenRow in
            let firstExpectedColumn = firstExpectedColumn ?? givenThenRow.count - 1
            
            guard firstExpectedColumn < givenThenRow.count else {
                return columnOutOfBounds()
            }

            let givens = givenThenRow.prefix(upTo: firstExpectedColumn)
            let actuals = getActuals(Array(givens)).map(\.toString)
            let expecteds = givenThenRow[firstExpectedColumn...]
            
            guard actuals.count != 0 else {
                return noActualsFound()
            }
            
            guard actuals.count == expecteds.count else {
                return conflictingCount(actuals.count, expecteds.count)
            }
            
            return Test(actuals: actuals,
                        expecteds: expecteds,
                        firstExpectedColumn: firstExpectedColumn,
                        filePath: testName,
                        fileLine: line)
        }
    }
    
    var testString: String {
        fatalError("Subclasses must implement")
    }
    
    var testName: String {
        fatalError("Subclasses must implement")
    }
    
    private func columnOutOfBounds() -> Test? {
        fail("Expected column index is out of bounds", nil)
    }
    
    private func noActualsFound() -> Test? {
        fail("No actual values found", nil)
    }
    
    private func conflictingCount(_ actual: Int, _ expected: Int) -> Test? {
        fail("Actual (\(actual)) and Expected (\(expected)) counts differ", nil)
    }
    
    private func parsingError() -> [Test] {
        fail("Parsing error", [])
    }
    
    func fail<T>(_ message: String, _ output: T) -> T {
        if !shouldSuppressValidationFailures {
            XCTFail(message)
        }
        return output
    }
}

class FileBasedATR: ATR {
    
    private let relativePath: String
    
    convenience init(name: String, directory: String, firstExpectedColumn: Int? = nil, swiftFile: StaticString = #file, swiftLine: UInt = #line, factory: @escaping ActualsFactory) {
        self.init("\(directory)/\(name)",
                  firstExpectedColumn: firstExpectedColumn,
                  swiftFile: swiftFile,
                  swiftLine: swiftLine,
                  factory: factory)
    }
    
    init(_ relativePath: String, firstExpectedColumn: Int? = nil, swiftFile: StaticString = #file, swiftLine: UInt = #line, factory: @escaping ActualsFactory) {
        self.relativePath = relativePath
        super.init(firstExpectedColumn: firstExpectedColumn,
                   swiftFile: swiftFile,
                   swiftLine: swiftLine,
                   factory: factory)
    }
    
    override var testString: String {
        guard
            let url = Bundle.module.url(forResource: relativePath,
                                        withExtension: testFileExtension,
                                        subdirectory: testRoot + "/"),
            let tests = try? String(contentsOf: url)
        else { return fileNotFound() }
        
        return tests.whiteSpaceTrimmed
    }
    
    override var testName: String {
        relativePath
    }

    private func fileNotFound() -> String {
        fail("File not found", "")
    }
}

private struct Test {
    
    private let assertions: [Assertion]
    
    init<T: Collection, U: Collection>(actuals: T, expecteds: U, firstExpectedColumn: Int, filePath: String, fileLine: Int) where T.Element == String, U.Element == String {
        self.assertions = zip(actuals, expecteds).enumerated().map {
            Assertion(actual: $0.element.0,
                      expected: $0.element.1,
                      column: firstExpectedColumn + $0.offset,
                      line: fileLine,
                      path: filePath)
        }
    }
    
    func run(in swiftFile: StaticString, at swiftLine: UInt) {
        assertions.forEach { $0.assert(in: swiftFile,
                                       at: swiftLine) }
    }
}

private struct Assertion {
    
    private let actual: Stringable
    private let expected: Stringable
    
    private let column: Int
    private let fileLine: Int
    private let filePath: String
    
    private var failureMessage: String {
        "\n\(testRoot)/\(filePath).\(testFileExtension): comparison failure at " +
        "line \(fileLine+2) " +
        "column \(column+1)"
    }
    
    init(actual: Stringable, expected: Stringable, column: Int, line: Int, path: String) {
        self.actual = actual
        self.expected = expected
        self.column = column
        
        self.fileLine = line
        self.filePath = path
    }
    
    func assert(in swiftFile: StaticString, at swiftLine: UInt) {
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
