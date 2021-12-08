import XCTest
@testable import Nand2Tetris

class TestLoaderTests: XCTestCase {
    func loadTestRows(_ resource: String = "And", directory dir: String = "Gates", cellParser: ((_ offset: Int,_ element: Substring) -> String) = { _, element in String(element) }) -> [[String]] {
        Nand2TetrisTests.loadTestRows(resource, directory: dir, cellParser: cellParser)
    }
    
    func testDoesNotLoadNothing() {
        XCTAssertEqual(loadTestRows("cat", directory: "Gates"), [[]])
    }
    
    func testParsesRowsIgnoringHeader() {
        let tableRows = loadTestRows()

        XCTAssertEqual(tableRows.count, 4)
        XCTAssertEqual(tableRows[0], ["0","0","0"])
        XCTAssertEqual(tableRows[1], ["0","1","0"])
        XCTAssertEqual(tableRows[2], ["1","0","0"])
        XCTAssertEqual(tableRows[3], ["1","1","1"])
    }
    
    func testCellParserReceivesColumnIndex() {
        let tableRows = loadTestRows { offset, _ in
            "Column \(offset)"
        }
        
        XCTAssertEqual(tableRows[0].count, 3)
        XCTAssertEqual(tableRows[0][0], "Column 0")
        XCTAssertEqual(tableRows[0][1], "Column 1")
        XCTAssertEqual(tableRows[0][2], "Column 2")
    }
}

func loadTestRows<T>(_ resource: String, directory dir: String, cellParser: ((_ offset: Int,_ element: Substring) -> T)) -> [[T]] {
    loadTest(resource, directory: dir)?
        .split(separator: "\n")
        .dropFirst()
        .map {
            $0.split(separator: "|")
                .enumerated()
                .map(cellParser)
        } ?? [[]]
}

private func loadTest(_ resource: String, directory dir: String) -> String? {
    guard let url = Bundle.module.url(forResource: resource, withExtension: "cmp", subdirectory: "AcceptanceTests/\(dir)") else { return nil }
    return try? String(contentsOf: url).trimmed
}

extension String {
    var trimmed: String {
        replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\r", with: "")
    }
}


