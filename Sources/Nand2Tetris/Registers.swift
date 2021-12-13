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

class RAM8 {
    
    private var registers = [Register]()
    
    init() {
        (0..<8).forEach { _ in registers.append(Register()) }
    }
    
    func callAsFunction(_ word: IntX16, _ load: Int, _ address: IntX3, _ clock: Int) -> IntX16 {
        let loadMap = deMux8Way(load, address[0], address[1], address[2])
        let clockMap = deMux8Way(clock, address[0], address[1], address[2])
        let wordMap = deMux8Way16(word, address[0], address[1], address[2])
        
        let outputs = registers.enumerated().reduce([String]()) {
            $0 + [$1.element(wordMap[$1.offset], loadMap[$1.offset], clockMap[$1.offset]).toString]
        }.map(\.x16)
        
        return mux8Way16(outputs[0], outputs[1], outputs[2], outputs[3], outputs[4], outputs[5], outputs[6], outputs[7], address[0], address[1], address[2])
    }
}

func deMux8Way16(_ a: IntX16, _ s1: Int, _ s2: Int, _ s3: Int) -> [IntX16] {
    var arrays = (0..<8).map { _ in [Int]() }
    a.forEach { bit in
        deMux8Way(bit, s1, s2, s3).enumerated().forEach { deMuxedBit in
            arrays[deMuxedBit.offset].append(deMuxedBit.element)
        }
    }
    
    return arrays.map(\.x16)
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
    
    var x3: IntX3 {
        Array(
            Int16(
                String(self).leftPad(length: 16))!
                .x16
                .suffix(from: 13)
        ).x3
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

