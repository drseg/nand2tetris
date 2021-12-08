func zero(_ a: IntX16) -> IntX16 {
    and16(not16(a), a)
}

func one(_ a: Int) -> Int {
    or(not(a), a)
}

func isZero(_ a: IntX16) -> Int {
    let first8 = Array(a[0..<8]).x8
    let last8 = Array(a[8...]).x8
    return not(or(or8Way(first8), or8Way(last8)))
}

func isNegative(_ a: IntX16) -> Int {
    and(one(a[0]), a[0])
}

