func zero(_ a: String) -> String {
    and16(not16(a), a)
}

func one(_ a: Character) -> Character {
    or(not(a), a)
}

func isZero(_ a: String) -> Character {
    let first8 = String(a.prefix(8))
    let last8 = String(a.suffix(8))
    return not(or(or8Way(first8), or8Way(last8)))
}

func isNegative(_ a: String) -> Character {
    and(one(a[0]), a[0])
}

extension String {
    var toChar: Character {
        Character(self)
    }
    
    var clockSignal: Character {
        last == "+" ? "0" : "1"
    }
}

