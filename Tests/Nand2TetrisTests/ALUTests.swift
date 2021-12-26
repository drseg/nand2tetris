@testable import Nand2Tetris
import XCTest
import Nand2TetrisTestLoader

final class ALUTests: XCTestCase {
    func testALU() throws {
        try FileBasedATR("ALU/ALU", firstOutputColumn: 8) {
            let x = $0[0]
            let y = $0[1]
            let zx = $0[2].toChar
            let nx = $0[3].toChar
            let zy = $0[4].toChar
            let ny = $0[5].toChar

            let f = $0[6].toChar
            let no = $0[7].toChar
            
            let actual = alu(x: x,
                             y: y,
                             zx: zx,
                             nx: nx,
                             zy: zy,
                             ny: ny,
                             f: f,
                             no: no)
            
            return [actual.out, actual.zr, actual.ng]
        }.run()
    }
}
