/// Data Flip Flops cannot be perfectly represeted in code as they depend on a feedback loop between the final two nand gates. This is a reasonable approximation of a standard 5 gate implementation
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
    
    func callAsFunction(
        _ input: Char,
        _ load: Char,
        _ clock: Char
    ) -> Char {
        dff(input, and(load, clock))
    }
}

final class Register {
    private let bits = [Bit](count: 16, forEach: Bit())
    
    @discardableResult
    func callAsFunction(
        _ input: String,
        _ load: Char,
        _ clock: Char
    ) -> String {
        zip(input, bits).reversed().reduce("") {
            String($1.1($1.0, load, clock)) + $0
        }
    }
}

final class PC {
    private let register = Register()
    
    func callAsFunction(
        _ input: String,
        _ reset: Char,
        _ load: Char,
        _ inc: Char,
        _ clock: Char
    ) -> String {
        let lastInput = register(
            input,
            zero(input)[0],
            clock
        )
        
        let shouldInc = and(
            inc,
            and(
                not(reset),
                not(load)
            )
        )
        
        let incrementedOrNot = mux16(
            input,
            inc16(lastInput),
            shouldInc
        )
        
        let registerInput = mux16(
            incrementedOrNot,
            zero(input),
            reset
        )
        
        let shouldLoadInput = or(
            or(
                reset,
                load
            ),
            inc
        )
        
        return register(
            registerInput,
            shouldLoadInput,
            clock
        )
    }
}

protocol RAM {
    func callAsFunction(
        _ word: String,
        _ load: Char,
        _ address: String,
        _ clock: Char
    ) -> String
}

final class FastRAM: RAM {
    var words: [String]
    
    init(_ bits: Int) {
        words = [String](repeating: 0.b,
                         count: bits)
    }
    
    @discardableResult
    func callAsFunction(
        _ word: String,
        _ load: Char,
        _ address: String,
        _ clock: Char
    ) -> String {
        let address = Int(address, radix: 2)!
        
        if load == "1" && clock == "1" {
            words[address] = word
        }
        
        return words[address]
    }
}

final class RAM8: RAM {
    private let registers = [Register](count: 8,
                                       forEach: Register())
    
    func callAsFunction(
        _ word: String,
        _ load: Char,
        _ address: String,
        _ clock: Char
    ) -> String {
        let loadMap = deMux8Way(load, address[0], address[1], address[2])
        let out = registers.enumerated().reduce([String]()) {
            $0 + [$1.element(word,
                             loadMap[$1.offset],
                             clock)]
        }
        
        return mux8Way16(out[0],
                         out[1],
                         out[2],
                         out[3],
                         out[4],
                         out[5],
                         out[6],
                         out[7],
                         address[0],
                         address[1],
                         address[2])
    }
}

protocol RAMx8: RAM {
    var subRAM: [RAM] { get }
}

extension RAMx8 {
    func callAsFunction(
        _ word: String,
        _ load: Char,
        _ address: String,
        _ clock: Char
    ) -> String {
        let loadMap = deMux8Way(load, address[0], address[1], address[2])
        let ramAddress = String(address.suffix(address.count - 3))
        
        let out = subRAM.enumerated().reduce(into: [String]()) {
            $0.append(
                $1.element(word,
                           loadMap[$1.offset],
                           ramAddress,
                           clock)
            )
        }
        
        return mux8Way16(out[0],
                         out[1],
                         out[2],
                         out[3],
                         out[4],
                         out[5],
                         out[6],
                         out[7],
                         address[0],
                         address[1],
                         address[2])
    }
}

final class RAM64: RAMx8 {
    var subRAM: [RAM] = [FastRAM](count: 8, forEach: FastRAM(8))
}

final class RAM512: RAMx8 {
    var subRAM: [RAM] = [FastRAM](count: 8, forEach: FastRAM(64))
}

final class RAM4K: RAMx8 {
    var subRAM: [RAM] = [FastRAM](count: 8, forEach: FastRAM(512))
}

final class RAM16K: RAM {
    private let ram4Ks = [FastRAM](count: 4, forEach: FastRAM(4096))
    
    func callAsFunction(
        _ word: String,
        _ load: Char,
        _ address: String,
        _ clock: Char
    ) -> String {
        let loadMap = deMux4Way(load, address[0], address[1])
        let ram4KAddress = String(address.suffix(12))
        
        let out = ram4Ks.enumerated().reduce(into: [String]()) {
            $0.append(
                $1.element(word,
                           loadMap[$1.offset],
                           ram4KAddress,
                           clock)
            )
        }
        
        return mux4Way16(out[0],
                         out[1],
                         out[2],
                         out[3],
                         address[0],
                         address[1])
    }
}

extension Array {
    init(count: Int, forEach block: @autoclosure () -> (Element)) {
        self.init()
        (0..<count).forEach { _ in append(block()) }
    }
}

