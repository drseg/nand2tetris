var nandGatesUsed = 0

// nand considered primitive, implemented using Swift builtins
func nand(_ a: Int, _ b: Int) -> Int {
    nandGatesUsed += 1
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

extension Int {
    var asBool: Bool {
        self == 0 ? false : true
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

