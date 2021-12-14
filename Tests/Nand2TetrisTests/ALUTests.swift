@testable import Nand2Tetris
import XCTest
import Nand2TetrisTestLoader

final class ALUTests: XCTestCase {
    
    func testALU() throws {
        try FileBasedATR("ALU/ALU", firstExpectedColumn: 8) {
            let x = $0[0], y = $0[1]
            let zx = $0[2].c, nx = $0[3].c
            let zy = $0[4].c, ny = $0[5].c

            let f = $0[6].c
            let no = $0[7].c
            
            let actual = alu(x: x, y: y, zx: zx, nx: nx, zy: zy, ny: ny, f: f, no: no)
            
            return [actual.out, actual.zr, actual.ng]
        }.run()
    }
}
