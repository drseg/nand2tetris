import XCTest
@testable import Nand2Tetris

class TestLoaderTests: XCTestCase {
    func load(_ resource: String = "And", directory dir: String = "Gates", cellParser: ((_ column: Int, _ element: Substring) -> String)? = nil) -> [(cells: [String], line: Int, filePath: String)] {
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

func loadTest(_ name: String, directory dir: String) -> [(cells: [String], line: Int, filePath: String)] {
    loadTest(name, directory: dir) { _, element in String(element) }
}

func loadTest<T>(_ name: String, directory dir: String, cellParser: ((_ column: Int,_ element: Substring) -> T)) -> [(cells: [T], line: Int, filePath: String)] {
    loadTest(name, directory: dir).rows.map { row, element in
        let cells = element.split(separator: "|").enumerated().map(cellParser)
        let filePath = "AcceptanceTests/\(dir)/\(name).cmp"
        return (cells, row + 2, filePath)
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


