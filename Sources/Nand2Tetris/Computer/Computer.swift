import Foundation

final class Computer {
    let cpu: CPU
    let memory: Memory
    var rom = FastRAM(32768)
    
    var reset: Char = "0"
    
    init(cpu: CPU, memory: Memory) {
        self.cpu = cpu
        self.memory = memory
    }
    
    func load(_ instructions: [String]) {
        rom.load(instructions)
    }
    
    private var clockStorage: Char = "0"
    var clock: Char {
        defer {
            clockStorage = clockStorage == "0" ? "1" : "0"
        }
        
        return clockStorage
    }
    
    func run() {
        DispatchQueue.global().async { [self] in
            var lastOut = performNext(CPU.Out.null, clock: clock)
            while true {
                lastOut = performNext(lastOut, clock: clock)
            }
        }
    }
    
    private func performNext(_ previous: CPU.Out, clock: Char) -> CPU.Out {
        let mOut = memory(previous.mValue,
                          previous.shouldWrite,
                          previous.aValue,
                          clock)
        
        let current = cpu(mOut,
                          rom[previous.pcValue],
                          reset,
                          clock)
        
        return current
    }
}

extension CPU.Out {
    static var null: CPU.Out {
        CPU.Out(mValue: "0".toBinary(),
                shouldWrite: "0",
                aValue: "0".toBinary(),
                pcValue: "0".toBinary())
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
            words[i] = "0".toBinary()
        }
    }
}
