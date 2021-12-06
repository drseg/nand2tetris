func halfAdder(_ a: Int, _ b: Int) -> IntX2 {
    [and(a, b), xor(a, b)].x2
}

func fullAdder(_ a: Int, _ b: Int, _ c: Int) -> IntX2 {
    let addAB = halfAdder(a, b)
    let addABC = halfAdder(addAB.sum, c)
    
    return [or(addABC.carry, addAB.carry), addABC.sum].x2
}

extension IntX2 {
    var sum: Int { self[1] }
    var carry: Int {self[0] }
}
