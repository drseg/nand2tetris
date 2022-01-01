import XCTest
@testable import Nand2Tetris

class CPUTests: XCTestCase {
    var cpu: CPU!
    
    override func setUp() {
        cpu = CPU()
    }
    
    func setA(_ value: String) {
        let _ = cpu("0", "0" + value, "0", "1")
    }
    
    func dEqualsA() -> CPU.Out {
        writeFromRegisters("1110110000010000")
    }
    
    func aMinusD() -> CPU.Out {
        writeFromRegisters("1110000111010000")
    }
    
    func mEqualsD() -> CPU.Out {
        writeFromRegisters("1110001100001000")
    }
    
    func mdEqualsDMinusOne(clock: Char = "1") -> CPU.Out {
        writeFromRegisters("1110001110011000", clock)
    }
    
    func dEqualsDMinusM() -> CPU.Out {
        cpu(11111.b, "1111010011010000", "0", "1")
    }
    
    func jumpIfNegD() -> CPU.Out {
        cpu(11111.b, "1110001100000100", "0", "1")
    }
    
    func writeFromRegisters(
        _ instruction: String,
        _ clock: Char = "1"
    ) -> CPU.Out {
        cpu("0".toBinary(15), instruction, "0", clock)
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
        let expected1 = cpuOut(aValue: 0.b,
                               pcValue: "0".toBinary())
        
        let expected2 = cpuOut(aValue: "011000000111001",
                               pcValue: "1".toBinary())
        
        let expected3 = cpuOut(aValue: "011000000111001",
                               pcValue: "1".toBinary())
        
        let expected4 = cpuOut(aValue: "101101110100000",
                               pcValue: "2".toBinary())
        
        cpu("0", "0011000000111001", "0", "0") ==> expected1
        cpu("0", "0011000000111001", "0", "1") ==> expected2
        
        cpu("0", "0101101110100000", "0", "0") ==> expected3
        cpu("0", "0101101110100000", "0", "1") ==> expected4
    }
    
    func testDAndMInstructions() {
        setA(12345.b)
        dEqualsA()
        ==> cpuOut(aValue: 12345.b,
                  pcValue: "2".toBinary())
        cpu.d.value => 12345.b
        
        setA(23456.b)
        aMinusD()
        ==> cpuOut(aValue: 23456.b,
                  pcValue: "4".toBinary())
        cpu.d.value => 11111.b
        
        setA(1000.b)
        mEqualsD() ==> cpuOut(toMemory: 11111.b,
                             shouldWrite: "1",
                             aValue: 1000.b,
                             pcValue: "6".toBinary())
        cpu.d.value => 11111.b
        
        setA(1001.b)
        mdEqualsDMinusOne(clock: "0")
        ==> cpuOut(toMemory: 11110.b,
                  shouldWrite: "1",
                  aValue: 1001.b,
                  pcValue: "7".toBinary())
        
        mdEqualsDMinusOne(clock: "1")
        ==> cpuOut(toMemory: 11109.b,
                  shouldWrite: "1",
                  aValue: 1001.b,
                  pcValue: "8".toBinary())
        cpu.d.value => 11110.b
        
        setA(1000.b)
        dEqualsDMinusM()
        ==> cpuOut(aValue: 1000.b,
                  pcValue: "10".toBinary())
        cpu.d.value => (-1).b
        
        setA(14.b)
        jumpIfNegD()
        ==> cpuOut(aValue: 14.b,
                  pcValue: "14".toBinary())
        
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
            
            return [output.toDecimal(),
                    result.shouldWrite,
                    result.aValue.toDecimal(),
                    result.pcValue.toDecimal()]
        }.run()
    }
}

extension Register {
    fileprivate var value: String {
        self("0".toBinary(15), "0", "0")
    }
}

extension Int {
    fileprivate var b: String {
        String(self).toBinary(15)
    }
}

infix operator ==>

func ==>(actual: CPU.Out, expected: CPU.Out) {
    XCTAssertEqual(actual.pcValue, expected.pcValue, "pcValue")
    XCTAssertEqual(actual.aValue, expected.aValue, "aValue")
    XCTAssertEqual(actual.shouldWrite, expected.shouldWrite, "shouldWrite")
    
    if !expected.toMemory.contains("*") {
        XCTAssertEqual(actual.toMemory, expected.toMemory, "toMemory")
    }
}
