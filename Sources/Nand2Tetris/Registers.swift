class Bit {
    
    private var input = 0
    private var load = 0
    private var lastOut = 0
    private var lastNotOut = 1
    
    func update(_ input: Int, _ load: Int, _ cycle: Int) -> Int {
        let clockAndLoad = and(load, not(cycle))
        let nandInputCL = nand(clockAndLoad, input)
        let nandNotInputCL = nand(clockAndLoad, not(input))
        
        lastNotOut = nand(nandNotInputCL, nandNotInputCL == 0 ? 1 : lastOut)
        lastOut = nand(nandInputCL, lastNotOut)
        
        return lastOut
    }
}

class Register {
    
    private var bitArray: [Bit]
    
    init() {
        self.bitArray = [Bit]()
        (0..<16).forEach { _ in bitArray.append(Bit()) }
    }

    func update(_ input: Int16, _ load: Int, _ cycle: Int) -> IntX16 {
        update(input.x16, load, cycle)
    }
    
    func update(_ input: IntX16, _ load: Int, _ cycle: Int) -> IntX16 {
        zip(input, bitArray).reduce([Int]()) {
            $0 + [$1.1.update($1.0, load, cycle)]
        }.x16
    }
}

extension Int16 {
    
    var x16: IntX16 {
        guard self != -32768 else {
            return not16((Int16.max).bin.x16)
        }
        
        return self >= 0
        ? bin.x16
        : inc16(not16((self * -1).bin.x16))
    }
    
    var bin: String {
        String(self, radix: 2).leftPad(with: "0", length: 16)
    }
}

extension IntX16 {
    
    var dec: Int {
        return first! == 1
        ? toInt - Int(UInt16.max) - 1
        : toInt
    }
    
    private var toInt: Int {
        Int(toString, radix: 2)!
    }
}

extension String {
    
    var isTock: Int {
        last == "+" ? 1 : 0
    }
    
    
    func leftPad(with character: Character, length: UInt) -> String {
        let maxLength = Int(length) - count
        return String(repeating: String(character), count: maxLength) + self
    }
}

