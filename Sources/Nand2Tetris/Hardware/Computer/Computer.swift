import Foundation
import XCTest

final class Computer {
    let cpu: CPU
    let memory: Memory
    let rom = FastRAM(32768)
    
    var reset: Char = "0"
    var cycles = Int.max
    var usesFastClocking = false
    
    init(cpu: CPU, memory: Memory) {
        self.cpu = cpu
        self.memory = memory
    }
    
    func load(_ instructions: [String]) {
        rom.load(instructions)
    }
    
    var clockState: Char = "0"
    var nextClock: Char {
        defer {
            clockState = clockState == "0"
            ? "1"
            : "0"
        }
        cycles -= 1
        return usesFastClocking ? "1" : clockState
    }
    
    func run() {
        DispatchQueue.global().async { [self] in
            runSync()
        }
    }
    
    func runSync() {
        var lastOut = CPU.Out.null
        while cycles > 0 {
            lastOut = performNext(lastOut, nextClock)
        }
    }
    
    private func performNext(
        _ current: CPU.Out,
        _ clock: Char
    ) -> CPU.Out {
        let mOut = memory(current.mValue,
                          current.shouldWrite,
                          current.aValue,
                          clock)

        return cpu(mOut,
                   rom[current.pcValue],
                   reset,
                   clock)
    }
}

extension CPU.Out {
    static var null: CPU.Out {
        CPU.Out(mValue: 0.b,
                shouldWrite: "0",
                aValue: 0.b,
                pcValue: 0.b)
    }
}

extension FastRAM {
    subscript(_ address: String) -> String {
        self(zero(address), zero(address)[0], address, "1")
    }
    
    func load(_ instructions: [String]) {
        reset()
        
        instructions.enumerated().forEach {
            words[$0.offset] = $0.element
        }
    }
    
    func reset() {
        for i in 0..<words.count {
            words[i] = 0.b
        }
    }
}
