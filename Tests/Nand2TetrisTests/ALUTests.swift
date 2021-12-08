@testable import Nand2Tetris
import XCTest

final class ALUTests: XCTestCase {
    
    func testALU() {
        assertALUAcceptanceTests()
    }
}

extension ALUTests {
    
    func assertALUAcceptanceTests() {
        loadTest("ALU", directory: "ALU").forEach {
            let x = $0.cells[0].x16, y = $0.cells[1].x16
            let zx = $0.cells[2].int, nx = $0.cells[3].int
            let zy = $0.cells[4].int, ny = $0.cells[5].int

            let f = $0.cells[6].int
            let no = $0.cells[7].int

            let out = $0.cells[8].x16
            let zr = $0.cells[9].int
            let ng = $0.cells[10].int

            let result = ALU(x: x, y: y, zx: zx, nx: nx, zy: zy, ny: ny, f: f, no: no)

            XCTAssertEqual(makeReadable(result.out), makeReadable(out),
                           "\n\($0.filePath): out comparison failure at line \($0.line)")
            XCTAssertEqual(result.zr, zr,
                           "\n\($0.filePath): zr comparison failure at line \($0.line)")
            XCTAssertEqual(result.ng, ng,
                           "\n\($0.filePath): ng comparison failure at line \($0.line)")
        }
    }
    
    func makeReadable(_ out: IntX16) -> String {
        out.map(String.init).joined()
    }
}

private func =><T: Equatable>(_ actual: T, _ expected: T) {
    XCTAssertEqual(actual, expected)
}
