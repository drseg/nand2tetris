//final class DataFlipFlop {
//    
//    private var Q = 0
//    private var notQ = 1
//    
//    func callAsFunction(_ D: Int, _ C: Int) -> Int {
//        let nandCNotD = nand(C, not(D))
//        
//        notQ = nand(nandCNotD, nandCNotD == 0 ? 1 : Q)
//        Q = nand(nand(C, D), notQ)
//        
//        return Q
//    }
//}
//
//final class Bit {
//
//    private let dff = DataFlipFlop()
//    
//    func callAsFunction(_ input: Int, _ load: Int, _ clock: Int) -> Int {
//        dff(input, and(load, clock))
//    }
//}
//
//final class Register {
//    
//    private let bits = [Bit](count: 16, eachElement: Bit())
//
//    func callAsFunction(_ input: Int16, _ load: Int, _ clock: Int) -> IntX16 {
//        self(input.x16, load, clock)
//    }
//    
//    func callAsFunction(_ input: IntX16, _ load: Int, _ clock: Int) -> IntX16 {
//        zip(input, bits).reduce([Int]()) {
//            $0 + [$1.1($1.0, load, clock)]
//        }.x16
//    }
//}
//
//final class RAM8 {
//    
//    private let registers = [Register](count: 8, eachElement: Register())
//    
//    func callAsFunction(_ word: IntX16, _ load: Int, _ address: IntX3, _ clock: Int) -> IntX16 {
//        let loadMap = deMux8Way(load, address[0], address[1], address[2])
//        let clockMap = deMux8Way(clock, address[0], address[1], address[2])
//        let wordMap = deMux8Way16(word, address[0], address[1], address[2])
//        
//        let out = registers.enumerated().reduce([String]()) {
//            $0 + [$1.element(wordMap[$1.offset],
//                             loadMap[$1.offset],
//                             clockMap[$1.offset]).toString]
//        }.map(\.x16)
//        
//        return mux8Way16(out[0], out[1], out[2], out[3], out[4], out[5], out[6], out[7], address[0], address[1], address[2])
//    }
//}
//
//final class CheatingRAM8 {
//    
//    var words = [[Int]](count: 8, eachElement: [Int](repeating: 0, count: 16))
//    
//    func callAsFunction(_ word: IntX16, _ load: Int, _ address: IntX3, _ clock: Int) -> IntX16 {
//        if load == 1 && clock == 1 {
//            words[address.toDecimal] = word.underlyingArray
//        }
//        
//        return words[address.toDecimal].x16
//    }
//}
//
//final class RAM64 {
//    
//    private let ram8s = [CheatingRAM8](count: 8, eachElement: CheatingRAM8())
//    
//    func callAsFunction(_ word: IntX16, _ load: Int, _ address: IntX6, _ clock: Int) -> IntX16 {
//        let loadMap = deMux8Way(load, address[0], address[1], address[2])
//        let clockMap = deMux8Way(clock, address[0], address[1], address[2])
//        let wordMap = deMux8Way16(word, address[0], address[1], address[2])
//        
//        let ram8Address = Array(address.suffix(from: 3)).x3
//        
//        let out = ram8s.enumerated().reduce([String]()) {
//            $0 + [$1.element(wordMap[$1.offset],
//                             loadMap[$1.offset],
//                             ram8Address,
//                             clockMap[$1.offset]).toString]
//        }.map(\.x16)
//        
//        return mux8Way16(out[0], out[1], out[2], out[3], out[4], out[5], out[6], out[7], address[0], address[1], address[2])
//    }
//}
//
//final class RAM512 {
//    
//    private let ram64s = [RAM64](count: 8, eachElement: RAM64())
//    
//    func callAsFunction(_ word: IntX16, _ load: Int, _ address: IntX9, _ clock: Int) -> IntX16 {
//        let loadMap = deMux8Way(load, address[0], address[1], address[2])
//        let clockMap = deMux8Way(clock, address[0], address[1], address[2])
//        let wordMap = deMux8Way16(word, address[0], address[1], address[2])
//        
//        let ram64Address = Array(address.suffix(from: 3)).x6
//        
//        let out = ram64s.enumerated().reduce([String]()) {
//            $0 + [$1.element(wordMap[$1.offset],
//                             loadMap[$1.offset],
//                             ram64Address,
//                             clockMap[$1.offset]).toString]
//        }.map(\.x16)
//        
//        return mux8Way16(out[0], out[1], out[2], out[3], out[4], out[5], out[6], out[7], address[0], address[1], address[2])
//    }
//}
//
//final class CheatingRAM512 {
//    
//    var words = [[Int]](count: 512, eachElement: [Int](repeating: 0, count: 16))
//    
//    func callAsFunction(_ word: IntX16, _ load: Int, _ address: IntX9, _ clock: Int) -> IntX16 {
//        if load == 1 && clock == 1 {
//            words[address.toDecimal] = word.underlyingArray
//        }
//        
//        return words[address.toDecimal].x16
//    }
//}
//
//final class RAM4K {
//    
//    private let ram512s = [CheatingRAM512](count: 8, eachElement: CheatingRAM512())
//    
//    func callAsFunction(_ word: IntX16, _ load: Int, _ address: IntX12, _ clock: Int) -> IntX16 {
//        let loadMap = deMux8Way(load, address[0], address[1], address[2])
//        let clockMap = deMux8Way(clock, address[0], address[1], address[2])
//        let wordMap = deMux8Way16(word, address[0], address[1], address[2])
//        
//        let ram512Address = Array(address.suffix(from: 3)).x9
//        
//        let out = ram512s.enumerated().reduce([String]()) {
//            $0 + [$1.element(wordMap[$1.offset],
//                             loadMap[$1.offset],
//                             ram512Address,
//                             clockMap[$1.offset]).toString]
//        }.map(\.x16)
//        
//        return mux8Way16(out[0], out[1], out[2], out[3], out[4], out[5], out[6], out[7], address[0], address[1], address[2])
//    }
//}
//
//final class RAM16K {
//    
//    private let ram4Ks = [RAM4K](count: 4, eachElement: RAM4K())
//    
//    func callAsFunction(_ word: IntX16, _ load: Int, _ address: IntX14, _ clock: Int) -> IntX16 {
//        let loadMap = deMux4Way(load, address[0], address[1])
//        let clockMap = deMux4Way(clock, address[0], address[1])
//        let wordMap = deMux4Way16(word, address[0], address[1])
//        
//        let ram4KAddress = Array(address.suffix(from: 2)).x12
//        
//        let out = ram4Ks.enumerated().reduce([String]()) {
//            $0 + [$1.element(wordMap[$1.offset],
//                             loadMap[$1.offset],
//                             ram4KAddress,
//                             clockMap[$1.offset]).toString]
//        }.map(\.x16)
//        
//        return mux4Way16(out[0], out[1], out[2], out[3], address[0], address[1])
//    }
//}
//
//func deMux4Way16(_ a: IntX16, _ s1: Int, _ s2: Int) -> [IntX16] {
//    a.reduce(into: [[Int]](count: 4, eachElement: [Int]())) { out, bit in
//        deMux4Way(bit, s1, s2).enumerated().forEach { deMuxedBit in
//            out[deMuxedBit.offset].append(deMuxedBit.element)
//        }
//    }.map(\.x16)
//}
//
//func deMux8Way16(_ a: IntX16, _ s1: Int, _ s2: Int, _ s3: Int) -> [IntX16] {
//    a.reduce(into: [[Int]](count: 8, eachElement: [Int]())) { out, bit in
//        deMux8Way(bit, s1, s2, s3).enumerated().forEach { deMuxedBit in
//            out[deMuxedBit.offset].append(deMuxedBit.element)
//        }
//    }.map(\.x16)
//}
//
//extension Int16 {
//    
//    var x3: IntX3   { xX(length: 3).x3 }
//    var x6: IntX6   { xX(length: 6).x6 }
//    var x9: IntX9   { xX(length: 9).x9 }
//    var x12: IntX12 { xX(length: 12).x12 }
//    var x14: IntX14 { xX(length: 14).x14 }
//    
//    var x16: IntX16 {
//        guard self != Int16.min else {
//            return not16(Int16.max.toBinary.x16)
//        }
//        
//        return self < 0
//        ? inc16(not16((-self).toBinary.x16))
//        : toBinary.x16
//    }
//    
//    func xX(length: Int) -> [Int] {
//        Array(
//            Int16(
//                String(self).leftPad(length: 16)
//            )!.x16.suffix(from: 16 - length)
//        )
//    }
//    
//    var toBinary: String {
//        String(self, radix: 2).leftPad(length: 16)
//    }
//}
//
//extension CountConstrainedIntArray {
//    
//    var toDecimal: Int {
//        let x16 = toString.leftPad(length: 16).x16
//        
//        return x16.first! == 1
//        ? x16.toInt - Int(UInt16.max) - 1
//        : x16.toInt
//    }
//    
//    private var toInt: Int {
//        Int(toString, radix: 2)!
//    }
//}
//
//extension String {
//        
//    func leftPad(length: Int) -> String {
//        String(repeating: "0", count: length - count) + self
//    }
//}
//
//extension Array {
//    
//    init(count: Int, eachElement block: @autoclosure () -> (Element)) {
//        self.init()
//        (0..<count).forEach { _ in append(block()) }
//    }
//}
//
