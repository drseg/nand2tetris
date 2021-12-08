import XCTest
@testable import Nand2Tetris

typealias AcceptanceTest<T> = [(cells: [T], line: Int, filePath: String)]
typealias CellParser<T> = (_ column: Int, _ element: Substring) -> T

class TestLoaderTests: XCTestCase {
    
    func load(_ resource: String = "And", directory dir: String = "Gates", cellParser: CellParser<String>? = nil) -> AcceptanceTest<String> {
        cellParser == nil
        ? loadTest(resource, directory: dir)
        : loadTest(resource, directory: dir, cellParser: cellParser!)
    }
    
    func testDoesNotLoadNothing() {
        XCTAssertTrue(load("cat").isEmpty)
    }
    
    func testParsesRowsIgnoringHeader() {
        let rows = load()

        XCTAssertEqual(rows.count, 4)
        XCTAssertEqual(rows[0].cells, ["0","0","0"])
        XCTAssertEqual(rows[1].cells, ["0","1","0"])
        XCTAssertEqual(rows[2].cells, ["1","0","0"])
        XCTAssertEqual(rows[3].cells, ["1","1","1"])
    }
    
    func testCellParserReceivesColumnIndex() {
        let rows = load { column, _ in "Column \(column)" }
        
        XCTAssertEqual(rows[0].cells.count, 3)
        XCTAssertEqual(rows[0].cells[0], "Column 0")
        XCTAssertEqual(rows[0].cells[1], "Column 1")
        XCTAssertEqual(rows[0].cells[2], "Column 2")
    }
    
    func testLoaderOutputsCorrectLine() {
        let rows = load()
        
        XCTAssertEqual(rows[0].line, 2)
        XCTAssertEqual(rows[1].line, 3)
        XCTAssertEqual(rows[2].line, 4)
    }
    
    func testLoaderOutputsFilepath() {
        XCTAssertEqual(load()[0].filePath, "AcceptanceTests/Gates/And.cmp")
    }
}

func loadTest(_ name: String, directory dir: String) -> AcceptanceTest<String> {
    loadTest(name, directory: dir) { _, element in String(element) }
}

func loadTest<T>(_ name: String, directory dir: String, cellParser: CellParser<T>) -> AcceptanceTest<T> {
    loadTest(name, directory: dir).rows.map { row, element in
        (cells: element.split(separator: "|").enumerated().map(cellParser),
         line: row + 2,
         filePath: "AcceptanceTests/\(dir)/\(name).cmp")
    }
}

private func loadTest(_ name: String, directory dir: String) -> String {
    guard let url = url(testName: name, directory: dir) else { return "" }
    return (try? String(contentsOf: url).trimmed) ?? ""
}

private func url(testName: String, directory dir: String) -> URL? {
    Bundle.module.url(forResource: testName, withExtension: "cmp", subdirectory: "AcceptanceTests/\(dir)")
}

extension String {
    var rows: EnumeratedSequence<ArraySlice<Substring>> {
        split(separator: "\n")
        .dropFirst()
        .enumerated()
    }
    
    var trimmed: String {
        replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\r", with: "")
    }
}


