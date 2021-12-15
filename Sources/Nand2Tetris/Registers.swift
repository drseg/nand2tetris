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
        let address = Int(address.toDecimal())!
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
        twosComplement(length: length)
            .toBinary
            .leftPad(length)
    }
    
    private func twosComplement(length: Int) -> Int {
        let intValue = Int(self)!
        
        return intValue < 0
        ? intValue + 1 + intMax(length)
        : intValue
    }
    
    func toDecimal(_ length: Int = 16) -> String {
        let padded = leftPad(length)
        let intValue = Int(padded, radix: 2)!
        
        return padded[0] == "1"
        ? String(intValue - intMax(length) - 1)
        : String(intValue)
    }
    
    private func intMax(_ bits: Int) -> Int {
        2 << (bits - 1) - 1
    }

    private func leftPad(_ length: Int) -> String {
        String(repeating: "0", count: length - count) + self
    }
}

extension Int {
    
    var toBinary: String {
        String(self, radix: 2)
    }
}

extension Array {
    
    init(count: Int, forEach block: @autoclosure () -> (Element)) {
        self.init()
        (0..<count).forEach { _ in append(block()) }
    }
}

