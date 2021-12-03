var gatesUsed = 0

// nand considered primitive, implemented using Swift builtins
func nand(_ a: Int, _ b: Int) -> Int {
    gatesUsed += 1
    return (!(a.asBool && b.asBool)).asInt
}

func not(_ a: Int) -> Int {
    nand(a, a)
}

func and(_ a: Int, _ b: Int) -> Int {
    not(nand(a, b))
}

func or(_ a: Int, _ b: Int) -> Int {
    nand(not(a), not(b))
}

func xor(_ a: Int, _ b: Int) -> Int {
    and(or(a, b), nand(a, b))
}

func efficientXor(_ a: Int, _ b: Int) -> Int {
    let nandAB = nand(a, b)
    return nand(nand(a, nandAB), nand(b, nandAB))
}

func mux(_ a: Int, _ b: Int, _ s: Int) -> Int {
    or(and(a, not(s)), and(b, s))
}

func efficientMux(_ a: Int, _ b: Int, _ s: Int) -> Int {
    let notBS = nand(b, s)
    let notS = nand(s, s)
    let notANotS = nand(a, notS)
    
    return nand(notANotS, notBS)
}

func demux(_ a: Int, _ s: Int) -> (Int, Int) {
    (and(a, not(s)), and(a, s))
}

func not16(_ a: [Int]) -> [Int] {
    a.map(not)
}

func and16(_ a: [Int], _ b: [Int]) -> [Int] {
    zip(a, b).map(and)
}

func or16(_ a: [Int], _ b: [Int]) -> [Int] {
    zip(a, b).map(or)
}

func mux16(_ a: [Int], _ b: [Int], _ s: Int) -> [Int] {
    zip(a, b).map { mux($0, $1, s) }
}

func or8Way(_ a: [Int]) -> Int {
    or(a[0],
       or(a[1],
          (or(a[2],
              (or(a[3],
                  (or(a[4],
                      (or(a[5],
                          or(a[6],
                             a[7]))
                     )
                  ))
              ))
          ))
    ))
}

func orNWay(_ a: [Int]) -> Int {
    a.reduce(0, or)
}

func mux4Way16(_ a: [Int], _ b: [Int], _ c: [Int], _ d: [Int], _ s1: Int, _ s2: Int) -> [Int] {
    mux16(mux16(a, b, s2), mux16(c, d, s2), s1)
}

func mux8Way16(_ a: [Int], _ b: [Int], _ c: [Int], _ d: [Int], _ e: [Int], _ f: [Int], _ g: [Int], _ h: [Int], _ s1: Int, _ s2: Int, _ s3: Int) -> [Int] {
    mux16(mux4Way16(a, b, c, d, s2, s3),
          mux4Way16(e, f, g, h, s2, s3),
          s1)
}

extension Int {
    var asBool: Bool {
        self != 0
    }
}

extension Bool {
    var asInt: Int {
        self ? 1 : 0
    }
}

extension Int {
    var d: Double {
        Double(self)
    }
}
