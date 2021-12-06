func halfAdder(_ a: Int, _ b: Int) -> IntX2 {
    IntX2(carry: and(a, b),
          sum:   xor(a, b))
}

func fullAdder(_ a: Int, _ b: Int, _ c: Int) -> IntX2 {
    let addAB = halfAdder(a, b)
    let addABC = halfAdder(addAB.sum, c)
    
    return IntX2(carry: or(addABC.carry, addAB.carry),
                 sum:   addABC.sum)
}

extension IntX2 {
    var sum: Int { self[1] }
    var carry: Int { self[0] }
    
    convenience init(carry: Int, sum: Int) {
        self.init([carry, sum])
    }
}
