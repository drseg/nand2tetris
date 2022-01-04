import Foundation

final class Computer {
    let cpu: CPU
    let memory: Memory
    var rom = FastRAM(32768)
    
    var reset: Char = "0"
    
    private var clockState: Char = "0"
    var clock: Char {
        defer { clockState = clockState == "0" ? "1" : "0" }
        return clockState
    }
    
    init(cpu: CPU, memory: Memory) {
        self.cpu = cpu
        self.memory = memory
    }
    
    func load(_ instructions: [String]) {
        rom.load(instructions)
    }
    
    func run() {
        DispatchQueue.global().async { [self] in
            var lastOut = CPU.Out.null
            while true {
                lastOut = performNext(lastOut, clock: clock)
            }
        }
    }
    
    private func performNext(_ current: CPU.Out, clock: Char) -> CPU.Out {
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
