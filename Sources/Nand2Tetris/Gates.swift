var gatesUsed = 0

// nand considered primitive, implemented using Swift builtins
func nand(_ a: Int, _ b: Int) -> Int {
    assert(a == 1 || a == 0)
    assert(b == 1 || b == 0)
    
    gatesUsed.increment()
    return (!(a.bool && b.bool)).int
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

func deMux(_ a: Int, _ s: Int) -> IntX2 {
    [and(a, not(s)), and(a, s)].x2
}

func not16(_ a: IntX16) -> IntX16 {
    a.map(not).x16
}

func and16(_ a: IntX16, _ b: IntX16) -> IntX16 {
    zip(a, b).map(and).x16
}

func or16(_ a: IntX16, _ b: IntX16) -> IntX16 {
    zip(a, b).map(or).x16
}

func mux16(_ a: IntX16, _ b: IntX16, _ s: Int) -> IntX16 {
    zip(a, b).map { mux($0, $1, s) }.x16
}

func or8Way(_ a: IntX8) -> Int {
    a.reduce(0, or)
}

func mux4Way16(_ a: IntX16, _ b: IntX16, _ c: IntX16, _ d: IntX16, _ s1: Int, _ s2: Int) -> IntX16 {
    mux16(mux16(a, b, s2), mux16(c, d, s2), s1)
}

func mux8Way16(_ a: IntX16, _ b: IntX16, _ c: IntX16, _ d: IntX16, _ e: IntX16, _ f: IntX16, _ g: IntX16, _ h: IntX16, _ s1: Int, _ s2: Int, _ s3: Int) -> IntX16 {
    mux16(mux4Way16(a, b, c, d, s2, s3),
          mux4Way16(e, f, g, h, s2, s3),
          s1)
}

func deMux4Way(_ a: Int, _ s1: Int, _ s2: Int) -> IntX4 {
    let deMuxS2 = deMux(a, s2)
    let deMuxS2S1 = (deMux(deMuxS2[0], s1),
                     deMux(deMuxS2[1], s1))
    
    return [deMuxS2S1.0[0],
            deMuxS2S1.1[0],
            deMuxS2S1.0[1],
            deMuxS2S1.1[1]].x4
}

func deMux8Way(_ a: Int, _ s1: Int, _ s2: Int, _ s3: Int) -> IntX8 {
    let deMuxS2S3 = deMux4Way(a, s2, s3)
    let deMuxS2S3S1 = (deMux(deMuxS2S3[0], s1),
                       deMux(deMuxS2S3[1], s1),
                       deMux(deMuxS2S3[2], s1),
                       deMux(deMuxS2S3[3], s1))
    
    return [deMuxS2S3S1.0[0],
            deMuxS2S3S1.1[0],
            deMuxS2S3S1.2[0],
            deMuxS2S3S1.3[0],
            deMuxS2S3S1.0[1],
            deMuxS2S3S1.1[1],
            deMuxS2S3S1.2[1],
            deMuxS2S3S1.3[1]].x8
}

extension Int {
    var bool: Bool {
        self == 1
    }
    
    mutating func increment() {
        self += 1
    }
}

extension Bool {
    var int: Int {
        self ? 1 : 0
    }
}

extension Int {
    var d: Double {
        Double(self)
    }
}
