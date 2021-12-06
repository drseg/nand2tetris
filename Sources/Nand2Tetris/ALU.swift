func halfAdder(_ a: Int, _ b: Int) -> IntX2 {
    IntX2(carry: and(a, b),
          sum: xor(a, b))
}

func fullAdder(_ a: Int, _ b: Int, _ c: Int) -> IntX2 {
    let addAB = halfAdder(a, b)
    let addABC = halfAdder(addAB.sum, c)
    
    return IntX2(carry: or(addABC.carry, addAB.carry),
                 sum: addABC.sum)
}

func add16(_ a: IntX16, _ b: IntX16) -> IntX16 {
    zip(a.reversed(), b.reversed()).reduce(into: (sum: [Int](), carry: 0)) { (result, addends) in
        let addition = fullAdder(addends.0, addends.1, result.carry)
        result.sum += [addition.sum]
        result.carry = addition.carry
    }.0.reversed().x16
}

func inc16(_ a: IntX16) -> IntX16 {
    add16(a, [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1].x16)
}

private extension IntX2 {
    var sum: Int { self[1] }
    var carry: Int { self[0] }
    
    convenience init(carry: Int, sum: Int) {
        self.init([carry, sum])
    }
}
