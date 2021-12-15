// Data Flip Flops cannot be perfectly represeted in code as they depend on a feedback loop between the final two nand gates. This is a reasonable approximation of a standard 5 gate implementation
final class DataFlipFlop {
 
    private var Q = "0".toChar
    private var notQ = "1".toChar
    
    func callAsFunction(_ D: Char, _ C: Char) -> Char {
        let nandCNotD = nand(C, not(D))
        
        notQ = nand(nandCNotD, nandCNotD == "0" ? "1" : Q)
        Q = nand(nand(C, D), notQ)
        
        return Q
    }
}

final class Bit {

    private let dff = DataFlipFlop()
    
    func callAsFunction(_ input: Char, _ load: Char, _ clock: Char) -> Char {
        dff(input, and(load, clock))
    }
}

final class Register {
    
    private let bits = [Bit](count: 16, forEach: Bit())
    
    func callAsFunction(decimalInput: String, _ load: Char, _ clock: Char) -> String {
        callAsFunction(decimalInput.toBinary(16), load, clock)
    }
    
    func callAsFunction(_ input: String, _ load: Char, _ clock: Char) -> String {
        zip(input, bits).reduce(into: "") {
            $0.append($1.1($1.0, load, clock))
        }
    }
}

protocol RAM {
    
    func callAsFunction(_ word: String, _ load: Char, _ address: String, _ clock: Char) -> String
}

final class FastRAM: RAM {
    
    var words: [String]
    
    init(_ bits: Int) {
        words = [String](count: bits,
                         forEach: String(repeating: "0",
                                             count: 16))
    }
    
    func callAsFunction(_ word: String, _ load: Char, _ address: String, _ clock: Char) -> String {
        let address = address.toDecimal.decimalToInt
        if load == "1" && clock == "1" {
            words[address] = word
        }
        
        return words[address]
    }
}

final class RAM8: RAM {
    
    private let registers = [Register](count: 8,
                                       forEach: Register())
    
    func callAsFunction(_ word: String, _ load: Char, _ address: String, _ clock: Char) -> String {
        let loadMap = deMux8Way(load, address[0], address[1], address[2])
        let clockMap = deMux8Way(clock, address[0], address[1], address[2])
        
        let out = registers.enumerated().reduce([String]()) {
            $0 + [$1.element(word,
                             loadMap[$1.offset],
                             clockMap[$1.offset])]
        }
        
        return mux8Way16(out[0], out[1], out[2], out[3], out[4], out[5], out[6], out[7], address[0], address[1], address[2])
    }
}

protocol RAMx8: RAM {
    
    var subRAM: [RAM] { get }
    var addressLength: Int { get }
}

extension RAMx8 {
    
    func callAsFunction(_ word: String, _ load: Char, _ address: String, _ clock: Char) -> String {
        let loadMap = deMux8Way(load, address[0], address[1], address[2])
        let clockMap = deMux8Way(clock, address[0], address[1], address[2])
        
        let ramAddress = String(address.suffix(addressLength))
        
        let out = subRAM.enumerated().reduce(into: [String]()) {
            $0.append(
                $1.element(word,
                           loadMap[$1.offset],
                           ramAddress,
                           clockMap[$1.offset])
            )
        }
        
        return mux8Way16(out[0], out[1], out[2], out[3], out[4], out[5], out[6], out[7], address[0], address[1], address[2])
    }
}

final class RAM64: RAMx8 {
    
    let addressLength = 3
    var subRAM: [RAM] = [FastRAM](count: 8, forEach: FastRAM(8))
}

final class RAM512: RAMx8 {
    
    let addressLength = 6
    var subRAM: [RAM] = [RAM64](count: 8, forEach: RAM64())
}

final class RAM4K: RAMx8 {
    
    let addressLength = 9
    var subRAM: [RAM] = [FastRAM](count: 8, forEach: FastRAM(512))
}

final class RAM16K: RAM {
    
    private let ram4Ks = [RAM4K](count: 4,
                                 forEach: RAM4K())
    
    func callAsFunction(_ word: String, _ load: Char, _ address: String, _ clock: Char) -> String {
        let loadMap = deMux4Way(load, address[0], address[1])
        let clockMap = deMux4Way(clock, address[0], address[1])
        
        let ram4KAddress = String(address.suffix(12))
        
        let out = ram4Ks.enumerated().reduce(into: [String]()) {
            $0.append(
                $1.element(word,
                           loadMap[$1.offset],
                           ram4KAddress,
                           clockMap[$1.offset])
            )
        }
        
        return mux4Way16(out[0], out[1], out[2], out[3], address[0], address[1])
    }
}

extension String {
    
    func toBinary(_ length: Int) -> String {
        guard Int16(self) != Int16.min else {
            return not16(String(Int16.max).bin(length))
        }
        
        return Int16(self)! < 0
        ? inc16(not16((String(self.dropFirst())).bin(length)))
        : bin(length)
    }
    
    private func bin(_ length: Int) -> String {
        assert(length <= 16)
        return String(decimalToInt, radix: 2).leftPad(length: length)
    }
    
    var toDecimal: String {
        let s = leftPad(length: 16)
        
        return s[0] == "1"
        ? String(s.binaryToInt - Int(UInt16.max) - 1)
        : String(s.binaryToInt)
    }
    
    private var binaryToInt: Int {
        Int(self, radix: 2)!
    }
    
    var decimalToInt: Int {
        Int(self)!
    }

    private func leftPad(length: Int) -> String {
        String(repeating: "0", count: length - count) + self
    }
}

extension Array {
    
    init(count: Int, forEach block: @autoclosure () -> (Element)) {
        self.init()
        (0..<count).forEach { _ in append(block()) }
    }
}

