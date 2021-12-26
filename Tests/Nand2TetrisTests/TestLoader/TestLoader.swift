import XCTest

public protocol Stringable {
    var toString: String { get }
}

extension String: Stringable {
    public var toString: String { self }
}

extension Character: Stringable {
    public var toString: String { String(self) }
}

public typealias ActualsFactory = (_ givens: [String]) -> [Stringable]

private let testRoot = "AcceptanceTests"
private let testFileExtension = "cmp"

struct ATRError: Error {
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
}

public protocol ATR {
    func run(swiftFile: StaticString, swiftLine: UInt) throws
}

protocol ATRImplementation: ATR {
    var testString: String { get throws }
    var testName: String { get throws }
    
    var actualsFactory: ActualsFactory { get }
    var firstOutputColumn: Int? { get }
}

extension ATRImplementation {
    public func run(
        swiftFile: StaticString = #file,
        swiftLine: UInt = #line
    ) throws {
        try getTests().forEach {
            $0.run(in: swiftFile, at: swiftLine)
        }
    }
    
    func getTests() throws -> [Test] {
        try makeTests(from: givenThenSentences(in: testString))
    }
    
    func makeTests(
        from givenThenSentences: [[String]]
    ) throws -> [Test] {
        try givenThenSentences.enumerated().compactMap { line, row in
            let firstOutputColumn: Int = try {
                let column = self.firstOutputColumn ?? row.count - 1
                try checkIsValid(column, row.count)
                return column
            }()
            
            let givens = row.prefix(upTo: firstOutputColumn)
            let actuals = try getActuals(from: givens)
            let expecteds = try getExpecteds(in: row,
                                             startingAt: firstOutputColumn,
                                             count: actuals.count)
            
            return Test(actuals: actuals,
                        expecteds: expecteds,
                        firstOutputColumn: firstOutputColumn,
                        filePath: try testName,
                        fileLine: line)
        }
    }
    
    func givenThenSentences(in s: String) throws -> [[String]] {
        let sentences = s.split(separator: "\r\n")
            .dropFirst()
            .toStrings
            .map(\.components)
        
        try checkIsNotEmpty(s)
        
        return sentences
    }
    
    func getActuals(
        from givens: Array<String>.SubSequence
    ) throws -> [String] {
        let actuals = actualsFactory(Array(givens)).map(\.toString)
        try checkIsNonZero(actuals.count)
        return actuals
    }
    
    func getExpecteds(
        in row: [String],
        startingAt firstExpectedColumn: Int,
        count: Int
    ) throws -> Array<String>.SubSequence {
        let expecteds = row.suffix(from: firstExpectedColumn)
        try checkCountsMatch(count, expecteds.count)
        return expecteds
    }
    
    func checkIsValid(_ expected: Int, _ given: Int) throws {
        guard expected < given else {
            throw ATRError("Expected column index is out of bounds")
        }
    }
    
    func checkIsNonZero(_ c: Int) throws {
        guard c != 0 else {
            throw ATRError("No actual values found")
        }
    }
    
    func checkCountsMatch(_ lhs: Int, _ rhs: Int) throws {
        guard lhs == rhs else {
            throw ATRError(
                "Actual (\(lhs)) and Expected (\(rhs)) counts differ"
            )
        }
    }
    
    func checkIsNotEmpty(_ s: String) throws {
        guard !s.isEmpty else {
            throw ATRError("Parsing error")
        }
    }
}

public struct FileBasedATR: ATRImplementation {
    let actualsFactory: ActualsFactory
    let firstOutputColumn: Int?
    
    private let relativePath: String
    var testName: String { relativePath }
    
    public init(
        name: String,
        directory: String,
        firstOutputColumn: Int? = nil,
        factory: @escaping ActualsFactory
    ) {
        self.init("\(directory)/\(name)",
                  firstOutputColumn: firstOutputColumn,
                  factory: factory)
    }
    
    public init(
        _ relativePath: String,
        firstOutputColumn: Int? = nil,
        factory: @escaping ActualsFactory
    ) {
        self.relativePath = relativePath
        self.firstOutputColumn = firstOutputColumn
        self.actualsFactory = factory
    }
    
    var testString: String {
        get throws {
            guard let url = Bundle
                    .module
                    .url(forResource: relativePath,
                         withExtension: testFileExtension,
                         subdirectory: testRoot + "/")
            else { throw fileNotFound() }
            
            return try String(contentsOf: url).whitespaceTrimmed
        }
    }
    
    func fileNotFound() -> ATRError {
        ATRError("File not found")
    }
}

struct Test {
    private let assertions: [Assertion]
    
    init<T: Collection, U: Collection>(
        actuals: T,
        expecteds: U,
        firstOutputColumn: Int,
        filePath: String,
        fileLine: Int
    ) where T.Element == String, U.Element == String {
        self.assertions = zip(actuals, expecteds).enumerated().map {
            Assertion(actual: $0.element.0,
                      expected: $0.element.1,
                      column: firstOutputColumn + $0.offset,
                      line: fileLine,
                      path: filePath)
        }
    }
    
    func run(in swiftFile: StaticString, at swiftLine: UInt) {
        assertions.forEach { $0.assert(in: swiftFile, at: swiftLine) }
    }
}

struct Assertion {
    private let actual: Stringable
    private let expected: Stringable
    
    private let column: Int
    private let fileLine: Int
    private let filePath: String
    
    init(
        actual: Stringable,
        expected: Stringable,
        column: Int,
        line: Int,
        path: String
    ) {
        self.actual = actual
        self.expected = expected
        self.column = column
        
        self.fileLine = line
        self.filePath = path
    }
    
    func assert(in swiftFile: StaticString, at swiftLine: UInt) {
        let failureMessage = {
            "\n\(testRoot)/\(filePath).\(testFileExtension)" +
            ": comparison failure at " +
            "line \(fileLine+2) " +
            "column \(column+1)"
        }()
        
        XCTAssertEqual(actual.toString, expected.toString,
                       failureMessage,
                       file: swiftFile,
                       line: swiftLine)
    }
}

private extension String {
    var components: [String] {
        split(separator: "|").toStrings
    }
    
    var whitespaceTrimmed: String {
        replacingOccurrences(of: " ", with: "")
    }
}

private extension Sequence where Element: StringProtocol {
    var toStrings: [String] {
        map { String($0) }
    }
}
