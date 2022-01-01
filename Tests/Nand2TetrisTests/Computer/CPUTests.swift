import XCTest
@testable import Nand2Tetris

class CPUTests: XCTestCase {
    var cpu: CPU!
    
    override func setUp() {
        cpu = CPU()
    }
    
    func setA(_ value: String) {
        let _ = cpu("0", value, "0", "1")
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
    
    func aEqualsAPlus1() -> CPU.Out {
        writeFromRegisters("1110110111100000")
    }
    
    func writeFromRegisters(
        _ instruction: String,
        _ clock: Char = "1"
    ) -> CPU.Out {
        cpu(0.b, instruction, "0", clock)
    }
    
    func cpuOut(
        mValue: String = "*******",
        shouldWrite: Char = "0",
        aValue: String,
        pcValue: String
    ) -> CPU.Out {
        CPU.Out(mValue: mValue,
                shouldWrite: shouldWrite,
                aValue: aValue,
                pcValue: pcValue)
    }
    
    func testAInstructions() {
        cpu("0", "0011000000111001", "0", "0")
        ==> cpuOut(aValue: 0.b,
                   pcValue: 0.b)
        
        cpu("0", "0011000000111001", "0", "1")
        ==> cpuOut(aValue: "0011000000111001",
                   pcValue: 1.b)
        
        cpu("0", "0101101110100000", "0", "0")
        ==> cpuOut(aValue: "0011000000111001",
                   pcValue: 1.b)
        
        cpu("0", "0101101110100000", "0", "1")
        ==> cpuOut(aValue: "0101101110100000",
                   pcValue: 2.b)
    }
    
    func testDAndMInstructions() {
        setA(12345.b)
        dEqualsA()
        ==> cpuOut(aValue: 12345.b,
                   pcValue: 2.b)
        cpu.dRegister.value => 12345.b
        
        setA(23456.b)
        aMinusD()
        ==> cpuOut(aValue: 23456.b,
                   pcValue: 4.b)
        cpu.dRegister.value => 11111.b
        
        setA(1000.b)
        mEqualsD() ==> cpuOut(mValue: 11111.b,
                              shouldWrite: "1",
                              aValue: 1000.b,
                              pcValue: 6.b)
        cpu.dRegister.value => 11111.b
        
        setA(1001.b)
        mdEqualsDMinusOne(clock: "0")
        ==> cpuOut(mValue: 11110.b,
                   shouldWrite: "1",
                   aValue: 1001.b,
                   pcValue: 7.b)
        
        mdEqualsDMinusOne(clock: "1")
        ==> cpuOut(mValue: 11109.b,
                   shouldWrite: "1",
                   aValue: 1001.b,
                   pcValue: 8.b)
        cpu.dRegister.value => 11110.b
        
        setA(1000.b)
        dEqualsDMinusM()
        ==> cpuOut(aValue: 1000.b,
                   pcValue: 10.b)
        cpu.dRegister.value => (-1).b
        
        setA(14.b)
        jumpIfNegD()
        ==> cpuOut(aValue: 14.b,
                   pcValue: 14.b)
        
        setA(999.b)
        aEqualsAPlus1()
        ==> cpuOut(aValue: 1000.b,
                   pcValue: 16.b)
    }
    
    func testAcceptance() throws {
        try FileBasedATR("Computer/CPU-external", firstOutputColumn: 4) {
            let clock = $0[0].clockSignal
            let input = $0[1].toBinary()
            let code = $0[2]
            let reset = $0[3].toChar
            
            let result = self.cpu(input, code, reset, clock)
            let shouldWrite = result.shouldWrite
            let aValue = result.aValue.toDecimal()
            let pcValue = result.pcValue.toDecimal()
            
            return shouldWrite == "1"
            ? [result.mValue.toDecimal(), shouldWrite, aValue, pcValue]
            : ["*******", shouldWrite, aValue, pcValue]
        }.run()
    }
}

extension Register {
    fileprivate var value: String {
        self(0.b, "0", "0")
    }
}

extension Int {
    fileprivate var b: String {
        String(self).toBinary()
    }
}

infix operator ==>

fileprivate func ==>(actual: CPU.Out, expected: CPU.Out) {
    XCTAssertEqual(actual.pcValue, expected.pcValue,
                   "pcValue")
    XCTAssertEqual(actual.aValue, expected.aValue,
                   "aValue")
    XCTAssertEqual(actual.shouldWrite, expected.shouldWrite,
                   "shouldWrite")
    
    if !expected.mValue.contains("*") {
        XCTAssertEqual(actual.mValue, expected.mValue,
                       "toMemory")
    }
}
