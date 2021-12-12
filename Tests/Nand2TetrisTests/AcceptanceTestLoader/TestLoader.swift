import XCTest
@testable import Nand2Tetris

typealias ActualsFactory = (_ givens: [String]) -> [Stringable]

private let testRoot = "AcceptanceTests"
private let testFileExtension = "cmp"

class ATR {
    
    struct ATRError: Error {
        let message: String
    }
    
    fileprivate var testString: String {
        get throws { throw subclassesMustImplement() }
    }
    
    fileprivate var testName: String {
        get throws { throw subclassesMustImplement() }
    }
            
    private let getActuals: ActualsFactory
    private let firstExpectedColumn: Int?
    
    init(firstExpectedColumn: Int? = nil, factory: @escaping ActualsFactory) {
        self.firstExpectedColumn = firstExpectedColumn
        self.getActuals = factory
    }
    
    func run(swiftFile: StaticString = #file, swiftLine: UInt = #line) throws {
        try getTests().forEach { $0.run(in: swiftFile, at: swiftLine) }
    }
    
    private func getTests() throws -> [Test] {
        try makeTests(from: givenThenSentences(in: testString))
    }
    
    private func makeTests(from givenThenSentences: [[String]]) throws -> [Test] {
        try givenThenSentences.enumerated().compactMap { line, givenThenRow in
            let firstExpectedColumn = try calculateFirstExpectedColumn(givenThenRow.count)
            
            let givens = givenThenRow.prefix(upTo: firstExpectedColumn)
            let actuals = try getActuals(from: givens)
            let expecteds = try getExpecteds(in: givenThenRow,
                                             from: firstExpectedColumn,
                                             count: actuals.count)
            
            return Test(actuals: actuals,
                        expecteds: expecteds,
                        firstExpectedColumn: firstExpectedColumn,
                        filePath: try testName,
                        fileLine: line)
        }
    }
    
    private func givenThenSentences(in s: String) throws -> [[String]] {
        let sentences = s.split(separator: "\r\n")
            .dropFirst()
            .toStrings
            .map(\.components)
        
        try checkIsNotEmpty(s)
        
        return sentences
    }
    
    fileprivate func calculateFirstExpectedColumn(_ columnCount: Int) throws -> Int {
        let column = firstExpectedColumn ?? columnCount - 1
        try checkIsValid(column, columnCount)
        return column
    }
    
    fileprivate func getActuals(from givens: Array<String>.SubSequence) throws -> [String] {
        let actuals = getActuals(Array(givens)).map(\.toString)
        try checkIsNonZero(actuals.count)
        return actuals
    }
    
    fileprivate func getExpecteds(in givenThenRow: [String], from firstExpectedColumn: Int, count: Int) throws -> Array<String>.SubSequence {
        let expecteds = givenThenRow.suffix(from: firstExpectedColumn)
        try checkCountsMatch(count, expecteds.count)
        return expecteds
    }
    
    private func subclassesMustImplement() -> ATRError {
        error("Subclasses must implement")
    }
    
    private func checkIsValid(_ expected: Int, _ given: Int) throws {
        guard expected < given else {
            throw error("Expected column index is out of bounds")
        }
    }
    
    private func checkIsNonZero(_ c: Int) throws {
        guard c != 0 else {
            throw error("No actual values found")
        }
    }
    
    private func checkCountsMatch(_ lhs: Int, _ rhs: Int) throws {
        guard lhs == rhs else {
            throw error("Actual (\(lhs)) and Expected (\(rhs)) counts differ")
        }
    }
    
    private func checkIsNotEmpty(_ s: String) throws {
        guard !s.isEmpty else {
            throw error("Parsing error")
        }
    }
    
    fileprivate func error(_ message: String) -> ATRError {
        ATRError(message: message)
    }
}

class FileBasedATR: ATR {
    
    private let relativePath: String
    
    convenience init(name: String, directory: String, firstExpectedColumn: Int? = nil, factory: @escaping ActualsFactory) {
        self.init("\(directory)/\(name)",
                  firstExpectedColumn: firstExpectedColumn,
                  factory: factory)
    }
    
    init(_ relativePath: String, firstExpectedColumn: Int? = nil, factory: @escaping ActualsFactory) {
        self.relativePath = relativePath
        super.init(firstExpectedColumn: firstExpectedColumn,
                   factory: factory)
    }
    
    override var testString: String {
        get throws {
            guard let url = Bundle.module.url(forResource: relativePath,
                                              withExtension: testFileExtension,
                                              subdirectory: testRoot + "/")
            else { throw fileNotFound() }
            
            return try String(contentsOf: url).whiteSpaceTrimmed
        }
    }
    
    override var testName: String {
        relativePath
    }
    
    private func fileNotFound() -> ATRError {
        error("File not found")
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
        assertions.forEach { $0.assert(in: swiftFile, at: swiftLine) }
    }
}

private struct Assertion {
    
    private let actual: Stringable
    private let expected: Stringable
    
    private let column: Int
    private let fileLine: Int
    private let filePath: String
    
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
    
    private var failureMessage: String {
        "\n\(testRoot)/\(filePath).\(testFileExtension): comparison failure at " +
        "line \(fileLine+2) " +
        "column \(column+1)"
    }
}

private extension String {
    
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
