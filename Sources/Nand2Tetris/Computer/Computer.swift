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
        rom = FastRAM(32768)
        
        instructions.enumerated().forEach {
            rom($0.element,
                one($0.element[0]),
                String($0.offset).toBinary(),
                one($0.element[0]))
        }
    }
    
    func run() {
        DispatchQueue.global().async { [self] in
            var last = fetchNext(CPU.Out.null)
            while true {
                last = fetchNext(last)
            }
        }
    }
    
    private func fetchNext(_ previous: CPU.Out) -> CPU.Out {
        let out = cpu(previous.mValue,
                      rom[previous.pcValue],
                      reset,
                      "1")
        
        memory(out.mValue,
               out.shouldWrite,
               out.aValue,
               "1")
        
        return out
    }
}

extension FastRAM {
    subscript(_ address: String) -> String {
        self(zero(address), zero(address)[0], address, "1")
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
