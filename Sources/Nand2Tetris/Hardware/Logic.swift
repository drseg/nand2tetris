typealias Char = Character

/// nand considered primitive, implemented using Swift builtins
func nand(_ a: Char, _ b: Char) -> Char {
    a == "0" || b == "0" ? "1" : "0"
}

func not(_ a: Char) -> Char {
    nand(a, a)
}

func and(_ a: Char, _ b: Char) -> Char {
    not(nand(a, b))
}

func or(_ a: Char, _ b: Char) -> Char {
    nand(not(a), not(b))
}

func xor(_ a: Char, _ b: Char) -> Char {
    let nandAB = nand(a, b)
    return nand(nand(a, nandAB), nand(b, nandAB))
}

func mux(_ a: Char, _ b: Char, _ s: Char) -> Char {
    let notBS = nand(b, s)
    let notANotS = nand(a, nand(s, s))
    
    return nand(notANotS, notBS)
}

func deMux(_ a: Char, _ s: Char) -> String {
    "\(and(a, not(s)))\(and(a, s))"
}

func not16(_ a: String) -> String {
    String(a.map(not))
}

func and16(_ a: String, _ b: String) -> String {
    String(zip(a, b).map(and))
}

func or16(_ a: String, _ b: String) -> String {
    String(zip(a, b).map(or))
}

func mux16(_ a: String, _ b: String, _ s: Char) -> String {
    String(zip(a, b).map { mux($0, $1, s) })
}

func or8Way(_ a: String) -> Char {
    a.reduce("0", or)
}

func mux4Way16(
    _ a: String,
    _ b: String,
    _ c: String,
    _ d: String,
    _ s1: Char,
    _ s2: Char
) -> String {
    mux16(mux16(a, b, s2), mux16(c, d, s2), s1)
}

func mux8Way16(
    _ a: String,
    _ b: String,
    _ c: String,
    _ d: String,
    _ e: String,
    _ f: String,
    _ g: String,
    _ h: String,
    _ s1: Char,
    _ s2: Char,
    _ s3: Char
) -> String {
    mux16(mux4Way16(a, b, c, d, s2, s3),
          mux4Way16(e, f, g, h, s2, s3),
          s1)
}

func deMux4Way(
    _ a: Char,
    _ s1: Char,
    _ s2: Char
) -> String {
    let deMuxS2 = deMux(a, s2)
    let deMuxS2S1 = (deMux(deMuxS2[0], s1),
                     deMux(deMuxS2[1], s1))
    
    return String([deMuxS2S1.0[0],
                   deMuxS2S1.1[0],
                   deMuxS2S1.0[1],
                   deMuxS2S1.1[1]])
}

func deMux8Way(
    _ a: Char,
    _ s1: Char,
    _ s2: Char,
    _ s3: Char
) -> String {
    let deMuxS2S3 = deMux4Way(a, s2, s3)
    let deMuxS2S3S1 = (deMux(deMuxS2S3[0], s1),
                       deMux(deMuxS2S3[1], s1),
                       deMux(deMuxS2S3[2], s1),
                       deMux(deMuxS2S3[3], s1))
    
    return String([deMuxS2S3S1.0[0],
                   deMuxS2S3S1.1[0],
                   deMuxS2S3S1.2[0],
                   deMuxS2S3S1.3[0],
                   deMuxS2S3S1.0[1],
                   deMuxS2S3S1.1[1],
                   deMuxS2S3S1.2[1],
                   deMuxS2S3S1.3[1]])
}

extension String {
    subscript(_ i: Int) -> Char {
        prefix(i + 1).last!
    }
}
