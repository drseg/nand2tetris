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

final class RAM8 {
    
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

class CheatingRAM {
    
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

final class RAM64 {
    
    private let ram8s = [CheatingRAM](count: 8, eachElement: CheatingRAM(8))
    
    func callAsFunction(_ word: String, _ load: Character, _ address: String, _ clock: Character) -> String {
        let loadMap = deMux8Way(load, address[0], address[1], address[2])
        let clockMap = deMux8Way(clock, address[0], address[1], address[2])
        let wordMap = deMux8Way16(word, address[0], address[1], address[2])
        
        let ram8Address = String(address.suffix(3))
        
        let out = ram8s.enumerated().reduce([String]()) {
            $0 + [$1.element(wordMap[$1.offset],
                             loadMap[$1.offset],
                             ram8Address,
                             clockMap[$1.offset])]
        }
        
        return mux8Way16(out[0], out[1], out[2], out[3], out[4], out[5], out[6], out[7], address[0], address[1], address[2])
    }
}

final class RAM512 {
    
    private let ram64s = [RAM64](count: 8, eachElement: RAM64())
    
    func callAsFunction(_ word: String, _ load: Character, _ address: String, _ clock: Character) -> String {
        let loadMap = deMux8Way(load, address[0], address[1], address[2])
        let clockMap = deMux8Way(clock, address[0], address[1], address[2])
        let wordMap = deMux8Way16(word, address[0], address[1], address[2])
        
        let ram64Address = String(address.suffix(6))
        
        let out = ram64s.enumerated().reduce([String]()) {
            $0 + [$1.element(wordMap[$1.offset],
                             loadMap[$1.offset],
                             ram64Address,
                             clockMap[$1.offset])]
        }
        
        return mux8Way16(out[0], out[1], out[2], out[3], out[4], out[5], out[6], out[7], address[0], address[1], address[2])
    }
}

final class RAM4K {
    
    private let ram512s = [CheatingRAM](count: 8, eachElement: CheatingRAM(512))
    
    func callAsFunction(_ word: String, _ load: Character, _ address: String, _ clock: Character) -> String {
        let loadMap = deMux8Way(load, address[0], address[1], address[2])
        let clockMap = deMux8Way(clock, address[0], address[1], address[2])
        let wordMap = deMux8Way16(word, address[0], address[1], address[2])
        
        let ram512Address = String(address.suffix(9))
        
        let out = ram512s.enumerated().reduce([String]()) {
            $0 + [$1.element(wordMap[$1.offset],
                             loadMap[$1.offset],
                             ram512Address,
                             clockMap[$1.offset])]
        }
        
        return mux8Way16(out[0], out[1], out[2], out[3], out[4], out[5], out[6], out[7], address[0], address[1], address[2])
    }
}

final class RAM16K {
    
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

