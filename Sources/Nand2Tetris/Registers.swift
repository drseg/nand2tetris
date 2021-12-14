final class DataFlipFlop {
    
    private var Q = "0".toChar
    private var notQ = "1".toChar
    
    func callAsFunction(_ D: Character, _ C: Character) -> Character {
        let nandCNotD = nand(C, not(D))
        
        notQ = nand(nandCNotD, nandCNotD == "0" ? "1" : Q)
        Q = nand(nand(C, D), notQ)
        
        return Q
    }
}

final class Bit {

    private let dff = DataFlipFlop()
    
    func callAsFunction(_ input: Character, _ load: Character, _ clock: Character) -> Character {
        dff(input, and(load, clock))
    }
}

final class Register {
    
    private let bits = [Bit](count: 16, eachElement: Bit())
    
    func callAsFunction(decimalInput: String, _ load: Character, _ clock: Character) -> String {
        callAsFunction(decimalInput.toBinary(16), load, clock)
    }
    
    func callAsFunction(_ input: String, _ load: Character, _ clock: Character) -> String {
        zip(input, bits).reduce(into: "") {
            $0.append($1.1($1.0, load, clock))
        }
    }
}

protocol RAM {
    func callAsFunction(_ word: String, _ load: Character, _ address: String, _ clock: Character) -> String
}

final class FastRAM: RAM {
    
    var words: [String]
    
    init(_ bits: Int) {
        words = [String](count: bits, eachElement: "0000000000000000")
    }
    
    func callAsFunction(_ word: String, _ load: Character, _ address: String, _ clock: Character) -> String {
        let address = Int(address.toDecimal)!
        if load == "1" && clock == "1" {
            words[address] = word
        }
        
        return words[address]
    }
}

final class RAM8: RAM {
    
    private let registers = [Register](count: 8, eachElement: Register())
    
    func callAsFunction(_ word: String, _ load: Character, _ address: String, _ clock: Character) -> String {
        let loadMap = deMux8Way(load, address[0], address[1], address[2])
        let clockMap = deMux8Way(clock, address[0], address[1], address[2])
        let wordMap = deMux8Way16(word, address[0], address[1], address[2])
        
        let out = registers.enumerated().reduce([String]()) {
            $0 + [$1.element(wordMap[$1.offset],
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
    
    func callAsFunction(_ word: String, _ load: Character, _ address: String, _ clock: Character) -> String {
        let loadMap = deMux8Way(load, address[0], address[1], address[2])
        let clockMap = deMux8Way(clock, address[0], address[1], address[2])
        let wordMap = deMux8Way16(word, address[0], address[1], address[2])
        
        let ramAddress = String(address.suffix(addressLength))
        
        let out = subRAM.enumerated().reduce([String]()) {
            $0 + [$1.element(wordMap[$1.offset],
                             loadMap[$1.offset],
                             ramAddress,
                             clockMap[$1.offset])]
        }
        
        return mux8Way16(out[0], out[1], out[2], out[3], out[4], out[5], out[6], out[7], address[0], address[1], address[2])
    }
}

final class RAM64: RAMx8 {
    
    let addressLength = 3
    var subRAM: [RAM] = [FastRAM](count: 8, eachElement: FastRAM(8))
}

final class RAM512: RAMx8 {
    
    let addressLength = 6
    var subRAM: [RAM] = [RAM64](count: 8, eachElement: RAM64())
}

final class RAM4K: RAMx8 {
    
    let addressLength = 9
    var subRAM: [RAM] = [FastRAM](count: 8, eachElement: FastRAM(512))
}

final class RAM16K: RAM {
    
    private let ram4Ks = [RAM4K](count: 4, eachElement: RAM4K())
    
    func callAsFunction(_ word: String, _ load: Character, _ address: String, _ clock: Character) -> String {
        let loadMap = deMux4Way(load, address[0], address[1])
        let clockMap = deMux4Way(clock, address[0], address[1])
        let wordMap = deMux4Way16(word, address[0], address[1])
        
        let ram4KAddress = String(address.suffix(12))
        
        let out = ram4Ks.enumerated().reduce([String]()) {
            $0 + [$1.element(wordMap[$1.offset],
                             loadMap[$1.offset],
                             ram4KAddress,
                             clockMap[$1.offset])]
        }
        
        return mux4Way16(out[0], out[1], out[2], out[3], address[0], address[1])
    }
}

func deMux4Way16(_ a: String, _ s1: Character, _ s2: Character) -> [String] {
    a.reduce(into: [String](count: 4, eachElement: "")) { out, bit in
        deMux4Way(bit, s1, s2).enumerated().forEach { deMuxedBit in
            out[deMuxedBit.offset].append(deMuxedBit.element)
        }
    }
}

func deMux8Way16(_ a: String, _ s1: Character, _ s2: Character, _ s3: Character) -> [String] {
    a.reduce(into: [String](count: 8, eachElement: "")) { out, bit in
        deMux8Way(bit, s1, s2, s3).enumerated().forEach { deMuxedBit in
            out[deMuxedBit.offset].append(deMuxedBit.element)
        }
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
        String(Int(self)!, radix: 2).leftPad(length: length)
    }
    
    var toDecimal: String {
        let s = leftPad(length: 16)
        
        return s.first! == "1"
        ? String(s.toInt - Int(UInt16.max) - 1)
        : String(s.toInt)
    }
    
    private var toInt: Int {
        Int(self, radix: 2)!
    }

    private func leftPad(length: Int) -> String {
        String(repeating: "0", count: length - count) + self
    }
}

extension Array {
    
    init(count: Int, eachElement block: @autoclosure () -> (Element)) {
        self.init()
        (0..<count).forEach { _ in append(block()) }
    }
}

