@testable import Nand2Tetris
import XCTest

final class ALUTests: XCTestCase {
    
    func testALU() {
        AcceptanceTestRunner("ALU/ALU", firstExpectedColumn: 8) {
            let x = $0[0].x16, y = $0[1].x16
            let zx = $0[2].int, nx = $0[3].int
            let zy = $0[4].int, ny = $0[5].int

            let f = $0[6].int
            let no = $0[7].int
            
            let actual = alu(x: x, y: y, zx: zx, nx: nx, zy: zy, ny: ny, f: f, no: no)
            
            return [actual.out, actual.zr, actual.ng]
        }.run()
    }
}
