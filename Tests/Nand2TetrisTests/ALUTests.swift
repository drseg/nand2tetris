@testable import Nand2Tetris
import XCTest

final class ALUTests: XCTestCase {
    
    func testALU() {
        runAcceptanceTest(named: "ALU", inside: "ALU") {
            let x = $0[0].x16, y = $0[1].x16
            let zx = $0[2].int, nx = $0[3].int
            let zy = $0[4].int, ny = $0[5].int
            
            let f = $0[6].int
            let no = $0[7].int
            
            let expectedOut = $0[8]
            let expectedZR = $0[9]
            let expectedNG = $0[10]
            
            let result = ALU(x: x, y: y, zx: zx, nx: nx, zy: zy, ny: ny, f: f, no: no)
            
            return [(result.out, expectedOut, 8),
                    (result.zr, expectedZR, 9),
                    (result.ng, expectedNG, 10)]
        }
    }
}
