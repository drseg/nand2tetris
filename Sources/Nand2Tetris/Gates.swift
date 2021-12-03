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
