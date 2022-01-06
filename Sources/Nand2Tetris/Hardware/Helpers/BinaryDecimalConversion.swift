extension BinaryInteger {
    func toBinary(_ width: Int = 16) -> String {
        String(self, radix: 2).leftPad(width)
    }
    
    var b: String {
        String(self).toBinary()
    }
}

extension String {
    func toBinary(_ width: Int = 16) -> String {
        twosComplement(width).toBinary(width)
    }
    
    private func twosComplement(_ width: Int) -> Int {
        let intValue = Int(self)!
        
        return intValue < 0
        ? intValue + intMax(width) + 1
        : intValue
    }
    
    func toDecimal(_ width: Int = 16) -> String {
        let padded = leftPad(width)
        let intValue = Int(padded, radix: 2)!
        
        return padded[0] == "1"
        ? String(intValue - intMax(width) - 1)
        : String(intValue)
    }
    
    private func intMax(_ width: Int) -> Int {
        2 << (width - 1) - 1
    }

    func leftPad(_ width: Int) -> String {
        String(repeating: "0", count: width - count) + self
    }
}
