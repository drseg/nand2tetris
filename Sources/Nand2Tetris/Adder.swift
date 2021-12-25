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

private extension String {
    var carry: Char { self[0] }
    var sum: Char { self[1] }
    
    init(carry: Char, sum: Char) {
        self.init([carry, sum])
    }
}
