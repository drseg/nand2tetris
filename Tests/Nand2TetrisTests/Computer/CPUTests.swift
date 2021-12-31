import XCTest
@testable import Nand2Tetris

class CPUTests: XCTestCase {
    var cpu: CPU!
    
    override func setUp() {
        cpu = CPU()
    }
    
    func setA(_ value: String) {
        cpu("0", "0" + value, "0", "1")
    }
    
    func setDToA() -> CPU.Out {
        cpu("0", "1110110000010000", "0", "1")
    }
    
    func cpuOut(
        toMemory: String = "*******",
        shouldWrite: Char = "0",
        aValue: String,
        pcValue: String
    ) -> CPU.Out {
        CPU.Out(toMemory: toMemory,
                shouldWrite: shouldWrite,
                aValue: aValue,
                pcValue: pcValue)
    }
    
    func testAInstructions() {
        let expected1 = cpuOut(aValue: "0".toBinary(15),
                               pcValue: "0".toBinary())
        
        let expected2 = cpuOut(aValue: "011000000111001",
                               pcValue: "1".toBinary())
        
        let expected3 = cpuOut(aValue: "011000000111001",
                               pcValue: "1".toBinary())
        
        let expected4 = cpuOut(aValue: "101101110100000",
                               pcValue: "2".toBinary())
        
        cpu("0", "0011000000111001", "0", "0") => expected1
        cpu("0", "0011000000111001", "0", "1") => expected2
        
        cpu("0", "0101101110100000", "0", "0") => expected3
        cpu("0", "0101101110100000", "0", "1") => expected4
    }
    
    func testDInstructions() {
        setA("011000000111001")
        setDToA() => cpuOut(aValue: "011000000111001",
                            pcValue: "2".toBinary())
        cpu.d.currentValue => "011000000111001"
        
        
        setA("101101110100000")
    }
    
    func testAcceptance() throws {
        throw XCTSkip()
        
        let cpu = CPU()
        
        try FileBasedATR("Computer/CPU-external", firstOutputColumn: 4) {
            let clock = $0[0].clockSignal
            let input = $0[1].toBinary()
            let instruction = $0[2]
            let reset = $0[3].toChar
            
            let result = cpu(input, instruction, reset, clock)
            
            var output = result.toMemory
            output = output.first! == "*"
                ? output
                : output.toDecimal()
            
            return [output,
                    result.shouldWrite,
                    result.aValue.toDecimal(),
                    result.pcValue.toDecimal()]
        }.run()
    }
}

extension Register {
    fileprivate var currentValue: String {
        self("0".toBinary(15), "0", "0")
    }
}
