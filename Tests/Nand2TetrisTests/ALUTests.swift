@testable import Nand2Tetris
import XCTest

final class ALUTests: XCTestCase {
    
    func testALU() {
        assertALU(
/*
Out = 0, both x and y are zeroed at input:
*/
"""
|        x       |        y       |zx|nx|zy|ny|f|no|       out      |zr|ng|
|0000000000000000|1111111111111111|1 |0 |1 |0 |1|0 |0000000000000000|1 |0 |
|0000000000010001|0000000000000011|1 |0 |1 |0 |1|0 |0000000000000000|1 |0 |
"""
        )
    }

}

extension ALUTests {
    
    func assertALU(_ table: String) {
        table
            .split(separator: "\n")
            .dropFirst()
            .map(String.init)
            .forEach(assert)
    }
    
    func assert(_ tableRow: String) {
        let parts = tableRow.split(separator: "|").map { $0.trimmingCharacters(in: .whitespaces)}
        
        let x = parts[0].x16, y = parts[1].x16
        let zx = parts[2].int, nx = parts[3].int, zy = parts[4].int, ny = parts[5].int
        let f = parts[6].int
        let no = parts[7].int

        let out = parts[8].x16
        let zr = parts[9].int
        let ng = parts[10].int
        
        let aluResult = ALU(x: x, y: y, zx: zx, nx: nx, zy: zy, ny: ny, f: f, no: no)
        
        XCTAssertEqual(makeReadable(aluResult.out),
                       makeReadable(out),
                       "out comparison failure")
        XCTAssertEqual(aluResult.zr,
                       zr,
                       "zr comparison failure")
        XCTAssertEqual(aluResult.ng,
                       ng,
                       "ng comparison failure")
    }
    
    func makeReadable(_ out: IntX16) -> String {
        out.map(String.init).joined()
    }
}

private func =><T: Equatable>(_ actual: T, _ expected: T) {
    XCTAssertEqual(actual, expected)
}

/*
 
 ALU function list:
 
 x, y are inputs
 zx, nx, zy, ny, f, no are selectors
 
 zx, nx, zy, ny select before f
 no selects after f
 f selects between x+y (f=1) and x&y (f=0)
 
 Outs:
 out
 zr if out == zero
 ng if out <= zero
 
 |        x       |        y       |zx|nx|zy|ny|f|no|       out      |zr|ng|
 
 Out = 0, both x and y are zeroed at input:
 |0000000000010001|0000000000000011|1 |0 |1 |0 |1|0 |0000000000000000|1 |0 |
 |0000000000010001|0000000000000011|1 |0 |1 |0 |1|0 |0000000000000000|1 |0 |
 
 Out = 1, both x and y are both zeroed then negated (then added), out negated
 |0000000000000000|1111111111111111|1 |1 |1 |1 |1|1 |0000000000000001|0 |0 |
 |0000000000010001|0000000000000011|1 |1 |1 |1 |1|1 |0000000000000001|0 |0 |
 
 Out = -1: x is zeroed then negated, y is zeroed, x + y
 | 0000000000000000 | 1111111111111111 | 1 | 1 | 1 | 0 | 1 | 0 | 1111111111111111 | 0 | 1 |
 | 0000000000010001 | 0000000000000011 | 1 | 1 | 1 | 0 | 1 | 0 | 1111111111111111 | 0 | 1 |
 
 Out = x, y is zeroed then negated, x & y
 | 0000000000000000 | 1111111111111111 | 0 | 0 | 1 | 1 | 0 | 0 | 0000000000000000 | 1 | 0 |
 | 0000000000010001 | 0000000000000011 | 0 | 0 | 1 | 1 | 0 | 0 | 0000000000010001 | 0 | 0 |
 
 Out = y, z is zeroed then negated, x & y
 | 0000000000000000 | 1111111111111111 | 1 | 1 | 0 | 0 | 0 | 0 | 1111111111111111 | 0 | 1 |
 | 0000000000010001 | 0000000000000011 | 1 | 1 | 0 | 0 | 0 | 0 | 0000000000000011 | 0 | 0 |

 Out = not(x), y is zeroed then negated, x & y, output negated
 | 0000000000000000 | 1111111111111111 | 0 | 0 | 1 | 1 | 0 | 1 | 1111111111111111 | 0 | 1 |
 | 0000000000010001 | 0000000000000011 | 0 | 0 | 1 | 1 | 0 | 1 | 1111111111101110 | 0 | 1 |

 Out = not(y), x is zeroed then negated, x & y, output negated
 | 0000000000000000 | 1111111111111111 | 1 | 1 | 0 | 0 | 0 | 1 | 0000000000000000 | 1 | 0 |
 | 0000000000010001 | 0000000000000011 | 1 | 1 | 0 | 0 | 0 | 1 | 1111111111111100 | 0 | 1 |

 Out = -x, y is zeroed then negated, x + y, output negated
 | 0000000000000000 | 1111111111111111 | 0 | 0 | 1 | 1 | 1 | 1 | 0000000000000000 | 1 | 0 |
 | 0000000000010001 | 0000000000000011 | 0 | 0 | 1 | 1 | 1 | 1 | 1111111111101111 | 0 | 1 |

 Out = -y, x is zeroed then negated, x + y, output negated
 | 0000000000000000 | 1111111111111111 | 1 | 1 | 0 | 0 | 1 | 1 | 0000000000000001 | 0 | 0 |
 | 0000000000010001 | 0000000000000011 | 1 | 1 | 0 | 0 | 1 | 1 | 1111111111111101 | 0 | 1 |

 Out = x + 1, x is negated, y is zeroed then negated, x + y ,output negated
 | 0000000000000000 | 1111111111111111 | 0 | 1 | 1 | 1 | 1 | 1 | 0000000000000001 | 0 | 0 |
 | 0000000000010001 | 0000000000000011 | 0 | 1 | 1 | 1 | 1 | 1 | 0000000000010010 | 0 | 0 |

 Out = y + 1, x is zeroed then negated, y is negated, x + y, output negated
 | 0000000000000000 | 1111111111111111 | 1 | 1 | 0 | 1 | 1 | 1 | 0000000000000000 | 1 | 0 |
 | 0000000000010001 | 0000000000000011 | 1 | 1 | 0 | 1 | 1 | 1 | 0000000000000100 | 0 | 0 |

 Out = x - 1, y is zeroed then negated, x + y
 | 0000000000000000 | 1111111111111111 | 0 | 0 | 1 | 1 | 1 | 0 | 1111111111111111 | 0 | 1 |
 | 0000000000010001 | 0000000000000011 | 0 | 0 | 1 | 1 | 1 | 0 | 0000000000010000 | 0 | 0 |

 Out = y - 1, x is zeroed then negated, x + y
 | 0000000000000000 | 1111111111111111 | 1 | 1 | 0 | 0 | 1 | 0 | 1111111111111110 | 0 | 1 |
 | 0000000000010001 | 0000000000000011 | 1 | 1 | 0 | 0 | 1 | 0 | 0000000000000010 | 0 | 0 |

 Out = x + y
 | 0000000000000000 | 1111111111111111 | 0 | 0 | 0 | 0 | 1 | 0 | 1111111111111111 | 0 | 1 |
 | 0000000000010001 | 0000000000000011 | 0 | 0 | 0 | 0 | 1 | 0 | 0000000000010100 | 0 | 0 |

 Out = x - y, neg(x) + y, output inverted
 | 0000000000000000 | 1111111111111111 | 0 | 1 | 0 | 0 | 1 | 1 | 0000000000000001 | 0 | 0 |
 | 0000000000010001 | 0000000000000011 | 0 | 1 | 0 | 0 | 1 | 1 | 0000000000001110 | 0 | 0 |

 Out = y - x, neg(y) + x, output inverted
 | 0000000000000000 | 1111111111111111 | 0 | 0 | 0 | 1 | 1 | 1 | 1111111111111111 | 0 | 1 |
 | 0000000000010001 | 0000000000000011 | 0 | 0 | 0 | 1 | 1 | 1 | 1111111111110010 | 0 | 1 |

 Out = x & y
 | 0000000000000000 | 1111111111111111 | 0 | 0 | 0 | 0 | 0 | 0 | 0000000000000000 | 1 | 0 |
 | 0000000000010001 | 0000000000000011 | 0 | 0 | 0 | 0 | 0 | 0 | 0000000000000001 | 0 | 0 |

 Out = x | y
 | 0000000000000000 | 1111111111111111 | 0 | 1 | 0 | 1 | 0 | 1 | 1111111111111111 | 0 | 1 |
 | 0000000000010001 | 0000000000000011 | 0 | 1 | 0 | 1 | 0 | 1 | 0000000000010011 | 0 | 0 |

 */
