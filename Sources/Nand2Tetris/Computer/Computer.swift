final class Computer {
    let cpu: CPU
    let memory: Memory
    var rom = FastRAM(32768)
    
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
    
    func reset(_ reset: Char) {
        var next = fetchNext(rom["0".toBinary()], reset: reset)
        while next != "0".toBinary() {
            next = fetchNext(next, reset: reset)
        }
    }
    
    private func fetchNext(_ previous: String, reset: Char) -> String {
        let out = cpu(zero(previous),
                      previous,
                      reset, "1")
        memory(out.mValue,
               out.shouldWrite,
               out.aValue,
               "1")
        
        return rom[out.pcValue]
    }
}

extension FastRAM {
    subscript(_ address: String) -> String {
        self(zero(address), zero(address)[0], address, "1")
    }
}
