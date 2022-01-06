func halfAdder(_ a: Char, _ b: Char) -> String {
    String(carry: and(a, b), sum: xor(a, b))
}

func fullAdder(_ a: Char, _ b: Char, _ c: Char) -> String {
    let addAB = halfAdder(a, b)
    let addABC = halfAdder(addAB.sum, c)
    
    return String(carry: or(addABC.carry, addAB.carry),
                  sum: addABC.sum)
}

func add16(_ a: String, _ b: String) -> String {
    String(
        zip(a,b)
            .reversed()
            .reduce(into: (sum: "", carry: "0".toChar)) {
                (result, addends) in
                let addition = fullAdder(addends.0, addends.1, result.carry)
                result.sum = String(addition.sum) + result.sum
                result.carry = addition.carry
            }.0
    )
}

func inc16(_ a: String) -> String {
    let one = not16(add16(not16(zero(a)), not16(zero(a))))
    return add16(a, one)
}

func alu(
    x: String,
    y: String,
    zx: Char,
    nx: Char,
    zy: Char,
    ny: Char,
    f: Char,
    no: Char
) -> (out: String, zr: Char, ng: Char) {
    let xZX = zeroIfZ(x, z: zx)
    let yZY = zeroIfZ(y, z: zy)
    
    let xNXZX = negateIfN(xZX, n: nx)
    let yNYZY = negateIfN(yZY, n: ny)
    
    let andOut = and16(xNXZX, yNYZY)
    let addOut = add16(xNXZX, yNYZY)

    let f_out = mux16(andOut, addOut, f)
    let not_f_out = not16(f_out)
    
    let out = mux16(f_out, not_f_out, no)
    let ng = isNegative(out)
    let zr = isZero(out)
    
    return (out, zr, ng)
}

private func negateIfN(_ a: String, n: Char) -> String {
    mux16(a, not16(a), n)
}

private func zeroIfZ(_ a: String, z: Char) -> String {
    mux16(a, zero(a), z)
}

private extension String {
    var carry: Char { self[0] }
    var sum: Char { self[1] }
    
    init(carry: Char, sum: Char) {
        self.init([carry, sum])
    }
}
