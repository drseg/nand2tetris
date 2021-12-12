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

class Register: Clocked {

    var input = "0000000000000000".x16
    var load = 0

    func update(_ input: Int16, _ load: Int) {
        self.input = input.x16
        self.load = load
    }

    func run(_ newValue: Int) -> ClockedOutput {
        let clockAndLoad = and(load, newValue)

        return input
    }
}

extension Int16 {
    
    var x16: IntX16 {
        self >= 0
        ? bin.x16
        : inc16(not16((self * -1).bin.x16))
    }
    
    var bin: String {
        String(self, radix: 2).leftPad(with: "0", length: 16)
    }
}

extension String {
    
    var isTock: Int {
        last == "+" ? 1 : 0
    }
    
    
    func leftPad(with character: Character, length: UInt) -> String {
        let maxLength = Int(length) - count
        guard maxLength > 0 else {
            return self
        }
        return String(repeating: String(character), count: maxLength) + self
    }
}

