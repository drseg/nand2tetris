final class Computer {
    let cpu: CPU
    // let memory: Memory
    var rom: [String]!
    
    var instructions: [String] {
        return rom
    }
    
    init(cpu: CPU) {
        self.cpu = cpu
    }
    
    func load(_ instructions: [String]) {
        rom = [String](repeating: "0".toBinary(), count: 32768)
        
        instructions.enumerated().forEach {
            rom[$0.offset] = $0.element
        }
    }
}
