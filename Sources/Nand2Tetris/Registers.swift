class DataFlipFlop {
    
    private var Q = 0
    private var notQ = 1
    
    func callAsFunction(_ D: Int, _ C: Int) -> Int {
        let nandCNotD = nand(C, not(D))
        
        notQ = nand(nandCNotD, nandCNotD == 0 ? 1 : Q)
        Q = nand(nand(C, D), notQ)
        
        return Q
    }
}

class Bit {

    private let dff = DataFlipFlop()
    
    func callAsFunction(_ input: Int, _ load: Int, _ clock: Int) -> Int {
        dff(input, and(load, clock))
    }
}

class Register {
    
    private var bits: [Bit]
    
    init() {
        self.bits = [Bit]()
        (0..<16).forEach { _ in bits.append(Bit()) }
    }

    func callAsFunction(_ input: Int16, _ load: Int, _ clock: Int) -> IntX16 {
        self(input.x16, load, clock)
    }
    
    func callAsFunction(_ input: IntX16, _ load: Int, _ clock: Int) -> IntX16 {
        zip(input, bits).reduce([Int]()) {
            $0 + [$1.1($1.0, load, clock)]
        }.x16
    }
}

extension Int16 {
    
    var x16: IntX16 {
        guard self != Int16.min else {
            return not16(Int16.max.bin.x16)
        }
        
        return self < 0
        ? inc16(not16((-self).bin.x16))
        : bin.x16
    }
    
    var bin: String {
        String(self, radix: 2).leftPad(length: 16)
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
        
    func leftPad(length: Int) -> String {
        String(repeating: "0", count: length - count) + self
    }
}

